#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

set -e

CONFIG="/etc/twingate/connector.conf"
CONFIG_DIR=$(dirname "$CONFIG")

apt_require_curl() {
    if ! command -v curl; then
        apt install -yq curl
        trap "apt purge -yq curl" EXIT
    fi
}

apt_require_gpg() {
    if ! command -v gpg; then
        apt install -yq gpg
        trap "apt purge -yq gpg" EXIT
    fi
}

exit_no_changes () {
    echo "Canceling setup and exiting. No changes have been made."
    exit 1
}

if [ -f "$CONFIG" ]; then
    echo "Config file \"${CONFIG}\" already exists"
    exit_no_changes
else
    install -d -m 0700 "$CONFIG_DIR"
    [ -f "$CONFIG" ] && mv "$CONFIG" "$CONFIG.$(date +%s)"
fi

apt update -yq
apt_require_curl
apt_require_gpg

TWINGATE_GPG_PUBLIC_KEY=/usr/share/keyrings/twingate-client-keyring.gpg
if ! curl -fsSL "https://packages.twingate.com/apt/gpg.key" | gpg --dearmor -o "$TWINGATE_GPG_PUBLIC_KEY"; then
    echo "Failed to download or process GPG key"
    exit 1
fi
echo "deb [signed-by=${TWINGATE_GPG_PUBLIC_KEY}] https://packages.twingate.com/apt/ /" | tee /etc/apt/sources.list.d/twingate.list
apt update -yq
apt install -yq twingate-connector

TWINGATE_ACCESS_TOKEN=$(bashio::config 'access_token')
if [[ -z "${TWINGATE_ACCESS_TOKEN}" ]]; then
    echo "access_token is not set. Please set it in the configuration."
    exit_no_changes
fi
export TWINGATE_ACCESS_TOKEN

TWINGATE_REFRESH_TOKEN=$(bashio::config 'refresh_token')
if [[ -z "${TWINGATE_REFRESH_TOKEN}" ]]; then
    echo "refresh_token is not set. Please set it in the configuration."
    exit_no_changes
fi
export TWINGATE_REFRESH_TOKEN

TWINGATE_NETWORK=$(bashio::config 'network')
if [[ -z "${TWINGATE_NETWORK}" ]]; then
    echo "network is not set. Please set it in the configuration."
    exit_no_changes
fi
export TWINGATE_NETWORK

TWINGATE_LOG_LEVEL=$(bashio::config 'connector_log_level')
if [[ -z "${TWINGATE_LOG_LEVEL}" ]]; then
    echo "connector_log_level is not set. Using default log level (3)"
    TWINGATE_LOG_LEVEL=3
fi
export TWINGATE_LOG_LEVEL

TWINGATE_LABEL_DEPLOYED_BY="home_assistant"
export TWINGATE_LABEL_DEPLOYED_BY

{
  echo "TWINGATE_NETWORK=${TWINGATE_NETWORK}"
  echo "TWINGATE_ACCESS_TOKEN=${TWINGATE_ACCESS_TOKEN}"
  echo "TWINGATE_REFRESH_TOKEN=${TWINGATE_REFRESH_TOKEN}"
  echo "TWINGATE_LOG_LEVEL=${TWINGATE_LOG_LEVEL}"
  echo "TWINGATE_LABEL_HOSTNAME=$(hostname)"
  echo "TWINGATE_LABEL_DEPLOYED_BY=${TWINGATE_LABEL_DEPLOYED_BY}"
} > "$CONFIG"
chmod 0600 "$CONFIG"

/usr/bin/twingate-connector
