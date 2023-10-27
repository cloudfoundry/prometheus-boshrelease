require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'firehose_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('firehose_exporter') }

  describe 'config/bpm.yml template' do
    let(:template) { job.template('config/bpm.yml') }
    let(:rendered_template) { template.render(properties) }
    let(:properties) do
      {
        'firehose_exporter' => {
          'metrics' => {
            'environment' => 'test'
          },
          'logging' => {
            'url' => 'http://api.yoursystemdomain.here.com'
          },
        }
      }
    end

    it 'renders with default values' do
      expect(rendered_template).to include('FIREHOSE_EXPORTER_LOGGING_URL: http://api.yoursystemdomain.here.com')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_LOGGING_TLS_CA: "/var/vcap/jobs/firehose_exporter/config/rlp_tls_ca.pem"')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_LOGGING_TLS_CERT: "/var/vcap/jobs/firehose_exporter/config/rlp_tls_cert.pem"')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_LOGGING_TLS_KEY: "/var/vcap/jobs/firehose_exporter/config/rlp_tls_key.pem"')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_SHARD_ID: prometheus')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_NODE_INDEX: 0')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_TIMER_ROLLUP_BUFFER_SIZE: 16384')
      expect(rendered_template).to include("FIREHOSE_EXPORTER_FILTER_DEPLOYMENTS: ''")
      expect(rendered_template).to include("FIREHOSE_EXPORTER_FILTER_EVENTS: ''")
      expect(rendered_template).to include('FIREHOSE_EXPORTER_METRICS_NAMESPACE: firehose')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_METRICS_ENVIRONMENT: test')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_METRICS_EXPIRATION: 10m')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_WEB_LISTEN_ADDRESS: ":9186"')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_WEB_TELEMETRY_PATH: "/metrics"')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_LOG_LEVEL: info')
      expect(rendered_template).to include('FIREHOSE_EXPORTER_RETRO_COMPAT_DISABLE: false')
    end
  end
end
