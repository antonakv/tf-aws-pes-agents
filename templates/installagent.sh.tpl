#!/usr/bin/env bash

# Stop on any error
set -euo pipefail

function get_secret {
    local secret_id=$1
    /usr/bin/env aws secretsmanager get-secret-value --secret-id $secret_id --region ${region} | jq --raw-output '.SecretBinary,.SecretString | select(. != null)'
}

agent_secret=$(get_secret ${agent_token_id})

sudo echo "TFC_AGENT_TOKEN=$agent_secret" > /etc/tfc-agent.env
sudo echo "TFC_ADDRESS=https://${tfe_hostname}" >> /etc/tfc-agent.env

mkdir /home/ubuntu/install

echo ${tfcagent_service} | base64 --decode > /home/ubuntu/install/tfc-agent.service

sudo cp /home/ubuntu/install/tfc-agent.service /etc/systemd/system/tfc-agent.service

sudo sysctl -w vm.swappiness=1

sudo systemctl daemon-reload

sudo systemctl enable tfc-agent.service

sudo systemctl start tfc-agent.service
