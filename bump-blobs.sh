# /bin/bash

# sudo apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC sudo apt install jq curl git sed nodejs make wget unzip -y
mkdir /tmp/cache /tmp/prometheus-blobs

export BOSH_VERSION=7.6.1

## TODO add later again
# cd /tmp/cache && curl -sL https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 > bosh && chmod 777 bosh
cd /tmp/cache && curl -sL https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-darwin-arm64 > bosh && chmod 777 bosh

export LATEST_REDIS_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/oliver006/redis_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_REDIS_EXPORTER_DOWNLOAD_URL}
export LATEST_ALERTMANAGER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/alertmanager/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_ALERTMANAGER_DOWNLOAD_URL}
export LATEST_BLACKBOX_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/blackbox_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_BLACKBOX_EXPORTER_DOWNLOAD_URL}
export LATEST_BOSH_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/cloudfoundry/bosh_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_BOSH_EXPORTER_DOWNLOAD_URL}
export LATEST_BOSH_TSDB_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/bosh-prometheus/bosh_tsdb_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_BOSH_TSDB_EXPORTER_DOWNLOAD_URL}
export LATEST_COLLECTD_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/collectd_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_COLLECTD_EXPORTER_DOWNLOAD_URL}
export LATEST_CONSUL_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/consul_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_CONSUL_EXPORTER_DOWNLOAD_URL}
export LATEST_CREDHUB_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/orange-cloudfoundry/credhub_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux_amd64.tar.gz$')
echo ${LATEST_CREDHUB_EXPORTER_DOWNLOAD_URL}
export LATEST_CF_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/cloudfoundry/cf_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_CF_EXPORTER_DOWNLOAD_URL}
export LATEST_FIREHOSE_EXPORTER_DOWNLOAD_URL=$(curl -sL https://firehose-prometheus-ci-bot:${FIREHOSE_PROM_CI_BOT_TOKEN}@api.github.com/repos/cloudfoundry/firehose_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_FIREHOSE_EXPORTER_DOWNLOAD_URL}
export LATEST_ELASTICSEARCH_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus-community/elasticsearch_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_ELASTICSEARCH_EXPORTER_DOWNLOAD_URL}
export LATEST_GRAPHITE_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/graphite_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_GRAPHITE_EXPORTER_DOWNLOAD_URL}
#export LATEST_GRAFANA_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/grafana/grafana/releases/latest | jq -r '.tag_name' | sed 's/v//')
#echo ${LATEST_GRAFANA_VERSION}
#export LATEST_GRAFANA_DOWNLOAD_URL="https://dl.grafana.com/oss/release/grafana-${LATEST_GRAFANA_VERSION}.linux-amd64.tar.gz"
#echo ${LATEST_GRAFANA_DOWNLOAD_URL}
export LATEST_INFLUXDB_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/influxdb_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_INFLUXDB_EXPORTER_DOWNLOAD_URL}
export LATEST_INGESTOR_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/bosh-prometheus/ingestor_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_INGESTOR_EXPORTER_DOWNLOAD_URL}
export LATEST_MEMCACHED_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/memcached_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_MEMCACHED_EXPORTER_DOWNLOAD_URL}
export LATEST_MONGODB_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/percona/mongodb_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_MONGODB_EXPORTER_DOWNLOAD_URL}
export LATEST_MYSQLD_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/mysqld_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_MYSQLD_EXPORTER_DOWNLOAD_URL}
export LATEST_POSTGRES_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus-community/postgres_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_POSTGRES_EXPORTER_DOWNLOAD_URL}
#export LATEST_PROMETHEUS_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
#echo ${LATEST_PROMETHEUS_DOWNLOAD_URL}
export LATEST_PUSHGATEWAY_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/pushgateway/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_PUSHGATEWAY_DOWNLOAD_URL}
export LATEST_SHIELD_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/bosh-prometheus/shield_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_SHIELD_EXPORTER_DOWNLOAD_URL}
export LATEST_STACKDRIVER_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus-community/stackdriver_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_STACKDRIVER_EXPORTER_DOWNLOAD_URL}
export LATEST_STATSD_EXPORTER_DOWNLOAD_URL=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/statsd_exporter/releases/latest | jq -r '.assets[].browser_download_url' | grep 'linux-amd64.tar.gz$')
echo ${LATEST_STATSD_EXPORTER_DOWNLOAD_URL}


export LATEST_REDIS_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/oliver006/redis_exporter/releases/latest | jq -r '.tag_name')
echo ${LATEST_REDIS_EXPORTER_VERSION}
export LATEST_ALERTMANAGER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/alertmanager/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_ALERTMANAGER_VERSION}
export LATEST_BLACKBOX_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/blackbox_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_BLACKBOX_EXPORTER_VERSION}
export LATEST_BOSH_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/cloudfoundry/bosh_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_BOSH_EXPORTER_VERSION}
export LATEST_BOSH_TSDB_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/bosh-prometheus/bosh_tsdb_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_BOSH_TSDB_EXPORTER_VERSION}
export LATEST_COLLECTD_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/collectd_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_COLLECTD_EXPORTER_VERSION}
export LATEST_CONSUL_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/consul_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_CONSUL_EXPORTER_VERSION}
export LATEST_CREDHUB_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/orange-cloudfoundry/credhub_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_CREDHUB_EXPORTER_VERSION}
export LATEST_CF_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/cloudfoundry/cf_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_CF_EXPORTER_VERSION}
export LATEST_FIREHOSE_EXPORTER_VERSION=$(curl -sL https://firehose-prometheus-ci-bot:${FIREHOSE_PROM_CI_BOT_TOKEN}@api.github.com/repos/cloudfoundry/firehose_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_FIREHOSE_EXPORTER_VERSION}
export LATEST_ELASTICSEARCH_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus-community/elasticsearch_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_ELASTICSEARCH_EXPORTER_VERSION}
export LATEST_GRAPHITE_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/graphite_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_GRAPHITE_EXPORTER_VERSION}
export LATEST_INFLUXDB_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/influxdb_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_INFLUXDB_EXPORTER_VERSION}
export LATEST_INGESTOR_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/bosh-prometheus/ingestor_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_INGESTOR_EXPORTER_VERSION}
export LATEST_MEMCACHED_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/memcached_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_MEMCACHED_EXPORTER_VERSION}
export LATEST_MONGODB_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/percona/mongodb_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_MONGODB_EXPORTER_VERSION}
export LATEST_MYSQLD_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/mysqld_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_MYSQLD_EXPORTER_VERSION}
export LATEST_POSTGRES_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus-community/postgres_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_POSTGRES_EXPORTER_VERSION}
#export LATEST_PROMETHEUS_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/prometheus/releases/latest | jq -r '.tag_name' | sed 's/v//')
#echo ${LATEST_PROMETHEUS_VERSION}
export LATEST_PUSHGATEWAY_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/pushgateway/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_PUSHGATEWAY_VERSION}
export LATEST_SHIELD_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/bosh-prometheus/shield_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_SHIELD_EXPORTER_VERSION}
export LATEST_STACKDRIVER_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus-community/stackdriver_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_STACKDRIVER_EXPORTER_VERSION}
export LATEST_STATSD_EXPORTER_VERSION=$(curl -sL https://cf-prometheus-ci-bot:${CF_PROM_CI_BOT_TOKEN}@api.github.com/repos/prometheus/statsd_exporter/releases/latest | jq -r '.tag_name' | sed 's/v//')
echo ${LATEST_STATSD_EXPORTER_VERSION}


# Switch to Prometheus Repo 
# TODO: Adjust
cd $HOME/Documents/prometheus-boshrelease

# do we need this?
# git config --global --add safe.directory /__w/loki-boshrelease/loki-boshrelease

export USED_REDIS_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "redis_exporter-v[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_REDIS_EXPORTER_VERSION}
export USED_ALERTMANAGER_VERSION=$(cat config/blobs.yml | egrep -o "alertmanager-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_ALERTMANAGER_VERSION}
export USED_BLACKBOX_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "blackbox_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_BLACKBOX_EXPORTER_VERSION}
export USED_BOSH_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "bosh_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_BOSH_EXPORTER_VERSION}
export USED_BOSH_TSDB_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "bosh_tsdb_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_BOSH_TSDB_EXPORTER_VERSION}
export USED_COLLECTD_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "collectd_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_COLLECTD_EXPORTER_VERSION}
export USED_CONSUL_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "consul_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_CONSUL_EXPORTER_VERSION}
export USED_CREDHUB_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "credhub_exporter_[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "_" -f 3)
echo ${USED_CREDHUB_EXPORTER_VERSION}
export USED_CF_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "cf_exporter_[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "_" -f 3)
echo ${USED_CF_EXPORTER_VERSION}
export USED_FIREHOSE_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "firehose_exporter_[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "_" -f 3)
echo ${USED_FIREHOSE_EXPORTER_VERSION}
export USED_ELASTICSEARCH_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "elasticsearch_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_ELASTICSEARCH_EXPORTER_VERSION}
export USED_GRAPHITE_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "graphite_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_GRAPHITE_EXPORTER_VERSION}
#export USED_GRAFANA_VERSION=$(cat config/blobs.yml | egrep -o "grafana-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+(\+security-[[:digit:]]+)*")
#echo ${USED_GRAFANA_VERSION}
export USED_INFLUXDB_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "influxdb_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_INFLUXDB_EXPORTER_VERSION}
export USED_INGESTOR_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "ingestor_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_INGESTOR_EXPORTER_VERSION}
export USED_MEMCACHED_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "memcached_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_MEMCACHED_EXPORTER_VERSION}
export USED_MONGODB_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "mongodb_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_MONGODB_EXPORTER_VERSION}
export USED_MYSQLD_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "mysqld_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_MYSQLD_EXPORTER_VERSION}
export USED_POSTGRES_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "postgres_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_POSTGRES_EXPORTER_VERSION}
#export USED_PROMETHEUS_VERSION=$(cat config/blobs.yml | egrep -o "prometheus-2.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
#echo ${USED_PROMETHEUS_VERSION}
export USED_PUSHGATEWAY_VERSION=$(cat config/blobs.yml | egrep -o "pushgateway-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_PUSHGATEWAY_VERSION}
export USED_SHIELD_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "shield_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_SHIELD_EXPORTER_VERSION}
export USED_STACKDRIVER_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "stackdriver_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_STACKDRIVER_EXPORTER_VERSION}
export USED_STATSD_EXPORTER_VERSION=$(cat config/blobs.yml | egrep -o "statsd_exporter-[[:digit:]]+.[[:digit:]]+.[[:digit:]]+" | cut -d "-" -f 2)
echo ${USED_STATSD_EXPORTER_VERSION}

# do we need this?
# rm config/blobs.yml 2> /dev/null && touch config/blobs.yml

touch bumped_versions.txt

if [[ $LATEST_REDIS_EXPORTER_VERSION != $USED_REDIS_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_REDIS_EXPORTER_DOWNLOAD_URL -o /tmp/cache/redis_exporter-$LATEST_REDIS_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/redis_exporter-$LATEST_REDIS_EXPORTER_VERSION.linux-amd64.tar.gz redis_exporter/redis_exporter-$LATEST_REDIS_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob redis_exporter/redis_exporter-$USED_REDIS_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Redis-Exporter bumped to ${LATEST_REDIS_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_ALERTMANAGER_VERSION != $USED_ALERTMANAGER_VERSION ]]; then
  curl -sL $LATEST_ALERTMANAGER_DOWNLOAD_URL -o /tmp/cache/alertmanager-$LATEST_ALERTMANAGER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/alertmanager-$LATEST_ALERTMANAGER_VERSION.linux-amd64.tar.gz alertmanager/alertmanager-$LATEST_ALERTMANAGER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob alertmanager/alertmanager-$USED_ALERTMANAGER_VERSION.linux-amd64.tar.gz
  echo "Alertmanager bumped to ${LATEST_ALERTMANAGER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_BLACKBOX_EXPORTER_VERSION != $USED_BLACKBOX_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_BLACKBOX_EXPORTER_DOWNLOAD_URL -o /tmp/cache/blackbox_exporter-$LATEST_BLACKBOX_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/blackbox_exporter-$LATEST_BLACKBOX_EXPORTER_VERSION.linux-amd64.tar.gz blackbox_exporter/blackbox_exporter-$LATEST_BLACKBOX_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob blackbox_exporter/blackbox_exporter-$USED_BLACKBOX_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Blackbox-Exporter bumped to ${LATEST_BLACKBOX_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_BOSH_EXPORTER_VERSION != $USED_BOSH_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_BOSH_EXPORTER_DOWNLOAD_URL -o /tmp/cache/bosh_exporter-$LATEST_BOSH_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/bosh_exporter-$LATEST_BOSH_EXPORTER_VERSION.linux-amd64.tar.gz bosh_exporter/bosh_exporter-$LATEST_BOSH_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob bosh_exporter/bosh_exporter-$USED_BOSH_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Bosh-Exporter bumped to ${LATEST_BOSH_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_BOSH_TSDB_EXPORTER_VERSION != $USED_BOSH_TSDB_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_BOSH_TSDB_EXPORTER_DOWNLOAD_URL -o /tmp/cache/bosh_tsdb_exporter-$LATEST_BOSH_TSDB_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/bosh_tsdb_exporter-$LATEST_BOSH_TSDB_EXPORTER_VERSION.linux-amd64.tar.gz bosh_tsdb_exporter/bosh_tsdb_exporter-$LATEST_BOSH_TSDB_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob bosh_tsdb_exporter/bosh_tsdb_exporter-$USED_BOSH_TSDB_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Bosh-TSDB-Exporter bumped to ${LATEST_BOSH_TSDB_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_COLLECTD_EXPORTER_VERSION != $USED_COLLECTD_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_COLLECTD_EXPORTER_DOWNLOAD_URL -o /tmp/cache/collectd_exporter-$LATEST_COLLECTD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/collectd_exporter-$LATEST_COLLECTD_EXPORTER_VERSION.linux-amd64.tar.gz collectd_exporter/collectd_exporter-$LATEST_COLLECTD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob collectd_exporter/collectd_exporter-$USED_COLLECTD_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Collectd-Exporter bumped to ${LATEST_COLLECTD_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_CONSUL_EXPORTER_VERSION != $USED_CONSUL_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_CONSUL_EXPORTER_DOWNLOAD_URL -o /tmp/cache/consul_exporter-$LATEST_CONSUL_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/consul_exporter-$LATEST_CONSUL_EXPORTER_VERSION.linux-amd64.tar.gz consul_exporter/consul_exporter-$LATEST_CONSUL_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob consul_exporter/consul_exporter-$USED_CONSUL_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Consul-Exporter bumped to ${LATEST_CONSUL_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_CREDHUB_EXPORTER_VERSION != $USED_CREDHUB_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_CREDHUB_EXPORTER_DOWNLOAD_URL -o /tmp/cache/credhub_exporter_${LATEST_CREDHUB_EXPORTER_VERSION}_linux_amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/credhub_exporter_${LATEST_CREDHUB_EXPORTER_VERSION}_linux_amd64.tar.gz credhub_exporter/credhub_exporter_${LATEST_CREDHUB_EXPORTER_VERSION}_linux_amd64.tar.gz
  /tmp/cache/bosh remove-blob credhub_exporter/credhub_exporter_${USED_CREDHUB_EXPORTER_VERSION}_linux_amd64.tar.gz
  echo "Credhub-Exporter bumped to ${LATEST_CREDHUB_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_CF_EXPORTER_VERSION != $USED_CF_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_CF_EXPORTER_DOWNLOAD_URL -o /tmp/cache/cf_exporter_$LATEST_CF_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/cf_exporter_$LATEST_CF_EXPORTER_VERSION.linux-amd64.tar.gz cf_exporter/cf_exporter_$LATEST_CF_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob cf_exporter/cf_exporter_$USED_CF_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "CF-Exporter bumped to ${LATEST_CF_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_FIREHOSE_EXPORTER_VERSION != $USED_FIREHOSE_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_FIREHOSE_EXPORTER_DOWNLOAD_URL -o /tmp/cache/firehose_exporter_$LATEST_FIREHOSE_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/firehose_exporter_$LATEST_FIREHOSE_EXPORTER_VERSION.linux-amd64.tar.gz firehose_exporter/firehose_exporter_$LATEST_FIREHOSE_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob firehose_exporter/firehose_exporter_$USED_FIREHOSE_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Firehose-Exporter bumped to ${LATEST_FIREHOSE_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_ELASTICSEARCH_EXPORTER_VERSION != $USED_ELASTICSEARCH_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_ELASTICSEARCH_EXPORTER_DOWNLOAD_URL -o /tmp/cache/elasticsearch_exporter-$LATEST_ELASTICSEARCH_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/elasticsearch_exporter-$LATEST_ELASTICSEARCH_EXPORTER_VERSION.linux-amd64.tar.gz elasticsearch_exporter/elasticsearch_exporter-$LATEST_ELASTICSEARCH_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob elasticsearch_exporter/elasticsearch_exporter-$USED_ELASTICSEARCH_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Elasticsearch-Exporter bumped to ${LATEST_ELASTICSEARCH_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_GRAPHITE_EXPORTER_VERSION != $USED_GRAPHITE_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_GRAPHITE_EXPORTER_DOWNLOAD_URL -o /tmp/cache/graphite_exporter-$LATEST_GRAPHITE_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/graphite_exporter-$LATEST_GRAPHITE_EXPORTER_VERSION.linux-amd64.tar.gz graphite_exporter/graphite_exporter-$LATEST_GRAPHITE_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob graphite_exporter/graphite_exporter-$USED_GRAPHITE_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Graphite-Exporter bumped to ${LATEST_GRAPHITE_EXPORTER_VERSION}" >> bumped_versions.txt
fi
#if [[ $LATEST_GRAFANA_VERSION != $USED_GRAFANA_VERSION ]]; then
# curl -sL $LATEST_GRAFANA_DOWNLOAD_URL -o /tmp/cache/grafana-$LATEST_GRAFANA_VERSION.linux-amd64.tar.gz
# /tmp/cache/bosh add-blob /tmp/cache/grafana-$LATEST_GRAFANA_VERSION.linux-amd64.tar.gz grafana/grafana-$LATEST_GRAFANA_VERSION.linux-amd64.tar.gz
# /tmp/cache/bosh remove-blob grafana/grafana-$USED_GRAFANA_VERSION.linux-amd64.tar.gz
# echo "Grafana bumped to ${LATEST_GRAFANA_VERSION}" >> bumped_versions.txt
#fi
if [[ $LATEST_INFLUXDB_EXPORTER_VERSION != $USED_INFLUXDB_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_INFLUXDB_EXPORTER_DOWNLOAD_URL -o /tmp/cache/influxdb_exporter-$LATEST_INFLUXDB_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/influxdb_exporter-$LATEST_INFLUXDB_EXPORTER_VERSION.linux-amd64.tar.gz influxdb_exporter/influxdb_exporter-$LATEST_INFLUXDB_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob influxdb_exporter/influxdb_exporter-$USED_INFLUXDB_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "InfluxDB-Exporter bumped to ${LATEST_INFLUXDB_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_INGESTOR_EXPORTER_VERSION != $USED_INGESTOR_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_INGESTOR_EXPORTER_DOWNLOAD_URL -o /tmp/cache/ingestor_exporter-$LATEST_INGESTOR_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/ingestor_exporter-$LATEST_INGESTOR_EXPORTER_VERSION.linux-amd64.tar.gz ingestor_exporter/ingestor_exporter-$LATEST_INGESTOR_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob ingestor_exporter/ingestor_exporter-$USED_INGESTOR_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Ingestor-Exporter bumped to ${LATEST_INGESTOR_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_MEMCACHED_EXPORTER_VERSION != $USED_MEMCACHED_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_MEMCACHED_EXPORTER_DOWNLOAD_URL -o /tmp/cache/memcached_exporter-$LATEST_MEMCACHED_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/memcached_exporter-$LATEST_MEMCACHED_EXPORTER_VERSION.linux-amd64.tar.gz memcached_exporter/memcached_exporter-$LATEST_MEMCACHED_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob memcached_exporter/memcached_exporter-$USED_MEMCACHED_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Memcached-Exporter bumped to ${LATEST_MEMCACHED_EXPORTER_VERSION}" >> bumped_versions.txt
fi
# if [[ $LATEST_MONGODB_EXPORTER_VERSION != $USED_MONGODB_EXPORTER_VERSION ]]; then
#  curl -sL $LATEST_MONGODB_EXPORTER_DOWNLOAD_URL -o /tmp/cache/mongodb_exporter-$LATEST_MONGODB_EXPORTER_VERSION.linux-amd64.tar.gz
#  /tmp/cache/bosh add-blob /tmp/cache/mongodb_exporter-$LATEST_MONGODB_EXPORTER_VERSION.linux-amd64.tar.gz mongodb_exporter/mongodb_exporter-$LATEST_MONGODB_EXPORTER_VERSION.linux-amd64.tar.gz
#  /tmp/cache/bosh remove-blob mongodb_exporter/mongodb_exporter-$USED_MONGODB_EXPORTER_VERSION.linux-amd64.tar.gz
#  echo "MongoDB-Exporter bumped to ${LATEST_MONGODB_EXPORTER_VERSION}" >> bumped_versions.txt
# fi
if [[ $LATEST_MYSQLD_EXPORTER_VERSION != $USED_MYSQLD_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_MYSQLD_EXPORTER_DOWNLOAD_URL -o /tmp/cache/mysqld_exporter-$LATEST_MYSQLD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/mysqld_exporter-$LATEST_MYSQLD_EXPORTER_VERSION.linux-amd64.tar.gz mysqld_exporter/mysqld_exporter-$LATEST_MYSQLD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob mysqld_exporter/mysqld_exporter-$USED_MYSQLD_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "MySQL-Exporter bumped to ${LATEST_MYSQLD_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_POSTGRES_EXPORTER_VERSION != $USED_POSTGRES_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_POSTGRES_EXPORTER_DOWNLOAD_URL -o /tmp/cache/postgres_exporter-$LATEST_POSTGRES_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/postgres_exporter-$LATEST_POSTGRES_EXPORTER_VERSION.linux-amd64.tar.gz postgres_exporter/postgres_exporter-$LATEST_POSTGRES_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob postgres_exporter/postgres_exporter-$USED_POSTGRES_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Postgres-Exporter bumped to ${LATEST_POSTGRES_EXPORTER_VERSION}" >> bumped_versions.txt
fi
#if [[ $LATEST_PROMETHEUS_VERSION != $USED_PROMETHEUS_VERSION ]]; then
#  curl -sL $LATEST_PROMETHEUS_DOWNLOAD_URL -o /tmp/cache/prometheus-$LATEST_PROMETHEUS_VERSION.linux-amd64.tar.gz
#  /tmp/cache/bosh add-blob /tmp/cache/prometheus-$LATEST_PROMETHEUS_VERSION.linux-amd64.tar.gz prometheus/prometheus-$LATEST_PROMETHEUS_VERSION.linux-amd64.tar.gz
#  /tmp/cache/bosh remove-blob prometheus/prometheus-$USED_PROMETHEUS_VERSION.linux-amd64.tar.gz
#  echo "Prometheus bumped to ${LATEST_PROMETHEUS_VERSION}" >> bumped_versions.txt
#fi
if [[ $LATEST_PUSHGATEWAY_VERSION != $USED_PUSHGATEWAY_VERSION ]]; then
  curl -sL $LATEST_PUSHGATEWAY_DOWNLOAD_URL -o /tmp/cache/pushgateway-$LATEST_PUSHGATEWAY_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/pushgateway-$LATEST_PUSHGATEWAY_VERSION.linux-amd64.tar.gz pushgateway/pushgateway-$LATEST_PUSHGATEWAY_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob pushgateway/pushgateway-$USED_PUSHGATEWAY_VERSION.linux-amd64.tar.gz
  echo "Pushgateway bumped to ${LATEST_PUSHGATEWAY_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_SHIELD_EXPORTER_VERSION != $USED_SHIELD_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_SHIELD_EXPORTER_DOWNLOAD_URL -o /tmp/cache/shield_exporter-$LATEST_SHIELD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/shield_exporter-$LATEST_SHIELD_EXPORTER_VERSION.linux-amd64.tar.gz shield_exporter/shield_exporter-$LATEST_SHIELD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob shield_exporter/shield_exporter-$USED_SHIELD_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Shield-Exporter bumped to ${LATEST_SHIELD_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_STACKDRIVER_EXPORTER_VERSION != $USED_STACKDRIVER_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_STACKDRIVER_EXPORTER_DOWNLOAD_URL -o /tmp/cache/stackdriver_exporter-$LATEST_STACKDRIVER_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/stackdriver_exporter-$LATEST_STACKDRIVER_EXPORTER_VERSION.linux-amd64.tar.gz stackdriver_exporter/stackdriver_exporter-$LATEST_STACKDRIVER_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob stackdriver_exporter/stackdriver_exporter-$USED_STACKDRIVER_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Stackdriver-Exporter bumped to ${LATEST_STACKDRIVER_EXPORTER_VERSION}" >> bumped_versions.txt
fi
if [[ $LATEST_STATSD_EXPORTER_VERSION != $USED_STATSD_EXPORTER_VERSION ]]; then
  curl -sL $LATEST_STATSD_EXPORTER_DOWNLOAD_URL -o /tmp/cache/statsd_exporter-$LATEST_STATSD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh add-blob /tmp/cache/statsd_exporter-$LATEST_STATSD_EXPORTER_VERSION.linux-amd64.tar.gz statsd_exporter/statsd_exporter-$LATEST_STATSD_EXPORTER_VERSION.linux-amd64.tar.gz
  /tmp/cache/bosh remove-blob statsd_exporter/statsd_exporter-$USED_STATSD_EXPORTER_VERSION.linux-amd64.tar.gz
  echo "Statsd-Exporter bumped to ${LATEST_STATSD_EXPORTER_VERSION}" >> bumped_versions.txt
fi

# /tmp/cache/bosh blobs
bosh blobs

# /tmp/cache/bosh upload-blobs

sed -i '' -e "s/redis_exporter-$USED_REDIS_EXPORTER_VERSION\.linux-amd64/redis_exporter-$LATEST_REDIS_EXPORTER_VERSION\.linux-amd64/g" packages/redis_exporter/*
sed -i '' -e "s/$USED_REDIS_EXPORTER_VERSION/$LATEST_REDIS_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/alertmanager-$USED_ALERTMANAGER_VERSION\.linux-amd64/alertmanager-$LATEST_ALERTMANAGER_VERSION\.linux-amd64/g" packages/alertmanager/*
sed -i '' -e "s/$USED_ALERTMANAGER_VERSION/$LATEST_ALERTMANAGER_VERSION/g" VERSIONS.md
sed -i '' -e "s/blackbox_exporter-$USED_BLACKBOX_EXPORTER_VERSION\.linux-amd64/blackbox_exporter-$LATEST_BLACKBOX_EXPORTER_VERSION\.linux-amd64/g" packages/blackbox_exporter/*
sed -i '' -e "s/$USED_BLACKBOX_EXPORTER_VERSION/$LATEST_BLACKBOX_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/bosh_exporter-$USED_BOSH_EXPORTER_VERSION\.linux-amd64/bosh_exporter-$LATEST_BOSH_EXPORTER_VERSION\.linux-amd64/g" packages/bosh_exporter/*
sed -i '' -e "s/bosh_exporter_$USED_BOSH_EXPORTER_VERSION\.linux-amd64/bosh_exporter_$LATEST_BOSH_EXPORTER_VERSION\.linux-amd64/g" packages/bosh_exporter/*
sed -i '' -e "s/$USED_BOSH_EXPORTER_VERSION/$LATEST_BOSH_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/bosh_tsdb_exporter-$USED_BOSH_TSDB_EXPORTER_VERSION\.linux-amd64/bosh_tsdb_exporter-$LATEST_BOSH_TSDB_EXPORTER_VERSION\.linux-amd64/g" packages/bosh_tsdb_exporter/*
sed -i '' -e "s/$USED_BOSH_TSDB_EXPORTER_VERSION/$LATEST_BOSH_TSDB_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/collectd_exporter-$USED_COLLECTD_EXPORTER_VERSION\.linux-amd64/collectd_exporter-$LATEST_COLLECTD_EXPORTER_VERSION\.linux-amd64/g" packages/collectd_exporter/*
sed -i '' -e "s/$USED_COLLECTD_EXPORTER_VERSION/$LATEST_COLLECTD_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/consul_exporter-$USED_CONSUL_EXPORTER_VERSION\.linux-amd64/consul_exporter-$LATEST_CONSUL_EXPORTER_VERSION\.linux-amd64/g" packages/consul_exporter/*
sed -i '' -e "s/$USED_CONSUL_EXPORTER_VERSION/$LATEST_CONSUL_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/credhub_exporter_${USED_CREDHUB_EXPORTER_VERSION}_linux_amd64/credhub_exporter_${LATEST_CREDHUB_EXPORTER_VERSION}_linux_amd64/g" packages/credhub_exporter/*
sed -i '' -e "s/$USED_CREDHUB_EXPORTER_VERSION/$LATEST_CREDHUB_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/cf_exporter_$USED_CF_EXPORTER_VERSION\.linux-amd64/cf_exporter_$LATEST_CF_EXPORTER_VERSION\.linux-amd64/g" packages/cf_exporter/*
sed -i '' -e "s/$USED_CF_EXPORTER_VERSION/$LATEST_CF_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/firehose_exporter_$USED_FIREHOSE_EXPORTER_VERSION\.linux-amd64/firehose_exporter_$LATEST_FIREHOSE_EXPORTER_VERSION\.linux-amd64/g" packages/firehose_exporter/*
sed -i '' -e "s/$USED_FIREHOSE_EXPORTER_VERSION/$LATEST_FIREHOSE_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/elasticsearch_exporter-$USED_ELASTICSEARCH_EXPORTER_VERSION\.linux-amd64/elasticsearch_exporter-$LATEST_ELASTICSEARCH_EXPORTER_VERSION\.linux-amd64/g" packages/elasticsearch_exporter/*
sed -i '' -e "s/$USED_ELASTICSEARCH_EXPORTER_VERSION/$LATEST_ELASTICSEARCH_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/graphite_exporter-$USED_GRAPHITE_EXPORTER_VERSION\.linux-amd64/graphite_exporter-$LATEST_GRAPHITE_EXPORTER_VERSION\.linux-amd64/g" packages/graphite_exporter/*
sed -i '' -e "s/$USED_GRAPHITE_EXPORTER_VERSION/$LATEST_GRAPHITE_EXPORTER_VERSION/g" VERSIONS.md
#sed -i '' -e "s/grafana-$USED_GRAFANA_VERSION\.linux-amd64/grafana-$LATEST_GRAFANA_VERSION\.linux-amd64/g" packages/grafana/*
#sed -i '' -e "s/$USED_GRAFANA_VERSION/$LATEST_GRAFANA_VERSION/g" VERSIONS.md
sed -i '' -e "s/influxdb_exporter-$USED_INFLUXDB_EXPORTER_VERSION\.linux-amd64/influxdb_exporter-$LATEST_INFLUXDB_EXPORTER_VERSION\.linux-amd64/g" packages/influxdb_exporter/*
sed -i '' -e "s/$USED_INFLUXDB_EXPORTER_VERSION/$LATEST_INFLUXDB_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/ingestor_exporter-$USED_INGESTOR_EXPORTER_VERSION\.linux-amd64/ingestor_exporter-$LATEST_INGESTOR_EXPORTER_VERSION\.linux-amd64/g" packages/ingestor_exporter/*
sed -i '' -e "s/$USED_INGESTOR_EXPORTER_VERSION/$LATEST_INGESTOR_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/memcached_exporter-$USED_MEMCACHED_EXPORTER_VERSION\.linux-amd64/memcached_exporter-$LATEST_MEMCACHED_EXPORTER_VERSION\.linux-amd64/g" packages/memcached_exporter/*
sed -i '' -e "s/$USED_MEMCACHED_EXPORTER_VERSION/$LATEST_MEMCACHED_EXPORTER_VERSION/g" VERSIONS.md
#sed -i '' -e "s/mongodb_exporter-$USED_MONGODB_EXPORTER_VERSION\.linux-amd64/mongodb_exporter-$LATEST_MONGODB_EXPORTER_VERSION\.linux-amd64/g" packages/mongodb_exporter/*
#sed -i '' -e "s/$USED_MONGODB_EXPORTER_VERSION/$LATEST_MONGODB_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/mysqld_exporter-$USED_MYSQLD_EXPORTER_VERSION\.linux-amd64/mysqld_exporter-$LATEST_MYSQLD_EXPORTER_VERSION\.linux-amd64/g" packages/mysqld_exporter/*
sed -i '' -e "s/$USED_MYSQLD_EXPORTER_VERSION/$LATEST_MYSQLD_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/postgres_exporter-$USED_POSTGRES_EXPORTER_VERSION\.linux-amd64/postgres_exporter-$LATEST_POSTGRES_EXPORTER_VERSION\.linux-amd64/g" packages/postgres_exporter/*
sed -i '' -e "s/$USED_POSTGRES_EXPORTER_VERSION/$LATEST_POSTGRES_EXPORTER_VERSION/g" VERSIONS.md
#sed -i '' -e "s/prometheus-$USED_PROMETHEUS_VERSION\.linux-amd64/prometheus-$LATEST_PROMETHEUS_VERSION\.linux-amd64/g" packages/prometheus2/*
#sed -i '' -e "s/$USED_PROMETHEUS_VERSION/$LATEST_PROMETHEUS_VERSION/g" VERSIONS.md
sed -i '' -e "s/pushgateway-$USED_PUSHGATEWAY_VERSION\.linux-amd64/pushgateway-$LATEST_PUSHGATEWAY_VERSION\.linux-amd64/g" packages/pushgateway/*
sed -i '' -e "s/$USED_PUSHGATEWAY_VERSION/$LATEST_PUSHGATEWAY_VERSION/g" VERSIONS.md
sed -i '' -e "s/shield_exporter-$USED_SHIELD_EXPORTER_VERSION\.linux-amd64/shield_exporter-$LATEST_SHIELD_EXPORTER_VERSION\.linux-amd64/g" packages/shield_exporter/*
sed -i '' -e "s/$USED_SHIELD_EXPORTER_VERSION/$LATEST_SHIELD_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/stackdriver_exporter-$USED_STACKDRIVER_EXPORTER_VERSION\.linux-amd64/stackdriver_exporter-$LATEST_STACKDRIVER_EXPORTER_VERSION\.linux-amd64/g" packages/stackdriver_exporter/*
sed -i '' -e "s/$USED_STACKDRIVER_EXPORTER_VERSION/$LATEST_STACKDRIVER_EXPORTER_VERSION/g" VERSIONS.md
sed -i '' -e "s/statsd_exporter-$USED_STATSD_EXPORTER_VERSION\.linux-amd64/statsd_exporter-$LATEST_STATSD_EXPORTER_VERSION\.linux-amd64/g" packages/statsd_exporter/*
sed -i '' -e "s/$USED_STATSD_EXPORTER_VERSION/$LATEST_STATSD_EXPORTER_VERSION/g" VERSIONS.md

cat bumped_versions.txt
rm bumped_versions.txt

rm -rf /tmp/cache/ /tmp/prometheus-blobs/

echo "DO NOT BUMP PROMETHEUS to PROMETHEUS3"
echo "DO NOT BUMP GRAFANA to GRAFANA v11"
