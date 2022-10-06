#!/bin/bash

set -e

# Setting eOS Environment Variables
echo "Setting environment variables..."
export TOR_HOST=$(yq -r '.tor_address' /app/start9/config.yaml)
export LAN_HOST=$(yq -r '.lan_address' /app/start9/config.yaml)
export RPC_TYPE=$(yq -r '.bitcoind.type' /app/start9/config.yaml)
export RPC_USER=$(yq -r '.bitcoind.user' /app/start9/config.yaml)
export RPC_PASSWORD=$(yq -r '.bitcoind.password' /app/start9/config.yaml)
export RPC_PORT=8332
if [ "$RPC_TYPE" = "internal-proxy" ]; then
	export RPC_HOST="btc-rpc-proxy.embassy"
	echo "Running on Bitcoin Proxy..."
else
	export RPC_HOST="bitcoind.embassy"
	echo "Running on Bitcoin Core..."
fi

# Setting Database Environment Variables
export MYSQL_DATABASE=samourai-main
export MYSQL_ROOT_PASSWORD=rootpassword
export MYSQL_USER=samourai
export MYSQL_PASSWORD=password

# Setting Dojo Environment Variables
export APP_SAMOURAI_SERVER_IP=dojo.embassy
export APP_SAMOURAI_SERVER_DOJO_PORT=3009
export APP_SAMOURAI_SERVER_CONNECT_PORT=3005
export APP_SAMOURAI_SERVER_WHIRLPOOL_IP=dojo.embassy
export APP_SAMOURAI_SERVER_WHIRLPOOL_PORT=8898
export APP_SAMOURAI_SERVER_DB_IP=dojo.embassy
export APP_SAMOURAI_SERVER_NODE_IP=dojo.embassy

export dojo_hidden_service_file="data/app-samourai-server-dojo/hostname"
export whirlpool_hidden_service_file="data/app-samourai-server-whirlpool/hostname"
export APP_SAMOURAI_SERVER_DOJO_HIDDEN_SERVICE="$(cat "${dojo_hidden_service_file}" 2>/dev/null || echo "notyetset.onion")"
export APP_SAMOURAI_SERVER_WHIRLPOOL_HIDDEN_SERVICE="$(cat "${whirlpool_hidden_service_file}" 2>/dev/null || echo "notyetset.onion")"
export APP_SAMOURAI_SERVER_NODE_API_KEY=$(derive_entropy "env-${app_entropy_identifier}-NODE_API_KEY")
export APP_SAMOURAI_SERVER_NODE_ADMIN_KEY=$(derive_entropy "env-${app_entropy_identifier}-NODE_ADMIN_KEY")
export APP_SAMOURAI_SERVER_NODE_JWT_SECRET=$(derive_entropy "env-${app_entropy_identifier}-NODE_JWT_SECRET")
export APP_SAMOURAI_SERVER_WHIRLPOOL_API_KEY=$(derive_entropy "env-${app_entropy_identifier}-WHIRLPOOL_API_KEY")

# samourai-server dojo Hidden Service
HiddenServiceDir /data/app-samourai-server-dojo
HiddenServicePort 80 dojo.embassy:80

# samourai-server whirlpool Hidden Service
HiddenServiceDir /data/app-samourai-server-whirlpool
HiddenServicePort 80 dojo.embassy:8898

# samourai-server connect Hidden Service
HiddenServiceDir /data/app-samourai-server
HiddenServicePort 80 dojo.embassy:8081

# GLOBAL
export COMMON_BTC_NETWORK=$APP_BITCOIN_NETWORK
export DOJO_VERSION_TAG=1.16.1
export NET_DOJO_TOR_IPV4=embassy
export TOR_SOCKS_PORT=9075
export NET_DOJO_MYSQL_IPV4=dojo.embassy
# NODEJS
export NODE_GAP_EXTERNAL=100
export NODE_GAP_INTERNAL=100
export NODE_ADDR_FILTER_THRESHOLD=1000
export NODE_ADDR_DERIVATION_MIN_CHILD=2
export NODE_ADDR_DERIVATION_MAX_CHILD=2
export NODE_ADDR_DERIVATION_THRESHOLD=10
export NODE_TXS_SCHED_MAX_ENTRIES=10
export NODE_TXS_SCHED_MAX_DELTA_HEIGHT=18
export NODE_JWT_ACCESS_EXPIRES=900
export NODE_JWT_REFRESH_EXPIRES=7200
export NODE_PREFIX_STATUS=status
export NODE_PREFIX_SUPPORT=support
export NODE_PREFIX_STATUS_PUSHTX=status
export NODE_TRACKER_MEMPOOL_PERIOD=10000
export NODE_TRACKER_UNCONF_TXS_PERIOD=300000
export NODE_ACTIVE_INDEXER=local_indexer
export NODE_FEE_TYPE=ECONOMICAL
# SECURITY
export NODE_API_KEY=$APP_SAMOURAI_SERVER_NODE_API_KEY
export NODE_ADMIN_KEY=$APP_SAMOURAI_SERVER_NODE_ADMIN_KEY
export NODE_JWT_SECRET=$APP_SAMOURAI_SERVER_NODE_JWT_SECRET
# BITCOIN
export BITCOIND_IP=$RPC_HOST
export BITCOIND_RPC_PORT=$RPC_PORT
export BITCOIND_RPC_USER=$RPC_USER
export BITCOIND_RPC_PASSWORD=$RPC_PASSWORD
export BITCOIND_ZMQ_RAWTXS=28333
export BITCOIND_ZMQ_BLK_HASH=28332
# EXPLORER
export EXPLORER_INSTALL="off"
# INDEXER
export INDEXER_IP=electrs.embassy
export INDEXER_RPC_PORT=50001
export INDEXER_PROTOCOL=tcp
export INDEXER_BATCH_SUPPORT=inactive # 'active' for ElectrumX, 'inactive' otherwise

# Setting Whirlpool Environment Variables
export WHIRLPOOL_BITCOIN_NETWORK=$APP_BITCOIN_NETWORK
export WHIRLPOOL_DOJO="on"
export WHIRLPOOL_DOJO_IP=$APP_SAMOURAI_SERVER_IP

# Setting Web Server Environment Variables 
export COMMON_BTC_NETWORK=$APP_BITCOIN_NETWORK
export DOJO_LOCAL_PORT=$APP_SAMOURAI_SERVER_DOJO_PORT
export DOJO_HIDDEN_SERVICE=$APP_SAMOURAI_SERVER_DOJO_HIDDEN_SERVICE
export WHIRLPOOL_HIDDEN_SERVICE=$APP_SAMOURAI_SERVER_WHIRLPOOL_HIDDEN_SERVICE
export NODE_PREFIX_SUPPORT=support
export NODE_ADMIN_KEY=$APP_SAMOURAI_SERVER_NODE_ADMIN_KEY
export WHIRLPOOL_API_KEY=$APP_SAMOURAI_SERVER_WHIRLPOOL_API_KEY


while true; do { sleep 100; echo sleeping; } done

## Starting Dojo API
# echo "Starting Dojo..."
# /home/node/app/wait-for-it.sh ${APP_SAMOURAI_SERVER_DB_IP}:3306 --timeout=720 --strict -- /home/node/app/restart.sh &


## Starting Whirlpool
# exec tini -p SIGTERM -- 
# --listen --cli.apiKey=$APP_SAMOURAI_SERVER_WHIRLPOOL_API_KEY --cli.api.http-enable=true --cli.api.http-port=$APP_SAMOURAI_SERVER_WHIRLPOOL_PORT \
# --cli.tor=true --cli.torConfig.coordinator.enabled=true --cli.torConfig.coordinator.onion=true --cli.torConfig.backend.enabled=false \
# --cli.torConfig.backend.onion=false --cli.mix.liquidityClient=true --cli.mix.clientsPerPool=1 --resync &

# echo "Starting Web Server.."
# envsubst < /var/www/connect/js/conf.template.js > /var/www/connect/js/conf.js && /wait-for node:8080 --timeout=720 -- nginx 
