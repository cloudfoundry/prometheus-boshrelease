#!/usr/bin/env ruby

require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'pathname'
require 'rubygems/version'
require 'yaml'

class BinaryBump
  REPOSITORIES = {
    'bosh_exporter' => 'cloudfoundry/bosh_exporter',
    'cf_exporter' => 'cloudfoundry/cf_exporter',
    'firehose_exporter' => 'cloudfoundry/firehose_exporter'
  }.freeze

  VERSION = /\A(?:v)?(\d+\.\d+\.\d+)\z/

  def initialize(component, artifact_dir)
    @component = component
    @repository = REPOSITORIES.fetch(component)
    @artifact_dir = File.expand_path(artifact_dir)
    root = Pathname.new(Dir.pwd)
    if Pathname.new(@artifact_dir).ascend.any? { |path| path == root }
      raise ArgumentError, 'Artifacts must be stored outside the repository'
    end
  end

  def current_blob
    spec = YAML.safe_load_file("packages/#{@component}/spec")
    blobs = spec.fetch('files').select { |file| file.start_with?("#{@component}/") }
    raise "Expected exactly one active blob for #{@component}, found #{blobs.length}" unless blobs.length == 1

    blob = blobs.first
    pattern = %r{\A#{Regexp.escape(@component)}/#{Regexp.escape(@component)}[-_]v?(\d+\.\d+\.\d+)(?:\.linux-amd64|_linux_amd64)\.tar\.gz\z}
    match = pattern.match(blob)
    raise "Unsupported blob filename: #{blob}" unless match
    raise "Active blob missing from config/blobs.yml: #{blob}" unless YAML.safe_load_file('config/blobs.yml').key?(blob)

    [blob, match[1]]
  end

  def plan(release)
    old_blob, old_version = current_blob
    raise 'Expected a published, stable release' if release.fetch('draft') || release.fetch('prerelease')

    match = VERSION.match(release.fetch('tag_name'))
    raise "Unsupported release tag: #{release.fetch('tag_name')}" unless match

    version = match[1]
    comparison = Gem::Version.new(version) <=> Gem::Version.new(old_version)
    raise "Refusing downgrade from #{old_version} to #{version}" if comparison.negative?
    return nil if comparison.zero?

    asset_pattern = /\A#{Regexp.escape(@component)}[-_]v?#{Regexp.escape(version)}(?:\.linux-amd64|_linux_amd64)\.tar\.gz\z/
    assets = release.fetch('assets').select { |asset| asset_pattern.match?(asset.fetch('name')) }
    raise "Expected one Linux amd64 asset for #{@repository} #{version}, found #{assets.length}" unless assets.length == 1

    asset = assets.first
    url = asset.fetch('browser_download_url')
    prefix = "https://github.com/#{@repository}/releases/download/"
    raise "Unexpected release asset URL: #{url}" unless url.start_with?(prefix)

    {
      'component' => @component,
      'repository' => @repository,
      'old_version' => old_version,
      'version' => version,
      'old_blob' => old_blob,
      'blob' => old_blob.sub(old_version, version),
      'url' => url,
      'size' => asset.fetch('size'),
      'upstream_digest' => asset['digest']
    }
  end

  def run
    release = JSON.parse(command('gh', 'api', "repos/#{@repository}/releases/latest"))
    update = plan(release)
    unless update
      puts "#{@component} is already up to date"
      output('changed', 'false')
      return
    end

    spec_path = "packages/#{@component}/spec"
    packaging_path = "packages/#{@component}/packaging"
    spec = File.read(spec_path)
    packaging = File.read(packaging_path)
    versions = File.read('VERSIONS.md')
    filename_pattern = /#{Regexp.escape(@component)}([-_]v?)#{Regexp.escape(update.fetch('old_version'))}(?=\.linux-amd64|_linux_amd64)/
    updated_packaging = packaging.gsub(filename_pattern) { "#{@component}#{Regexp.last_match(1)}#{update.fetch('version')}" }
    if updated_packaging == packaging
      raise "Packaging does not reference the active version: #{packaging_path}"
    end

    row_pattern = /^(\| \[#{Regexp.escape(@component)}\]\s*\|[^|]*\|\s*)v\d+\.\d+\.\d+(\s*\|.*)$/
    raise "Expected one version row for #{@component}" unless versions.scan(row_pattern).length == 1

    updated_versions = versions.sub(row_pattern) { "#{Regexp.last_match(1)}v#{update.fetch('version')}#{Regexp.last_match(2)}" }
    updated_spec = spec.gsub(update.fetch('old_blob'), update.fetch('blob'))
    raise "Active blob not found in #{spec_path}" if updated_spec == spec

    FileUtils.mkdir_p(@artifact_dir)
    binary = File.join(@artifact_dir, File.basename(update.fetch('blob')))
    command('curl', '--fail', '--location', '--silent', '--show-error', '--retry', '3',
            '--proto', '=https', '--proto-redir', '=https', update.fetch('url'), '--output', binary)
    raise 'Downloaded asset size differs from release metadata' unless File.size(binary) == update.fetch('size')

    update['sha256'] = Digest::SHA256.file(binary).hexdigest
    digest = update.fetch('upstream_digest')
    if digest && digest != "sha256:#{update.fetch('sha256')}"
      raise "Upstream digest does not match downloaded asset: #{digest}"
    end
    command('tar', '-tzf', binary)

    command('bosh', '--non-interactive', '--sha2', 'add-blob', binary, update.fetch('blob'))
    command('bosh', '--non-interactive', 'remove-blob', update.fetch('old_blob'))
    File.write(spec_path, updated_spec)
    File.write(packaging_path, updated_packaging)
    File.write('VERSIONS.md', updated_versions)
    File.write(File.join(@artifact_dir, 'metadata.json'), "#{JSON.pretty_generate(update)}\n")
    File.write(File.join(@artifact_dir, 'pr-body.md'), pr_body(update))

    output('artifact_dir', @artifact_dir)
    output('version', update.fetch('version'))
    output('changed', 'true')
    puts "#{@component}: #{update.fetch('old_version')} -> #{update.fetch('version')} (upload required)"
  end

  private

  def command(*args)
    stdout, stderr, status = Open3.capture3(*args)
    raise "#{args.first} failed (#{status.exitstatus}): #{stderr}\n#{stdout}" unless status.success?

    stdout
  end

  def output(key, value)
    File.open(ENV.fetch('GITHUB_OUTPUT'), 'a') { |file| file.puts("#{key}=#{value}") }
  end

  def pr_body(update)
    run_url = "#{ENV.fetch('GITHUB_SERVER_URL')}/#{ENV.fetch('GITHUB_REPOSITORY')}/actions/runs/#{ENV.fetch('GITHUB_RUN_ID')}"
    <<~BODY
      Bumps #{@component} from #{update.fetch('old_version')} to #{update.fetch('version')}.

      **DO NOT MERGE: the new blob has NOT been uploaded to the BOSH blobstore.**

      Source: #{update.fetch('url')}
      SHA256: `#{update.fetch('sha256')}`
      Upstream digest: #{update.fetch('upstream_digest') || 'not supplied; SHA256 above is computed locally'}
      Binary and metadata: [workflow run](#{run_url}), artifact `#{@component}-#{update.fetch('version')}` (retained for 30 days).

      Before marking this PR ready:
      - [ ] Disable this component's workflow and wait for active runs to finish.
      - [ ] Check out this PR branch and download/extract the artifact.
      - [ ] Verify the binary against its SHA256 above.
      - [ ] Run `bosh --sha2 add-blob <downloaded-binary> #{update.fetch('blob')}`.
      - [ ] Run `bosh --sha2 upload-blobs` with the release blobstore credentials.
      - [ ] Commit and push the resulting `config/blobs.yml` with the new `object_id`.
      - [ ] Validate the release/package before merging.
      - [ ] Re-enable the component's workflow after merging.

      Keep the workflow disabled throughout the handoff: scheduled or manual updates regenerate the draft branch from the default branch and can overwrite manual edits.
    BODY
  end
end

if $PROGRAM_NAME == __FILE__
  raise ArgumentError, 'Usage: ruby ci/scripts/bump-binary.rb COMPONENT ARTIFACT_DIR' unless ARGV.length == 2

  BinaryBump.new(*ARGV).run
end
