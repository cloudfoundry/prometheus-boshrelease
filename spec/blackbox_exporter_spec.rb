require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'blackbox_exporter job'do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('blackbox_exporter') }

  describe 'bin/blackbox_exporter_ctl template'do
    let(:template) { job.template('bin/blackbox_exporter_ctl') }

    context "when only .env specs are configured" do
      it 'renders values'do
        blackbox_exporter_ctl = template.render({
        "env" => {
          "http_proxy" => "http://http-proxy:8080",
          "https_proxy" => "https://https-proxy:8080",
          "no_proxy" => "127.0.0.1"
          }
        })
        expect(blackbox_exporter_ctl).to include('export HTTP_PROXY="http://http-proxy:8080"')
        expect(blackbox_exporter_ctl).to include('export HTTPS_PROXY="https://https-proxy:8080"')
        expect(blackbox_exporter_ctl).to include('export NO_PROXY="127.0.0.1"')
        expect(blackbox_exporter_ctl).to include('export http_proxy="http://http-proxy:8080"')
        expect(blackbox_exporter_ctl).to include('export https_proxy="https://https-proxy:8080"')
        expect(blackbox_exporter_ctl).to include('export no_proxy="127.0.0.1"')
      end
    end

    context "when only .web specs are configured" do
      it 'renders values'do
        blackbox_exporter_ctl = template.render({
        "blackbox_exporter" => {
          "web" => {
            "port" => "8080",
            "route_prefix" => "internal",
            "external_url" => "https://blackbox_exporter"
            }
          }
        })
        expect(blackbox_exporter_ctl).to include('--web.listen-address=":8080"')
        expect(blackbox_exporter_ctl).to include('--web.route-prefix="internal"')
        expect(blackbox_exporter_ctl).to include('--web.external-url="https://blackbox_exporter"')
      end
    end

    context "when only log specs are configured" do
      it 'renders values'do
        blackbox_exporter_ctl = template.render({
          "blackbox_exporter" => {
            "log_level" => "debug",
            "log_format" => "json"
          }
        })
        expect(blackbox_exporter_ctl).to include('--log.level="debug"')
        expect(blackbox_exporter_ctl).to include('--log.format="json"')
      end
    end

    context "when only misc specs are configured" do
      it 'renders values'do
        blackbox_exporter_ctl = template.render({
          "blackbox_exporter" => {
            "history_limit" => 100,
            "timeout_offset" => 10
            }
        })
        expect(blackbox_exporter_ctl).to include('--history.limit="100"')
        expect(blackbox_exporter_ctl).to include('--timeout-offset="10"')
      end
    end
  end

  describe 'config/blackbox.yml template'do
    let(:template) { job.template('config/blackbox.yml') }

    context "when only mandatory specs are configured" do
      it 'renders with default values'do
        blackbox_exporter_yml = template.render({
          "blackbox_exporter" => {
            "config" => {
              "modules" => {
                "http" => {
                  "prober" => "http",
                  "timeout" => "5s",
                  "http" => {
                    "tls_config" => {
                      "insecure_skip_verify" => true
                    }
                  }
                }
              }
            }
          }
        })
        expect(blackbox_exporter_yml).to include('prober: http')
        expect(blackbox_exporter_yml).to include('timeout: 5s')
        expect(blackbox_exporter_yml).to include('insecure_skip_verify: true')
      end
    end
  end
end
