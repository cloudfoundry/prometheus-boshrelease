#!/bin/bash

set -e

VERSION="1.9.0"
DOWNLOAD_URL="https://github.com/danielqsj/kafka_exporter/releases/download/v${VERSION}/kafka_exporter-${VERSION}.linux-amd64.tar.gz"
FILENAME="kafka_exporter-${VERSION}.linux-amd64.tar.gz"

echo "Downloading kafka_exporter v${VERSION}..."
echo "URL: ${DOWNLOAD_URL}"

if command -v wget &> /dev/null; then
    wget -O "${FILENAME}" "${DOWNLOAD_URL}"
elif command -v curl &> /dev/null; then
    curl -L -o "${FILENAME}" "${DOWNLOAD_URL}"
else
    echo "Error: Neither wget nor curl is available. Please install one of them."
    exit 1
fi

echo "Download complete: ${FILENAME}"
echo "File size: $(du -h ${FILENAME} | cut -f1)"
