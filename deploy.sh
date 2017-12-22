#!/bin/sh

bosh -e vbox -d prometheus deploy manifests/prometheus.yml \
  --vars-store tmp/deployment-vars.yml \
  -o manifests/operators/monitor-bosh.yml \
  -v bosh_url=https://192.168.50.6:25555 \
  -v bosh_username=admin \
  -v bosh_password=bmj1sdtuh2am06w6ektx \
  --var-file bosh_ca_cert=cert.pem \
  -v metrics_environment=bosh-lite

