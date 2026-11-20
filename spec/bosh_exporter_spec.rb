require 'rspec'
require 'yaml'
require 'bosh/template/test'

describe 'bosh_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('bosh_exporter') }

  describe 'config/bpm.yml template' do
    let(:template) { job.template('config/bpm.yml') }
    let(:mandatory) do
      {
        'bosh_exporter' => {
          'bosh' => { 'url' => 'https://10.0.0.6:25555' },
          'metrics' => { 'environment' => 'test' },
        }
      }
    end

    def process(props)
      YAML.safe_load(template.render(props))['processes'].first
    end

    context 'when only mandatory properties are configured' do
      it 'renders the bpm process with default args' do
        proc = process(mandatory)
        expect(proc['name']).to eq('bosh_exporter')
        expect(proc['executable']).to eq('/var/vcap/packages/bosh_exporter/bin/bosh_exporter')
        expect(proc['persistent_disk']).to eq(true)
        expect(proc['args']).to contain_exactly(
          '--bosh.url=https://10.0.0.6:25555',
          '--metrics.environment=test',
          '--sd.filename=/var/vcap/store/bosh_exporter/bosh_target_groups.json',
          '--web.listen-address=:9190',
        )
        expect(proc['env']).to eq({})
      end
    end

    context 'when optional properties are configured' do
      it 'renders flags, secrets as env and proxy settings' do
        proc = process(
          'bosh_exporter' => {
            'bosh' => {
              'url' => 'https://10.0.0.6:25555',
              'username' => 'admin',
              'password' => 'secret',
              'uaa' => { 'client_id' => 'exporter', 'client_secret' => 'uaa-secret' },
              'ca_cert' => 'CA',
            },
            'metrics' => { 'environment' => 'test', 'namespace' => 'ns' },
            'sd' => { 'processes_regexp' => '^node_exporter$' },
            'web' => { 'port' => '8080', 'auth_username' => 'u', 'auth_password' => 'p', 'tls_cert' => 'C', 'tls_key' => 'K' },
          },
          'env' => { 'http_proxy' => 'http://proxy:3128' }
        )
        expect(proc['args']).to include(
          '--bosh.username=admin',
          '--bosh.uaa.client-id=exporter',
          '--bosh.ca-cert-file=/var/vcap/jobs/bosh_exporter/config/bosh_ca_cert.pem',
          '--metrics.namespace=ns',
          '--sd.processes_regexp=^node_exporter$',
          '--web.listen-address=:8080',
          '--web.auth.username=u',
          '--web.tls.cert_file=/var/vcap/jobs/bosh_exporter/config/web_tls_cert.pem',
          '--web.tls.key_file=/var/vcap/jobs/bosh_exporter/config/web_tls_key.pem',
        )
        expect(proc['args'].join(' ')).not_to include('secret', 'p ')
        expect(proc['env']).to eq(
          'BOSH_EXPORTER_BOSH_PASSWORD' => 'secret',
          'BOSH_EXPORTER_BOSH_UAA_CLIENT_SECRET' => 'uaa-secret',
          'BOSH_EXPORTER_WEB_AUTH_PASSWORD' => 'p',
          'HTTP_PROXY' => 'http://proxy:3128',
          'http_proxy' => 'http://proxy:3128',
        )
      end
    end
  end
end
