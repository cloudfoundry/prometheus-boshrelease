require 'minitest/autorun'
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

  def with_fixture(component = 'prometheus')
    Dir.mktmpdir('binary-bump-test-') do |tmp|
      root = File.join(tmp, 'release')
      FileUtils.mkdir_p(File.join(root, "packages/#{component}"))
      FileUtils.mkdir_p(File.join(root, 'config'))
      %W[packages/#{component}/spec packages/#{component}/packaging config/blobs.yml config/final.yml VERSIONS.md].each do |file|
        FileUtils.cp(File.join(ROOT, file), File.join(root, file))
      end
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

  def test_all_23_components_update_with_real_bosh_and_preserve_unrelated_blobs
    assert_equal 23, BinaryBump::REPOSITORIES.length
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
        unless component == 'mongodb_exporter'
          assert_includes File.read("packages/#{component}/packaging"), version
        end
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
      before = tracked_contents('prometheus')
      bump.release = release_for('prometheus', bump.current_blob.last, bump.archive)
      capture_io { bump.run }
      assert_unchanged(before)
      assert_equal [['gh', 'api', 'repos/prometheus/prometheus/releases/latest']], bump.commands
      assert_equal "changed=false\n", File.read(ENV.fetch('GITHUB_OUTPUT'))
      refute Dir.exist?(File.join(tmp, 'artifact'))
    end
  end

  def test_prometheus_uses_active_v3_blob_and_rejects_major_changes_and_downgrades
    with_fixture do |bump, _|
      assert_equal '3.13.1', bump.current_blob.last
      ['4.0.0', '3.12.0'].each do |version|
        assert_raises(RuntimeError) { bump.plan(release_for('prometheus', version, bump.archive)) }
      end
    end
  end

  def test_rejects_missing_ambiguous_assets_and_unsupported_tags
    with_fixture do |bump, _|
      release = release_for('prometheus', '3.13.2', bump.archive)
      assert_raises(RuntimeError) { bump.plan(release.merge('assets' => [])) }
      assert_raises(RuntimeError) { bump.plan(release.merge('assets' => release.fetch('assets') * 2)) }
      ['null', 'v3.13.2-rc.1', "v3.13.2\nchanged=true"].each do |tag|
        assert_raises(RuntimeError) { bump.plan(release.merge('tag_name' => tag)) }
      end
      ['draft', 'prerelease'].each do |key|
        assert_raises(RuntimeError) { bump.plan(release.merge(key => true)) }
      end
      asset = release.fetch('assets').first.merge('browser_download_url' => 'https://example.com/binary.tar.gz')
      assert_raises(RuntimeError) { bump.plan(release.merge('assets' => [asset])) }
    end
  end

  def test_supports_upstream_underscore_and_redis_v_filenames
    %w[cf_exporter credhub_exporter firehose_exporter redis_exporter].each do |component|
      with_fixture(component) do |bump, _|
        release = release_for(component, '99.0.0', bump.archive)
        asset = release.fetch('assets').first
        asset['name'] = if component == 'redis_exporter'
                          "#{component}-v99.0.0.linux-amd64.tar.gz"
                        elsif component == 'credhub_exporter'
                          "#{component}_99.0.0_linux_amd64.tar.gz"
                        else
                          "#{component}_99.0.0.linux-amd64.tar.gz"
                        end
        assert_equal '99.0.0', bump.plan(release).fetch('version')
      end
    end
  end

  def test_api_errors_fail_without_success_output
    with_fixture do |bump, _|
      before = tracked_contents('prometheus')
      bump.api_error = 'GitHub API request failed'
      assert_raises(RuntimeError) { bump.run }
      assert_unchanged(before)
      refute File.exist?(ENV.fetch('GITHUB_OUTPUT'))
    end
  end

  def test_digest_size_and_invalid_archive_fail_before_modifying_release
    %w[digest size archive].each do |failure|
      with_fixture do |bump, _|
        before = tracked_contents('prometheus')
        File.write(bump.archive, 'not an archive') if failure == 'archive'
        bump.release = release_for('prometheus', '3.13.2', bump.archive)
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
      bump.release = release_for('prometheus', '3.13.2', bump.archive)
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
      assert_raises(ArgumentError) { BinaryBump.new('prometheus', 'artifact') }
    end
  end

  def test_packaging_mismatch_fails_before_downloading
    with_fixture do |bump, _|
      File.write('packages/prometheus/packaging', 'tar xzf prometheus/wrong.tar.gz')
      bump.release = release_for('prometheus', '3.13.2', bump.archive)
      before = tracked_contents('prometheus')
      assert_raises(RuntimeError) { bump.run }
      assert_unchanged(before)
      refute bump.commands.any? { |command| command.first == 'curl' }
    end
  end

  def test_workflows_cover_exactly_the_supported_components_and_always_create_drafts
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
    assert_equal BinaryBump::REPOSITORIES.keys.sort, components.sort
    shared = YAML.safe_load_file(File.join(ROOT, '.github/workflows/bump-binary.yml'))
    steps = shared.fetch('jobs').fetch('bump').fetch('steps')
    pr = steps.find { |step| step['uses'] == 'peter-evans/create-pull-request@v7' }
    assert_equal 'always-true', pr.fetch('with').fetch('draft')
    assert_includes pr.fetch('with').fetch('commit-message'), 'Co-authored-by: Copilot'
    artifact = steps.find { |step| step['uses'] == 'actions/upload-artifact@v4' }
    assert_equal 30, artifact.fetch('with').fetch('retention-days')
    assert_operator steps.index(artifact), :<, steps.index(pr)
  end
end
