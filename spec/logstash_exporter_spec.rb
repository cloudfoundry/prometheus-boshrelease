require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'logstash_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('logstash_exporter') }

  describe 'bin/logstash_exporter_ctl template' do
    let(:template) { job.template('bin/logstash_exporter_ctl') }

    context "when default specs are used" do
      it 'renders with default values' do
        logstash_exporter_ctl = template.render({})
        expect(logstash_exporter_ctl).to include('--logstash.host="localhost"')
        expect(logstash_exporter_ctl).to include('--logstash.port=9600')
        expect(logstash_exporter_ctl).to include('--logstash.timeout="5s"')
        expect(logstash_exporter_ctl).to include('--web.listen-address=":9304"')
        expect(logstash_exporter_ctl).to include('--web.telemetry-path="/metrics"')
      end
    end

    context "when custom host and port are configured" do
      it 'renders with custom values' do
        logstash_exporter_ctl = template.render({
          "logstash_exporter" => {
            "logstash" => {
              "host" => "logstash.example.com",
              "port" => 9601
            }
          }
        })
        expect(logstash_exporter_ctl).to include('--logstash.host="logstash.example.com"')
        expect(logstash_exporter_ctl).to include('--logstash.port=9601')
        expect(logstash_exporter_ctl).to include('--logstash.timeout="5s"')
        expect(logstash_exporter_ctl).to include('--web.listen-address=":9304"')
        expect(logstash_exporter_ctl).to include('--web.telemetry-path="/metrics"')
      end
    end

    context "when custom timeout is configured" do
      it 'renders with custom timeout' do
        logstash_exporter_ctl = template.render({
          "logstash_exporter" => {
            "logstash" => {
              "timeout" => "10s"
            }
          }
        })
        expect(logstash_exporter_ctl).to include('--logstash.host="localhost"')
        expect(logstash_exporter_ctl).to include('--logstash.port=9600')
        expect(logstash_exporter_ctl).to include('--logstash.timeout="10s"')
      end
    end

    context "when custom web settings are configured" do
      it 'renders with custom web settings' do
        logstash_exporter_ctl = template.render({
          "logstash_exporter" => {
            "web" => {
              "listen-address" => ":8080",
              "telemetry-path" => "/logstash_metrics"
            }
          }
        })
        expect(logstash_exporter_ctl).to include('--web.listen-address=":8080"')
        expect(logstash_exporter_ctl).to include('--web.telemetry-path="/logstash_metrics"')
      end
    end

    context "when all settings are customized" do
      it 'renders all custom values' do
        logstash_exporter_ctl = template.render({
          "logstash_exporter" => {
            "logstash" => {
              "host" => "logstash.internal",
              "port" => 9700,
              "timeout" => "15s"
            },
            "web" => {
              "listen-address" => ":9999",
              "telemetry-path" => "/custom_metrics"
            }
          }
        })
        expect(logstash_exporter_ctl).to include('--logstash.host="logstash.internal"')
        expect(logstash_exporter_ctl).to include('--logstash.port=9700')
        expect(logstash_exporter_ctl).to include('--logstash.timeout="15s"')
        expect(logstash_exporter_ctl).to include('--web.listen-address=":9999"')
        expect(logstash_exporter_ctl).to include('--web.telemetry-path="/custom_metrics"')
      end
    end
  end
end