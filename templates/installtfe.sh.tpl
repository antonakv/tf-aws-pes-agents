#!/usr/bin/env bash

# Stop on any error
set -euo pipefail

function get_secret {
    local secret_id=$1
    /usr/bin/env aws secretsmanager get-secret-value --secret-id $secret_id --region ${region} | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

logpath="/home/ubuntu/install/tfeinstall.log" 

mkdir -p /var/lib/tfe

mkdir -p /home/ubuntu/install

echo "$(date +"%T_%F") Create TFE and replicated setting files" | tee -a $logpath

sudo echo "${tfe_settings}" | sudo base64 --decode > /etc/ptfe-settings.json

sudo echo "${replicated_settings}" | sudo base64 --decode > /etc/replicated.conf

echo "$(date +"%T_%F") Create docker config" | tee -a $logpath

sudo mkdir -p /etc/docker | tee -a $logpath

sudo echo "${docker_config}" | sudo base64 --decode > /etc/docker/daemon.json

echo "$(date +"%T_%F") Extract certificate, key, license from AWS Secretsmanager" | tee -a $logpath

cert_base64=$(get_secret ${cert_secret_id})

key_base64=$(get_secret ${key_secret_id})

license_base64=$(get_secret ${license_secret_id})

echo "$(date +"%T_%F") Write certificate, key, license" | tee -a $logpath

echo $cert_base64 | base64 --decode > /var/lib/tfe/certificate.pem

echo $key_base64 | base64 --decode > /var/lib/tfe/key.pem

sudo echo $license_base64 | sudo base64 --decode > /etc/tfe-license.rli

echo "$(date +"%T_%F") Downloading TFE online" | tee -a $logpath

curl --noproxy '*' --create-dirs --output /etc/replicated/install.sh https://install.terraform.io/ptfe/active-active

chmod +x /etc/replicated/install.sh

cd /etc/replicated

ipaddr=$(hostname -I | awk '{print $1}')

echo "$(date +"%T_%F") Installing TFE online" | tee -a $logpath

/etc/replicated/install.sh \
    fast-timeouts \
    bypass-firewalld-warning \
    no-proxy \
    private-address=$ipaddr \
    public-address=$ipaddr \
    | tee -a $logpath
