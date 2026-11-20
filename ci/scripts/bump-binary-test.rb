require 'minitest/autorun'
require 'minitest/mock'
require 'tmpdir'
require_relative 'bump-binary'

class FixtureBinaryBump < BinaryBump
  attr_accessor :release, :archive, :api_error
  attr_reader :commands

  def initialize(*args)
    super
    @commands = []
  end

  private

  def command(*args)
    @commands << args
    case args.first
    when 'gh'
      raise api_error if api_error

      JSON.generate(release)
    when 'curl'
      FileUtils.cp(archive, args.last)
      ''
    else
      super
    end
  end
end

class BinaryBumpTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)

  def with_fixture(component = 'cf_exporter')
    Dir.mktmpdir('binary-bump-test-') do |tmp|
      root = File.join(tmp, 'release')
      FileUtils.mkdir_p(File.join(root, "packages/#{component}"))
      FileUtils.mkdir_p(File.join(root, 'config'))
      separator = component == 'bosh_exporter' ? '-' : '_'
      blob = "#{component}/#{component}#{separator}2.2.0.linux-amd64.tar.gz"
      legacy_blob = blob.sub('2.2.0', '2.1.0')
      File.write(File.join(root, "packages/#{component}/spec"),
                 YAML.dump('name' => component, 'files' => ['common/utils.sh', blob]))
      File.write(File.join(root, "packages/#{component}/packaging"),
                 "tar zxf #{blob} --strip 1 -C ${BOSH_INSTALL_TARGET}/bin\n")
      metadata = { 'size' => 1, 'object_id' => 'fixture-object', 'sha' => "sha256:#{'0' * 64}" }
      File.write(File.join(root, 'config/blobs.yml'), YAML.dump(legacy_blob => metadata, blob => metadata.dup))
      File.write(File.join(root, 'config/final.yml'),
                 YAML.dump('final_name' => 'fixture', 'blobstore' => { 'provider' => 'local', 'options' => { 'blobstore_path' => File.join(tmp, 'blobstore') } }))
      File.write(File.join(root, 'VERSIONS.md'),
                 "| [#{component}] | cf | v2.2.0 | |\n| [unrelated_exporter] | cf | v1.0.0 | |\n")
      File.write(File.join(tmp, 'binary'), 'fixture binary')
      stdout, stderr, status = Open3.capture3('tar', '-czf', File.join(tmp, 'binary.tar.gz'), '-C', tmp, 'binary')
      raise "Fixture tar failed: #{stdout} #{stderr}" unless status.success?

      variables = {
        'GITHUB_OUTPUT' => File.join(tmp, 'output'),
        'GITHUB_SERVER_URL' => 'https://github.com',
        'GITHUB_REPOSITORY' => 'cloudfoundry/prometheus-boshrelease',
        'GITHUB_RUN_ID' => '123',
        'BOSH_CONFIG' => File.join(tmp, 'bosh-config')
      }
      original = variables.to_h { |key, _| [key, ENV[key]] }
      begin
        ENV.update(variables)
        Dir.chdir(root) do
          bump = FixtureBinaryBump.new(component, File.join(tmp, 'artifact'))
          bump.archive = File.join(tmp, 'binary.tar.gz')
          yield bump, tmp
        end
      ensure
        original.each { |key, value| value ? ENV[key] = value : ENV.delete(key) }
      end
    end
  end

  def release_for(component, version, archive)
    repository = BinaryBump::REPOSITORIES.fetch(component)
    filename = "#{component}-#{version}.linux-amd64.tar.gz"
    {
      'tag_name' => "v#{version}",
      'draft' => false,
      'prerelease' => false,
      'assets' => [{
        'name' => filename,
        'browser_download_url' => "https://github.com/#{repository}/releases/download/v#{version}/#{filename}",
        'size' => File.size(archive),
        'digest' => "sha256:#{Digest::SHA256.file(archive).hexdigest}"
      }]
    }
  end

  def assert_unchanged(before)
    before.each { |path, contents| assert_equal contents, File.read(path), path }
  end

  def tracked_contents(component)
    %W[config/blobs.yml packages/#{component}/spec packages/#{component}/packaging VERSIONS.md].to_h do |file|
      [file, File.read(file)]
    end
  end

  def test_all_three_components_update_with_real_bosh_and_preserve_unrelated_blobs
    assert_equal %w[bosh_exporter cf_exporter firehose_exporter], BinaryBump::REPOSITORIES.keys.sort
    BinaryBump::REPOSITORIES.each_key do |component|
      with_fixture(component) do |bump, tmp|
        old_blob, old_version = bump.current_blob
        parts = old_version.split('.').map(&:to_i)
        parts[-1] += 1
        version = parts.join('.')
        before = YAML.safe_load_file('config/blobs.yml')
        before_versions = File.readlines('VERSIONS.md').reject { |line| line.match?(/^\| \[#{Regexp.escape(component)}\]/) }
        bump.release = release_for(component, version, bump.archive)
        capture_io { bump.run }

        blob = old_blob.sub(old_version, version)
        after = YAML.safe_load_file('config/blobs.yml')
        assert_equal before.reject { |key, _| key == old_blob }, after.reject { |key, _| key == blob }, component
        assert_equal File.size(bump.archive), after.fetch(blob).fetch('size')
        assert_equal "sha256:#{Digest::SHA256.file(bump.archive).hexdigest}", after.fetch(blob).fetch('sha')
        refute after.fetch(blob).key?('object_id'), 'New blob must still require upload'
        assert_includes YAML.safe_load_file("packages/#{component}/spec").fetch('files'), blob
        refute_includes File.read("packages/#{component}/packaging"), old_version
        assert_includes File.read("packages/#{component}/packaging"), version
        version_row = File.readlines('VERSIONS.md').find { |line| line.match?(/^\| \[#{Regexp.escape(component)}\]/) }
        assert_match(/\|\s*v#{Regexp.escape(version)}\s*\|/, version_row)
        assert_equal before_versions, File.readlines('VERSIONS.md').reject { |line| line.match?(/^\| \[#{Regexp.escape(component)}\]/) }
        assert_includes File.read(ENV.fetch('GITHUB_OUTPUT')), "changed=true\n"
        assert_includes File.read(ENV.fetch('GITHUB_OUTPUT')), "artifact_dir=#{tmp}/artifact\n"
        metadata = JSON.parse(File.read(File.join(tmp, 'artifact/metadata.json')))
        assert_equal blob, metadata.fetch('blob')
        assert_equal version, metadata.fetch('version')
        assert_equal Digest::SHA256.file(bump.archive).hexdigest, metadata.fetch('sha256')
        assert_equal File.binread(bump.archive), File.binread(File.join(tmp, 'artifact', File.basename(blob)))
        body = File.read(File.join(tmp, 'artifact/pr-body.md'))
        assert_includes body, 'DO NOT MERGE'
        assert_includes body, 'Disable'
        assert_equal 1, bump.commands.count { |command| command.first == 'gh' }
        refute bump.commands.any? { |command| command.include?('upload-blobs') }
      end
    end
  end

  def test_up_to_date_does_not_download_or_modify_files
    with_fixture do |bump, tmp|
      before = tracked_contents('cf_exporter')
      bump.release = release_for('cf_exporter', bump.current_blob.last, bump.archive)
      capture_io { bump.run }
      assert_unchanged(before)
      assert_equal [['gh', 'api', 'repos/cloudfoundry/cf_exporter/releases/latest']], bump.commands
      assert_equal "changed=false\n", File.read(ENV.fetch('GITHUB_OUTPUT'))
      refute Dir.exist?(File.join(tmp, 'artifact'))
    end
  end

  def test_firehose_uses_active_blob_instead_of_older_blob_and_rejects_downgrades
    with_fixture('firehose_exporter') do |bump, _|
      assert_equal '2.2.0', bump.current_blob.last
      assert_raises(RuntimeError) { bump.plan(release_for('firehose_exporter', '2.1.0', bump.archive)) }
    end
  end

  def test_rejects_missing_ambiguous_assets_and_unsupported_tags
    with_fixture do |bump, _|
      release = release_for('cf_exporter', '2.2.1', bump.archive)
      assert_raises(RuntimeError) { bump.plan(release.merge('assets' => [])) }
      assert_raises(RuntimeError) { bump.plan(release.merge('assets' => release.fetch('assets') * 2)) }
      ['null', 'v2.2.1-rc.1', "v2.2.1\nchanged=true"].each do |tag|
        assert_raises(RuntimeError) { bump.plan(release.merge('tag_name' => tag)) }
      end
      ['draft', 'prerelease'].each do |key|
        assert_raises(RuntimeError) { bump.plan(release.merge(key => true)) }
      end
      asset = release.fetch('assets').first.merge('browser_download_url' => 'https://example.com/binary.tar.gz')
      assert_raises(RuntimeError) { bump.plan(release.merge('assets' => [asset])) }
    end
  end

  def test_supports_upstream_exporter_filenames
    %w[bosh_exporter cf_exporter firehose_exporter].each do |component|
      with_fixture(component) do |bump, _|
        release = release_for(component, '99.0.0', bump.archive)
        asset = release.fetch('assets').first
        separator = component == 'bosh_exporter' ? '-' : '_'
        asset['name'] = "#{component}#{separator}99.0.0.linux-amd64.tar.gz"
        assert_equal '99.0.0', bump.plan(release).fetch('version')
      end
    end
  end

  def test_api_errors_fail_without_success_output
    with_fixture do |bump, _|
      before = tracked_contents('cf_exporter')
      bump.api_error = 'GitHub API request failed'
      assert_raises(RuntimeError) { bump.run }
      assert_unchanged(before)
      refute File.exist?(ENV.fetch('GITHUB_OUTPUT'))
    end
  end

  def test_digest_size_and_invalid_archive_fail_before_modifying_release
    %w[digest size archive].each do |failure|
      with_fixture do |bump, _|
        before = tracked_contents('cf_exporter')
        File.write(bump.archive, 'not an archive') if failure == 'archive'
        bump.release = release_for('cf_exporter', '2.2.1', bump.archive)
        asset = bump.release.fetch('assets').first
        asset['digest'] = "sha256:#{'0' * 64}" if failure == 'digest'
        asset['size'] += 1 if failure == 'size'
        assert_raises(RuntimeError) { bump.run }
        assert_unchanged(before)
        refute bump.commands.any? { |command| command.first == 'bosh' }
        refute File.exist?(ENV.fetch('GITHUB_OUTPUT'))
      end
    end
  end

  def test_missing_upstream_digest_is_explicitly_documented
    with_fixture do |bump, tmp|
      bump.release = release_for('cf_exporter', '2.2.1', bump.archive)
      bump.release.fetch('assets').first.delete('digest')
      capture_io { bump.run }
      assert_includes File.read(File.join(tmp, 'artifact/pr-body.md')), 'not supplied; SHA256 above is computed locally'
    end
  end

  def test_manual_handoff_can_restore_blob_from_artifact_in_clean_checkout
    with_fixture('cf_exporter') do |bump, tmp|
      bump.release = release_for('cf_exporter', '2.2.1', bump.archive)
      capture_io { bump.run }
      metadata = JSON.parse(File.read(File.join(tmp, 'artifact/metadata.json')))
      blob = metadata.fetch('blob')
      binary = File.join(tmp, 'artifact', File.basename(blob))
      %w[blobs .blobs].each { |directory| FileUtils.rm_rf(File.join(Dir.pwd, directory)) }
      stdout, stderr, status = Open3.capture3('bosh', '--non-interactive', '--sha2', 'add-blob', binary, blob)
      assert status.success?, "#{stdout}\n#{stderr}"
      assert_equal File.binread(binary), File.binread(File.join('blobs', blob))
      refute YAML.safe_load_file('config/blobs.yml').fetch(blob).key?('object_id')
    end
  end

  def test_rejects_unknown_components_and_artifacts_inside_repository
    with_fixture do |_, _|
      assert_raises(KeyError) { BinaryBump.new('unknown_binary', '/tmp/artifact') }
      assert_raises(KeyError) { BinaryBump.new('prometheus', '/tmp/artifact') }
      assert_raises(ArgumentError) { BinaryBump.new('cf_exporter', 'artifact') }
    end
  end

  def test_packaging_mismatch_fails_before_downloading
    with_fixture do |bump, _|
      File.write('packages/cf_exporter/packaging', 'tar xzf cf_exporter/wrong.tar.gz')
      bump.release = release_for('cf_exporter', '2.2.1', bump.archive)
      before = tracked_contents('cf_exporter')
      assert_raises(RuntimeError) { bump.run }
      assert_unchanged(before)
      refute bump.commands.any? { |command| command.first == 'curl' }
    end
  end

  def test_single_configured_workflow_is_a_valid_supported_subset
    files = [
      File.join(ROOT, '.github/workflows/bump-binary.yml'),
      File.join(ROOT, '.github/workflows/bump-cf-exporter.yml')
    ]
    Dir.stub(:glob, files) do
      test_configured_workflows_use_supported_components_and_always_create_drafts
    end
  end

  def test_configured_workflows_use_supported_components_and_always_create_drafts
    callers = Dir.glob(File.join(ROOT, '.github/workflows/bump-*.yml')).reject { |file| File.basename(file) == 'bump-binary.yml' }
    components = callers.map do |file|
      workflow = YAML.safe_load_file(file)
      assert workflow.fetch('on').key?('workflow_dispatch')
      assert_equal 1, workflow.fetch('on').fetch('schedule').length
      assert_equal({ 'contents' => 'write', 'pull-requests' => 'write' }, workflow.fetch('permissions'))
      job = workflow.fetch('jobs').fetch('bump')
      assert_equal './.github/workflows/bump-binary.yml', job.fetch('uses')
      job.fetch('with').fetch('component')
    end
    refute_empty components
    assert_empty components - BinaryBump::REPOSITORIES.keys
    assert_equal components.uniq, components
    shared = YAML.safe_load_file(File.join(ROOT, '.github/workflows/bump-binary.yml'))
    steps = shared.fetch('jobs').fetch('bump').fetch('steps')
    pr = steps.find { |step| step['uses'] == 'peter-evans/create-pull-request@v7' }
    assert_equal 'always-true', pr.fetch('with').fetch('draft')
    artifact = steps.find { |step| step['uses'] == 'actions/upload-artifact@v4' }
    assert_equal 30, artifact.fetch('with').fetch('retention-days')
    assert_operator steps.index(artifact), :<, steps.index(pr)
  end
end
