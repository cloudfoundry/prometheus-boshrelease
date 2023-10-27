require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'firehose_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('firehose_exporter') }

  describe 'config/bpm.yml template' do
    let(:template) { job.template('config/bpm.yml') }

    context "when only mandatory specs are configured" do
      it 'renders with default values' do
        bpm_yml = template.render({
          'firehose_exporter' => {
            'metrics' => {
              'environment' => 'test'
            },
            'logging' => {
              'url' => 'http://api.yoursystemdomain.here.com'
            },
          }
        })
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_URL: http://api.yoursystemdomain.here.com')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_TLS_CA: "/var/vcap/jobs/firehose_exporter/config/rlp_tls_ca.pem"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_TLS_CERT: "/var/vcap/jobs/firehose_exporter/config/rlp_tls_cert.pem"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_TLS_KEY: "/var/vcap/jobs/firehose_exporter/config/rlp_tls_key.pem"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_SHARD_ID: prometheus')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_NODE_INDEX: 0')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_TIMER_ROLLUP_BUFFER_SIZE: 16384')
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_FILTER_DEPLOYMENTS: ''")
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_FILTER_EVENTS: ''")
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_NAMESPACE: firehose')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_ENVIRONMENT: test')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_EXPIRATION: 10m')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_WEB_LISTEN_ADDRESS: ":9186"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_WEB_TELEMETRY_PATH: "/metrics"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOG_LEVEL: info')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_RETRO_COMPAT_DISABLE: false')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_RETRO_COMPAT_ENABLE_DELTA: false')
      end
    end

    context "when default values are overwritten" do
      it 'renders with costumized values' do
        bpm_yml = template.render({
            'firehose_exporter' => {
              'doppler' => {
                'metric_expiration' => '15m',
                'subscription_id' => 'prometheus_firehose',
              },
              'filter' => {
                'deployments' => 'prometheus, node-exporter',
                'events' => 'ContainerMetric, CounterEvent'
              },
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'log_level' => 'debug',
              'metrics' => {
                'environment' => 'test',
                'timer_rollup_buffer_size' => 1234,
                'namespace' => 'prometheus_firehose',
              },
              'retro_compat' => {
                'disable' => true,
                'enable_delta' => true
              },
              'web' => {
                'port' => '8080',
                'telemetry_path' => '/new_metrics'
              }
            }
          })
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_URL: http://api.yoursystemdomain.here.com')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_SHARD_ID: prometheus_firehose')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_TIMER_ROLLUP_BUFFER_SIZE: 1234')
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_FILTER_DEPLOYMENTS: prometheus, node-exporter")
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_FILTER_EVENTS: ContainerMetric, CounterEvent")
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_NAMESPACE: prometheus_firehose')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_ENVIRONMENT: test')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_EXPIRATION: 15m')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_WEB_LISTEN_ADDRESS: ":8080"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_WEB_TELEMETRY_PATH: "/new_metrics"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOG_LEVEL: debug')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_RETRO_COMPAT_DISABLE: true')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_RETRO_COMPAT_ENABLE_DELTA: true')
      end
    end

    context "when specs are configured to true which are not included in the config by default" do
      it 'renders with the configuration present' do
        bpm_yml = template.render({
            'firehose_exporter' => {
              'log_in_json' => true,
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              },
              'profiler' => {
                'enable' => true
              },
              'skip_ssl_verify' => true
            }
          })
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_ENABLE_PROFILER: 'true'")
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_URL: http://api.yoursystemdomain.here.com')
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_LOG_IN_JSON: 'true'")
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_ENVIRONMENT: test')
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_SKIP_SSL_VERIFY: 'true'")
      end
    end

    context "when specs are configured which are not included in the config by default" do
      it 'renders with the configuration present' do
        bpm_yml = template.render({
            'env' => {
              'http_proxy' => 'http_proxy:8080',
              'https_proxy' => 'https_proxy:8080',
              'no_proxy' => 'no_proxy'
            },
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              },
              'web' => {
                'auth_username' => 'admin',
                'auth_password' => 'secure_password',
                'tls_cert' => 'cert',
                'tls_key' => 'key'
              }
            }
          })
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_LOGGING_URL: http://api.yoursystemdomain.here.com')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_METRICS_ENVIRONMENT: test')
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_WEB_AUTH_USERNAME: admin")
        expect(bpm_yml).to include("FIREHOSE_EXPORTER_WEB_AUTH_PASSWORD: secure_password")
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_WEB_TLS_CERTFILE: "/var/vcap/jobs/firehose_exporter/config/web_tls_cert.pem"')
        expect(bpm_yml).to include('FIREHOSE_EXPORTER_WEB_TLS_KEYFILE: "/var/vcap/jobs/firehose_exporter/config/web_tls_key.pem"')
        expect(bpm_yml).to include("HTTP_PROXY: http_proxy")
        expect(bpm_yml).to include("HTTPS_PROXY: https_proxy")
        expect(bpm_yml).to include("NO_PROXY: no_proxy")
      end
    end
  end
  describe 'config/web_tls_cert.pem template' do
    let(:template) { job.template('config/web_tls_cert.pem') }

    context "when no cert is provided" do
      it 'renders with no content' do
        web_tls_cert_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(web_tls_cert_pem).to include("")
      end
    end

    context "when a cert is provided" do
      it 'renders with the cert as content' do
        web_tls_cert_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              },
              'web' => {
                'tls_cert' => 'certificate'
              },
            }
          })
        expect(web_tls_cert_pem).to include("certificate")
      end
    end
  end

  describe 'config/web_tls_key.pem template' do
    let(:template) { job.template('config/web_tls_key.pem') }

    context "when no key is provided" do
      it 'renders with no content' do
        web_tls_key_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(web_tls_key_pem).to include("")
      end
    end

    context "when a key is provided" do
      it 'renders with the key as content' do
        web_tls_key_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              },
              'web' => {
                'tls_key' => 'key'
              },
            }
          })
        expect(web_tls_key_pem).to include("key")
      end
    end
  end

  describe 'config/rlp_tls_ca.pem template' do
    let(:template) { job.template('config/rlp_tls_ca.pem') }

    context "when no ca is provided" do
      it 'renders with no content' do
        rlp_tls_ca_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(rlp_tls_ca_pem).to include("")
      end
    end

    context "when a ca is provided" do
      it 'renders with the ca as content' do
        rlp_tls_ca_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com',
                'tls' => {
                  'ca' => 'ca'
                },
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(rlp_tls_ca_pem).to include("ca")
      end
    end
  end

  describe 'config/rlp_tls_cert.pem template' do
    let(:template) { job.template('config/rlp_tls_cert.pem') }

    context "when no cert is provided" do
      it 'renders with no content' do
        rlp_tls_cert_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(rlp_tls_cert_pem).to include("")
      end
    end

    context "when a cert is provided" do
      it 'renders with the cert as content' do
        rlp_tls_cert_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com',
                'tls' => {
                  'cert' => 'cert'
                },
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(rlp_tls_cert_pem).to include("cert")
      end
    end
  end

  describe 'config/rlp_tls_key.pem template' do
    let(:template) { job.template('config/rlp_tls_key.pem') }

    context "when no key is provided" do
      it 'renders with no content' do
        rlp_tls_key_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com'
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(rlp_tls_key_pem).to include("")
      end
    end

    context "when a key is provided" do
      it 'renders with the key as content' do
        rlp_tls_key_pem = template.render({
            'firehose_exporter' => {
              'logging' => {
                'url' => 'http://api.yoursystemdomain.here.com',
                'tls' => {
                  'key' => 'key'
                },
              },
              'metrics' => {
                'environment' => 'test'
              }
            }
          })
        expect(rlp_tls_key_pem).to include("key")
      end
    end
  end
end
