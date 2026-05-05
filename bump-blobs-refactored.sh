#!/bin/bash

set -euo pipefail

# Setup
mkdir -p /tmp/cache /tmp/prometheus-blobs
cd "$HOME/Documents/prometheus-boshrelease"
export BOSH_VERSION=7.6.1

# Download BOSH CLI
cd /tmp/cache
curl -sL "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-darwin-arm64" > bosh
chmod 777 bosh
cd -

touch bumped_versions.txt

# Define exporters: repo_owner repo_name blob_name version_pattern version_filter package_dir
# Format: "PRETTY_NAME|repo_owner|repo_name|blob_name|version_pattern|version_filter|package_dir|api_token"
declare -a EXPORTERS=(
  "Redis-Exporter|oliver006|redis_exporter|redis_exporter|redis_exporter-v|sed 's/v//'|redis_exporter|CF_PROM_CI_BOT_TOKEN"
  "Alertmanager|prometheus|alertmanager|alertmanager|alertmanager-|sed 's/v//'|alertmanager|CF_PROM_CI_BOT_TOKEN"
  "Blackbox-Exporter|prometheus|blackbox_exporter|blackbox_exporter|blackbox_exporter-|sed 's/v//'|blackbox_exporter|CF_PROM_CI_BOT_TOKEN"
  "Bosh-Exporter|cloudfoundry|bosh_exporter|bosh_exporter|bosh_exporter-|sed 's/v//'|bosh_exporter|CF_PROM_CI_BOT_TOKEN"
  "Bosh-TSDB-Exporter|bosh-prometheus|bosh_tsdb_exporter|bosh_tsdb_exporter|bosh_tsdb_exporter-|sed 's/v//'|bosh_tsdb_exporter|CF_PROM_CI_BOT_TOKEN"
  "Collectd-Exporter|prometheus|collectd_exporter|collectd_exporter|collectd_exporter-|sed 's/v//'|collectd_exporter|CF_PROM_CI_BOT_TOKEN"
  "Consul-Exporter|prometheus|consul_exporter|consul_exporter|consul_exporter-|sed 's/v//'|consul_exporter|CF_PROM_CI_BOT_TOKEN"
  "Credhub-Exporter|orange-cloudfoundry|credhub_exporter|credhub_exporter|credhub_exporter_|sed 's/v//'|credhub_exporter|CF_PROM_CI_BOT_TOKEN"
  "CF-Exporter|cloudfoundry|cf_exporter|cf_exporter|cf_exporter_|sed 's/v//'|cf_exporter|CF_PROM_CI_BOT_TOKEN"
  "Firehose-Exporter|cloudfoundry|firehose_exporter|firehose_exporter|firehose_exporter_|sed 's/v//'|firehose_exporter|FIREHOSE_PROM_CI_BOT_TOKEN"
  "Elasticsearch-Exporter|prometheus-community|elasticsearch_exporter|elasticsearch_exporter|elasticsearch_exporter-|sed 's/v//'|elasticsearch_exporter|CF_PROM_CI_BOT_TOKEN"
  "Graphite-Exporter|prometheus|graphite_exporter|graphite_exporter|graphite_exporter-|sed 's/v//'|graphite_exporter|CF_PROM_CI_BOT_TOKEN"
  "InfluxDB-Exporter|prometheus|influxdb_exporter|influxdb_exporter|influxdb_exporter-|sed 's/v//'|influxdb_exporter|CF_PROM_CI_BOT_TOKEN"
  "Ingestor-Exporter|bosh-prometheus|ingestor_exporter|ingestor_exporter|ingestor_exporter-|sed 's/v//'|ingestor_exporter|CF_PROM_CI_BOT_TOKEN"
  "Memcached-Exporter|prometheus|memcached_exporter|memcached_exporter|memcached_exporter-|sed 's/v//'|memcached_exporter|CF_PROM_CI_BOT_TOKEN"
  "MongoDB-Exporter|percona|mongodb_exporter|mongodb_exporter|mongodb_exporter-|sed 's/v//'|mongodb_exporter|CF_PROM_CI_BOT_TOKEN"
  "MySQL-Exporter|prometheus|mysqld_exporter|mysqld_exporter|mysqld_exporter-|sed 's/v//'|mysqld_exporter|CF_PROM_CI_BOT_TOKEN"
  "Postgres-Exporter|prometheus-community|postgres_exporter|postgres_exporter|postgres_exporter-|sed 's/v//'|postgres_exporter|CF_PROM_CI_BOT_TOKEN"
  "Prometheus|prometheus|prometheus|prometheus|prometheus-|sed 's/v//'|prometheus2|CF_PROM_CI_BOT_TOKEN"
  "Pushgateway|prometheus|pushgateway|pushgateway|pushgateway-|sed 's/v//'|pushgateway|CF_PROM_CI_BOT_TOKEN"
  "Shield-Exporter|bosh-prometheus|shield_exporter|shield_exporter|shield_exporter-|sed 's/v//'|shield_exporter|CF_PROM_CI_BOT_TOKEN"
  "Stackdriver-Exporter|prometheus-community|stackdriver_exporter|stackdriver_exporter|stackdriver_exporter-|sed 's/v//'|stackdriver_exporter|CF_PROM_CI_BOT_TOKEN"
  "Statsd-Exporter|prometheus|statsd_exporter|statsd_exporter|statsd_exporter-|sed 's/v//'|statsd_exporter|CF_PROM_CI_BOT_TOKEN"
)

# Get GitHub API token
get_api_token() {
  local token_var="$1"
  echo "${!token_var}"
}

# Fetch latest version from GitHub API
fetch_latest_version() {
  local repo_owner="$1"
  local repo_name="$2"
  local api_token="$3"
  local version_filter="$4"
  
  curl -sL "https://$(get_api_token "$api_token"):@api.github.com/repos/${repo_owner}/${repo_name}/releases/latest" \
    | jq -r '.tag_name' \
    | eval "$version_filter"
}

# Fetch latest download URL
fetch_latest_url() {
  local repo_owner="$1"
  local repo_name="$2"
  local api_token="$3"
  local asset_filter="$4"
  
  curl -sL "https://$(get_api_token "$api_token"):@api.github.com/repos/${repo_owner}/${repo_name}/releases/latest" \
    | jq -r '.assets[].browser_download_url' \
    | grep "$asset_filter"
}

# Extract used version from config/blobs.yml
extract_used_version() {
  local pattern="$1"
  
  cat config/blobs.yml | egrep -o "$pattern" | head -1
}

# Handle special cases for version extraction
get_used_version() {
  local blob_name="$1"
  
  case "$blob_name" in
    prometheus)
      extract_used_version "prometheus-2\.[[:digit:]]+\.[[:digit:]]+" | cut -d "-" -f 2
      ;;
    credhub_exporter|cf_exporter|firehose_exporter)
      extract_used_version "${blob_name}_[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+" | cut -d "_" -f 3
      ;;
    *)
      extract_used_version "${blob_name}-[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+" | cut -d "-" -f 2
      ;;
  esac
}

# Handle special cases for asset filtering
get_asset_filter() {
  local blob_name="$1"
  
  case "$blob_name" in
    credhub_exporter)
      echo "linux_amd64.tar.gz\$"
      ;;
    *)
      echo "linux-amd64.tar.gz\$"
      ;;
  esac
}

# Process a single exporter
bump_exporter() {
  local pretty_name="$1"
  local repo_owner="$2"
  local repo_name="$3"
  local blob_name="$4"
  local version_pattern="$5"
  local version_filter="$6"
  local package_dir="$7"
  local api_token="$8"
  
  echo "Processing $pretty_name..."
  
  local asset_filter
  asset_filter=$(get_asset_filter "$blob_name")
  
  local latest_version
  latest_version=$(fetch_latest_version "$repo_owner" "$repo_name" "$api_token" "$version_filter")
  
  local used_version
  used_version=$(get_used_version "$blob_name")
  
  echo "  Latest: $latest_version, Used: $used_version"
  
  if [[ "$latest_version" == "$used_version" ]]; then
    echo "  → Already up to date"
    return 0
  fi
  
  local latest_url
  latest_url=$(fetch_latest_url "$repo_owner" "$repo_name" "$api_token" "$asset_filter")
  
  if [[ -z "$latest_url" ]]; then
    echo "  → Error: Could not fetch download URL"
    return 1
  fi
  
  echo "  → Bumping from $used_version to $latest_version"
  
  # Download blob
  local blob_filename
  if [[ "$blob_name" == "credhub_exporter" || "$blob_name" == "cf_exporter" || "$blob_name" == "firehose_exporter" ]]; then
    blob_filename="${blob_name}_${latest_version}.linux-amd64.tar.gz"
  else
    blob_filename="${blob_name}-${latest_version}.linux-amd64.tar.gz"
  fi
  
  curl -sL "$latest_url" -o "/tmp/cache/$blob_filename"
  
  # Add new blob
  /tmp/cache/bosh add-blob "/tmp/cache/$blob_filename" "$blob_name/$blob_filename"
  
  # Remove old blob
  local old_blob_filename
  if [[ "$blob_name" == "credhub_exporter" || "$blob_name" == "cf_exporter" || "$blob_name" == "firehose_exporter" ]]; then
    old_blob_filename="${blob_name}_${used_version}.linux-amd64.tar.gz"
  else
    old_blob_filename="${blob_name}-${used_version}.linux-amd64.tar.gz"
  fi
  
  /tmp/cache/bosh remove-blob "$blob_name/$old_blob_filename"
  
  # Update package files
  if [[ "$blob_name" == "credhub_exporter" || "$blob_name" == "cf_exporter" || "$blob_name" == "firehose_exporter" ]]; then
    sed -i '' -e "s/${blob_name}_${used_version}\.linux-amd64/${blob_name}_${latest_version}\.linux-amd64/g" "packages/${package_dir}"/*
  else
    sed -i '' -e "s/${blob_name}-${used_version}\.linux-amd64/${blob_name}-${latest_version}\.linux-amd64/g" "packages/${package_dir}"/*
  fi
  
  # Update VERSIONS.md - only update the line for this specific exporter
  sed -i '' -e "/\[${blob_name}\]/s/$used_version/$latest_version/" VERSIONS.md
  
  echo "$pretty_name bumped to ${latest_version}" >> bumped_versions.txt
}

# Main processing loop
echo "Starting blob bumping..."
for exporter in "${EXPORTERS[@]}"; do
  IFS='|' read -r pretty_name repo_owner repo_name blob_name version_pattern version_filter package_dir api_token <<< "$exporter"
  bump_exporter "$pretty_name" "$repo_owner" "$repo_name" "$blob_name" "$version_pattern" "$version_filter" "$package_dir" "$api_token" || true
done

# Final steps
echo ""
echo "=== Blob Status ==="
/tmp/cache/bosh blobs

echo ""
echo "=== Bumped Versions ==="
cat bumped_versions.txt

# Cleanup
rm bumped_versions.txt
rm -rf /tmp/cache /tmp/prometheus-blobs

echo "Done!"
