require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'mongodb_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('mongodb_exporter') }

  describe 'bin/mongodb_exporter_ctl script' do
    let(:template) { job.template('bin/mongodb_exporter_ctl') }

    context "when only mandatory specs are configured" do
      it 'renders with only required parameters' do
        ctl_script = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            }
          }
        })
        
        # Should include the mandatory mongodb URI
        expect(ctl_script).to include('--mongodb.uri="mongodb://localhost:27017"')
        
        # Should not include optional parameters
        expect(ctl_script).not_to include('--mongodb.user=')
        expect(ctl_script).not_to include('--mongodb.password=')
        expect(ctl_script).not_to include('--mongodb.collstats-colls=')
        expect(ctl_script).not_to include('--mongodb.indexstats-colls=')
        expect(ctl_script).not_to include('--mongodb.global-conn-pool')
        expect(ctl_script).not_to include('--mongodb.direct-connect')
        expect(ctl_script).not_to include('--web.listen-address=')
        expect(ctl_script).not_to include('--web.telemetry-path=')
        expect(ctl_script).not_to include('--web.config=')
        expect(ctl_script).not_to include('--web.timeout-offset=')
        expect(ctl_script).not_to include('--log.level=')
      end
    end

    context "when web configuration properties are provided" do
      it 'renders with custom web configuration' do
        ctl_script = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            },
            'web' => {
              'listen-address' => '0.0.0.0:9090',
              'telemetry-path' => '/mongodb_metrics',
              'timeout-offset' => '5'
            }
          }
        })
        expect(ctl_script).to include('--web.listen-address="0.0.0.0:9090"')
        expect(ctl_script).to include('--web.telemetry-path="/mongodb_metrics"')
        expect(ctl_script).to include('--web.timeout-offset="5"')
      end
    end

    context "when web configuration properties are not provided" do
      it 'does not include web configuration flags' do
        ctl_script = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            }
          }
        })
        expect(ctl_script).not_to include('--web.listen-address=')
        expect(ctl_script).not_to include('--web.telemetry-path=')
        expect(ctl_script).not_to include('--web.timeout-offset=')
      end
    end

    context "when log level is provided" do
      it 'renders with custom log level' do
        ctl_script = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            },
            'log' => {
              'level' => 'debug'
            }
          }
        })
        expect(ctl_script).to include('--log.level="debug"')
      end
    end
  end

  describe 'config/web_tls_key.pem template' do
    let(:template) { job.template('config/web_tls_key.pem') }

    context "when no key is provided" do
      it 'renders with no content' do
        web_tls_key_pem = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            }
          }
        })
        expect(web_tls_key_pem).to eq("")
      end
    end

    context "when a key is provided" do
      it 'renders with the key as content' do
        web_tls_key_pem = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            },
            'web' => {
              'tls_private_key' => 'test-private-key'
            }
          }
        })
        expect(web_tls_key_pem).to eq("test-private-key")
      end
    end
  end

  describe 'config/web_tls_cert.pem template' do
    let(:template) { job.template('config/web_tls_cert.pem') }

    context "when no cert is provided" do
      it 'renders with no content' do
        web_tls_cert_pem = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            }
          }
        })
        expect(web_tls_cert_pem).to eq("")
      end
    end

    context "when a cert is provided" do
      it 'renders with the cert as content' do
        web_tls_cert_pem = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            },
            'web' => {
              'tls_cert' => 'test-cert'
            }
          }
        })
        expect(web_tls_cert_pem).to eq("test-cert")
      end
    end
  end

  describe 'config/web_tls_client_ca.pem template' do
    let(:template) { job.template('config/web_tls_client_ca.pem') }

    context "when no client CA is provided" do
      it 'renders with no content' do
        web_tls_client_ca_pem = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            }
          }
        })
        expect(web_tls_client_ca_pem).to eq("")
      end
    end

    context "when a client CA is provided" do
      it 'renders with the client CA as content' do
        web_tls_client_ca_pem = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            },
            'web' => {
              'tls_client_ca' => 'test-client-ca',
              'tls_client_auth_type' => 'RequireAndVerifyClientCert'
            }
          }
        })
        expect(web_tls_client_ca_pem).to eq("test-client-ca")
      end
    end
  end

  describe 'config/web.config.yml template' do
    let(:template) { job.template('config/web.config.yml') }

    context "when no TLS configuration is provided" do
      it 'renders with basic TLS config' do
        web_config_yml = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            }
          }
        })
        parsed_yaml = YAML.safe_load(web_config_yml)
        expect(parsed_yaml).to have_key('tls_server_config')
        expect(parsed_yaml['tls_server_config']['cert_file']).to eq('/var/vcap/jobs/mongodb_exporter/config/web_tls_cert.pem')
        expect(parsed_yaml['tls_server_config']['key_file']).to eq('/var/vcap/jobs/mongodb_exporter/config/web_tls_key.pem')
        expect(parsed_yaml['tls_server_config']).not_to have_key('client_ca_file')
        expect(parsed_yaml['tls_server_config']).not_to have_key('client_auth_type')
      end
    end

    context "when TLS client CA is provided" do
      it 'renders with client authentication configuration' do
        web_config_yml = template.render({
          'mongodb_exporter' => {
            'mongodb' => {
              'uri' => 'mongodb://localhost:27017'
            },
            'web' => {
              'tls_client_ca' => 'test-client-ca',
              'tls_client_auth_type' => 'RequireAndVerifyClientCert'
            }
          }
        })
        parsed_yaml = YAML.safe_load(web_config_yml)
        expect(parsed_yaml).to have_key('tls_server_config')
        expect(parsed_yaml['tls_server_config']['client_ca_file']).to eq('/var/vcap/jobs/mongodb_exporter/config/web_tls_client_ca.pem')
        expect(parsed_yaml['tls_server_config']['client_auth_type']).to eq('RequireAndVerifyClientCert')
      end
    end
  end
end
