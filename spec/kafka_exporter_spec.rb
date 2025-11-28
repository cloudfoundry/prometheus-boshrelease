require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'kafka_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('kafka_exporter') }

  describe 'bin/kafka_exporter_ctl template' do
    let(:template) { job.template('bin/kafka_exporter_ctl') }

    context "when only web specs are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "web" => {
              "listen_address" => ":9308",
              "telemetry_path" => "/metrics"
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--web.listen-address=:9308')
        expect(kafka_exporter_ctl).to include('--web.telemetry-path=/metrics')
      end
    end

    context "when topic and group filters are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "topic" => {
              "filter" => "^test.*",
              "exclude" => "^internal.*"
            },
            "group" => {
              "filter" => "^consumer.*",
              "exclude" => "^system.*"
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--topic.filter=^test.*')
        expect(kafka_exporter_ctl).to include('--topic.exclude=^internal.*')
        expect(kafka_exporter_ctl).to include('--group.filter=^consumer.*')
        expect(kafka_exporter_ctl).to include('--group.exclude=^system.*')
      end
    end

    context "when kafka servers are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "kafka" => {
              "servers" => ["kafka1:9092", "kafka2:9092", "kafka3:9092"]
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--kafka.server=kafka1:9092')
        expect(kafka_exporter_ctl).to include('--kafka.server=kafka2:9092')
        expect(kafka_exporter_ctl).to include('--kafka.server=kafka3:9092')
      end
    end

    context "when SASL is enabled" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "sasl" => {
              "enabled" => true,
              "handshake" => true,
              "username" => "kafka_user",
              "password" => "kafka_pass",
              "mechanism" => "SCRAM-SHA-512"
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--sasl.enabled')
        expect(kafka_exporter_ctl).to include('--sasl.username=kafka_user')
        expect(kafka_exporter_ctl).to include('--sasl.password=kafka_pass')
        expect(kafka_exporter_ctl).to include('--sasl.mechanism=SCRAM-SHA-512')
      end
    end

    context "when SASL handshake is disabled" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "sasl" => {
              "enabled" => true,
              "handshake" => false
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--no-sasl.handshake')
      end
    end

    context "when SASL AWS IAM is configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "sasl" => {
              "enabled" => true,
              "mechanism" => "awsiam",
              "aws_region" => "us-east-1"
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--sasl.aws-region=us-east-1')
        expect(kafka_exporter_ctl).to include('--sasl.mechanism=awsiam')
      end
    end

    context "when Kerberos authentication is configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "sasl" => {
              "enabled" => true,
              "mechanism" => "gssapi",
              "service_name" => "kafka",
              "kerberos_config_path" => "/etc/krb5.conf",
              "realm" => "EXAMPLE.COM",
              "kerberos_auth_type" => "keytabAuth",
              "keytab_path" => "/etc/security/keytabs/kafka.keytab",
              "disable_pa_fx_fast" => true
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--sasl.service-name=kafka')
        expect(kafka_exporter_ctl).to include('--sasl.kerberos-config-path=/etc/krb5.conf')
        expect(kafka_exporter_ctl).to include('--sasl.realm=EXAMPLE.COM')
        expect(kafka_exporter_ctl).to include('--sasl.kerberos-auth-type=keytabAuth')
        expect(kafka_exporter_ctl).to include('--sasl.keytab-path=/etc/security/keytabs/kafka.keytab')
        expect(kafka_exporter_ctl).to include('--sasl.disable-PA-FX-FAST')
      end
    end

    context "when TLS for Kafka connection is enabled" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "tls" => {
              "enabled" => true,
              "server_name" => "kafka.example.com",
              "ca_file" => "/var/vcap/jobs/kafka_exporter/config/ca.crt",
              "cert_file" => "/var/vcap/jobs/kafka_exporter/config/client.crt",
              "key_file" => "/var/vcap/jobs/kafka_exporter/config/client.key",
              "insecure_skip_tls_verify" => false
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--tls.enabled')
        expect(kafka_exporter_ctl).to include('--tls.server-name=kafka.example.com')
        expect(kafka_exporter_ctl).to include('--tls.ca-file=/var/vcap/jobs/kafka_exporter/config/ca.crt')
        expect(kafka_exporter_ctl).to include('--tls.cert-file=/var/vcap/jobs/kafka_exporter/config/client.crt')
        expect(kafka_exporter_ctl).to include('--tls.key-file=/var/vcap/jobs/kafka_exporter/config/client.key')
      end
    end

    context "when TLS insecure skip verify is enabled" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "tls" => {
              "enabled" => true,
              "insecure_skip_tls_verify" => true
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--tls.insecure-skip-tls-verify')
      end
    end

    context "when TLS for web server is enabled" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "server" => {
              "tls" => {
                "enabled" => true,
                "mutual_auth_enabled" => true,
                "ca_file" => "/var/vcap/jobs/kafka_exporter/config/server-ca.crt",
                "cert_file" => "/var/vcap/jobs/kafka_exporter/config/server.crt",
                "key_file" => "/var/vcap/jobs/kafka_exporter/config/server.key"
              }
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--server.tls.enabled')
        expect(kafka_exporter_ctl).to include('--server.tls.mutual-auth-enabled')
        expect(kafka_exporter_ctl).to include('--server.tls.ca-file=/var/vcap/jobs/kafka_exporter/config/server-ca.crt')
        expect(kafka_exporter_ctl).to include('--server.tls.cert-file=/var/vcap/jobs/kafka_exporter/config/server.crt')
        expect(kafka_exporter_ctl).to include('--server.tls.key-file=/var/vcap/jobs/kafka_exporter/config/server.key')
      end
    end

    context "when kafka version and labels are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "kafka" => {
              "version" => "3.0.0",
              "labels" => "prod-cluster",
              "allow_auto_topic_creation" => true
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--kafka.version=3.0.0')
        expect(kafka_exporter_ctl).to include('--kafka.labels=prod-cluster')
        expect(kafka_exporter_ctl).to include('--kafka.allow-auto-topic-creation')
      end
    end

    context "when zookeeper is configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "use" => {
              "consumelag" => {
                "zookeeper" => true
              }
            },
            "zookeeper" => {
              "servers" => ["zk1:2181", "zk2:2181", "zk3:2181"]
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--use.consumelag.zookeeper')
        expect(kafka_exporter_ctl).to include('--zookeeper.server=zk1:2181')
        expect(kafka_exporter_ctl).to include('--zookeeper.server=zk2:2181')
        expect(kafka_exporter_ctl).to include('--zookeeper.server=zk3:2181')
      end
    end

    context "when metadata refresh and offset settings are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "refresh" => {
              "metadata" => "60s"
            },
            "offset" => {
              "show_all" => false
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--refresh.metadata=60s')
        expect(kafka_exporter_ctl).to include('--no-offset.show-all')
      end
    end

    context "when concurrent mode and topic workers are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "concurrent" => {
              "enable" => true
            },
            "topic" => {
              "workers" => 200
            }
          }
        })
        expect(kafka_exporter_ctl).to include('--concurrent.enable')
        expect(kafka_exporter_ctl).to include('--topic.workers=200')
      end
    end

    context "when logging settings are configured" do
      it 'renders values' do
        kafka_exporter_ctl = template.render({
          "kafka_exporter" => {
            "log" => {
              "enable_sarama" => true,
              "level" => "debug",
              "format" => "json"
            },
            "verbosity" => 2
          }
        })
        expect(kafka_exporter_ctl).to include('--log.enable-sarama')
        expect(kafka_exporter_ctl).to include('--log.level=debug')
        expect(kafka_exporter_ctl).to include('--log.format=json')
        expect(kafka_exporter_ctl).to include('--verbosity=2')
      end
    end
  end
end
