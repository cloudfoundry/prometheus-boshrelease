require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'alertmanager job'do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('alertmanager') }
  let(:alertmanager_link) do
    Bosh::Template::Test::Link.new(
      name: 'alertmanager',
      instances: [Bosh::Template::Test::LinkInstance.new()]
    )
  end

  describe 'bin/alertmanager_ctl template'do
    let(:template) { job.template('bin/alertmanager_ctl') }

    context "when only mandatory specs are configured" do
      it 'renders with default values'do
        alertmanager_ctl = template.render({}, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('--cluster.listen-address=192.168.0.0:9094')
        expect(alertmanager_ctl).to include('--cluster.peer="link.instance.address.com:9094"')
        expect(alertmanager_ctl).to include('--web.listen-address=":9093"')
      end
    end

    context "when only .alerts specs are configured" do
      it 'renders values'do
        alertmanager_ctl = template.render({
          "alertmanager" => {
            "alerts" => {
              "gc_interval" => "20m"
            }
          }
        }, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('--alerts.gc-interval="20m"')
      end
    end

    context "when only .data specs are configured" do
      it 'renders values'do
        alertmanager_ctl = template.render({
          "alertmanager" => {
            "data" => {
              "retention" => "120h"
            }
          }
        }, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('--data.retention="120h"')
      end
    end

    context "when only log specs are configured" do
      it 'renders values'do
        alertmanager_ctl = template.render({
          "alertmanager" => {
            "log_level" => "debug",
            "log_format" => "json"
          }
        }, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('--log.level="debug"')
        expect(alertmanager_ctl).to include('--log.format="json"')
      end
    end

    context "when only .cluster specs are configured" do
      it 'renders values'do
        alertmanager_ctl = template.render({
          "alertmanager" => {
            "cluster" => {
              "listen_address" => "127.0.0.1",
              "advertise_address" => "CLUSTER.ADVERTISE-ADDRESS",
              "gossip_interval" => "200ms",
              "peer_timeout" => "15s",
              "enabled" => true,
              "port" => "7777",
              "probe_interval" => "1s",
              "probe_timeout" => "500ms",
              "pushpull_interval" => "1m0s",
              "reconnect_interval" => "10s",
              "reconnect_timeout" => "6h0m0s",
              "settle_timeout" => "1m0s",
              "tcp_timeout" => "10s",
            }
          }
        }, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('--cluster.listen-address=127.0.0.1:7777')
        expect(alertmanager_ctl).to include('--cluster.advertise-address="CLUSTER.ADVERTISE-ADDRESS:7777"')
        expect(alertmanager_ctl).to include('--cluster.gossip-interval="200ms"')
        expect(alertmanager_ctl).to include('--cluster.peer-timeout="15s"')
        expect(alertmanager_ctl).to include('--cluster.peer="link.instance.address.com:7777"')
        expect(alertmanager_ctl).to include('--cluster.probe-interval="1s"')
        expect(alertmanager_ctl).to include('--cluster.probe-timeout="500ms"')
        expect(alertmanager_ctl).to include('--cluster.pushpull-interval="1m0s"')
        expect(alertmanager_ctl).to include('--cluster.reconnect-interval="10s"')
        expect(alertmanager_ctl).to include('--cluster.reconnect-timeout="6h0m0s"')
        expect(alertmanager_ctl).to include('--cluster.settle-timeout="1m0s"')
        expect(alertmanager_ctl).to include('--cluster.tcp-timeout="10s"')
      end
    end

    context "when only .web specs are configured" do
      it 'renders values'do
        alertmanager_ctl = template.render({
          "alertmanager" => {
            "web" => {
              "external_url" => "127.0.0.1",
              "get_concurrency" => "0",
              "listen_address" => "localhost",
              "port" => "7777",
              "route_prefix" => "/alert",
              "timeout" => "0"
            }
          }
        }, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('--web.external-url="127.0.0.1"')
        expect(alertmanager_ctl).to include('--web.get-concurrency="0"')
        expect(alertmanager_ctl).to include('--web.listen-address="localhost:7777"')
        expect(alertmanager_ctl).to include('--web.route-prefix="/alert"')
        expect(alertmanager_ctl).to include('--web.timeout="0"')
      end
    end

    context "when only .env specs are configured" do
      it 'renders values'do
        alertmanager_ctl = template.render({
        "env" => {
          "http_proxy" => "http://http-proxy:8080",
          "https_proxy" => "https://https-proxy:8080",
          "no_proxy" => "127.0.0.1"
          }
        }, consumes: [alertmanager_link])
        expect(alertmanager_ctl).to include('export HTTP_PROXY="http://http-proxy:8080"')
        expect(alertmanager_ctl).to include('export HTTPS_PROXY="https://https-proxy:8080"')
        expect(alertmanager_ctl).to include('export NO_PROXY="127.0.0.1"')
        expect(alertmanager_ctl).to include('export http_proxy="http://http-proxy:8080"')
        expect(alertmanager_ctl).to include('export https_proxy="https://https-proxy:8080"')
        expect(alertmanager_ctl).to include('export no_proxy="127.0.0.1"')
      end
    end
  end

  describe 'bin/pre-start template'do
    let(:template) { job.template('bin/pre-start') }

    context "when only mandatory specs are configured" do
      it 'renders with default values'do
        pre_start = template.render({})
        expect(pre_start).not_to include('# Send a test alert hourly')
        expect(pre_start).not_to include('# Send a test alert daily')
        expect(pre_start).not_to include('# Send a test alert weekly')
      end
    end

    context "when only .test_alert specs are configured" do
      it 'renders with test_alert values'do
        pre_start = template.render({
          "alertmanager" => {
            "test_alert" => {
              "hourly" => true,
              "daily" => true,
              "weekly" => true
            }
          }
        })
        expect(pre_start).to include('# Send a test alert hourly')
        expect(pre_start).to include('# Send a test alert daily')
        expect(pre_start).to include('# Send a test alert weekly')
      end
    end
  end

  describe 'bin/alertmanager_test template'do
    let(:template) { job.template('bin/alertmanager_test') }

    context "when only mandatory specs are configured" do
      it 'renders with default values'do
        alertmanager_test = template.render({})
        expect(alertmanager_test).to include('192.168.0.0:9093/api/v2/alerts')
      end
    end
  end

  describe 'config/alertmanager.yml template'do
    let(:template) { job.template('config/alertmanager.yml') }

    context "when only mandatory specs are configured" do
      it 'renders with default values'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
      end
    end

    context "when only .resolve_timeout specs are configured" do
      it 'renders with .resolve_timeout configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "resolve_timeout" => "60s",
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('resolve_timeout: 60s')
      end
    end

    context "when only .smtp specs are configured" do
      it 'renders with .smtp configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "smtp" => {
              "from" => "smtp_from",
              "smarthost" => "smtp_smarthost",
              "hello" => "smtp_hello",
              "auth_username" => "smtp_auth_username",
              "auth_password" => "smtp_auth_password", 
              "auth_secret" => "smtp_auth_secret", 
              "auth_identity" => "smtp_auth_identity",
              "require_tls" => "smtp_require_tls" 
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('smtp_from: smtp_from')
        expect(alertmanager_yml).to include('smtp_smarthost: smtp_smarthost')
        expect(alertmanager_yml).to include('smtp_hello: smtp_hello')
        expect(alertmanager_yml).to include('smtp_auth_username: smtp_auth_username')
        expect(alertmanager_yml).to include('smtp_auth_password: smtp_auth_password')
        expect(alertmanager_yml).to include('smtp_auth_secret: smtp_auth_secret')
        expect(alertmanager_yml).to include('smtp_auth_identity: smtp_auth_identity')
        expect(alertmanager_yml).to include('smtp_require_tls: smtp_require_tls')
      end
    end

    context "when only .slack specs are configured" do
      it 'renders with .slack configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "slack" => {
              "api_url" => "slack_api_url"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('slack_api_url: slack_api_url')
      end
    end

    context "when only .victorops specs are configured" do
      it 'renders with .victorops configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "victorops" => {
              "api_key" => "victorops_api_key",
              "api_url" => "victorops_api_url"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('victorops_api_key: victorops_api_key')
        expect(alertmanager_yml).to include('victorops_api_url: victorops_api_url')
      end
    end

    context "when only .pagerduty specs are configured" do
      it 'renders with .pagerduty configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "pagerduty" => {
              "url" => "pagerduty_url"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('pagerduty_url: pagerduty_url')
      end
    end

    context "when only .wechat specs are configured" do
      it 'renders with .wechat configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "wechat" => {
              "api_secret" => "wechat_api_secret",
              "api_corp_id" => "wechat_api_corp_id",
              "api_url" => "wechat_api_url"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('wechat_api_secret: wechat_api_secret')
        expect(alertmanager_yml).to include('wechat_api_corp_id: wechat_api_corp_id')
        expect(alertmanager_yml).to include('wechat_api_url: wechat_api_url')
      end
    end

    context "when only .http_config specs are configured" do
      it 'renders with .http_config configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "http_config" => {
              "config_key" => "config_value"
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('http_config: {"config_key":"config_value"}')
      end
    end

    context "when only .route specs are configured" do
      it 'renders with .route configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver",
              "continue" => true,
              "group_by" => "group",
              "group_wait" => "5s",
              "group_interval" => "60s",
              "repeat_interval" => "120s",
              "routes" => [{
                "receiver" => "team-X-mails"
              }]
            }
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('continue: true')
        expect(alertmanager_yml).to include('group_by: group')
        expect(alertmanager_yml).to include('group_wait: 5s')
        expect(alertmanager_yml).to include('group_interval: 60s')
        expect(alertmanager_yml).to include('repeat_interval: 120s')
        expect(alertmanager_yml).to include('routes: [{"receiver":"team-X-mails"}]')
      end
    end

    context "when only .inhibit_rules specs are configured" do
      it 'renders with .inhibit_rules configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "inhibit_rules" => [
              {
                "source_matchers" => ["severity='critical'"],
                "target_matchers" => ["severity='warning'"],
                "equal" => ["alertname","cluster","service"]
              }
            ]
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include("inhibit_rules: [{\"source_matchers\":[\"severity='critical'\"],\"target_matchers\":[\"severity='warning'\"],\"equal\":[\"alertname\",\"cluster\",\"service\"]}]")
      end
    end

    context "when only .time_intervals specs are configured" do
      it 'renders with .time_intervals configuration'do
        alertmanager_yml = template.render({
          "alertmanager" => {
            "receivers" => [
              { "name" => "default_receiver",
                "email_configs" => [
                  { "to" => "default_mail" }
                ]
              }
            ],
            "route" => {
              "receiver" => "default_receiver"
            },
            "time_intervals" => [
              {
                "name" => "offday",
                "time_intervals" => [
                  "times" => [
                    "start_time" => "HH:MM",
                    "end_time" => "HH:MM"
                  ]
                ]
              }
            ]
          }
        })
        expect(alertmanager_yml).to include('receiver: default_receiver')
        expect(alertmanager_yml).to include('receivers: [{"name":"default_receiver","email_configs":[{"to":"default_mail"}]}]')
        expect(alertmanager_yml).to include('time_intervals: [{"name":"offday","time_intervals":[{"times":[{"start_time":"HH:MM","end_time":"HH:MM"}]}]}]')
      end
    end
  end
end
