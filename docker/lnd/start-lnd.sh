#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# error function is used within a bash function in order to send the error
# message directly to the stderr output and exit.
error() {
    echo "$1" > /dev/stderr
    exit 0
}

# return is used within bash function in order to return the value.
return() {
    echo "$1"
}

# set_default function gives the ability to move the setting of default
# env variable from docker file to the script thereby giving the ability to the
# user override it during container start.
set_default() {
    # docker initialized env variables with blank string and we can't just
    # use -z flag as usually.
    BLANK_STRING='""'

    VARIABLE="$1"
    DEFAULT="$2"

    if [[ -z "$VARIABLE" || "$VARIABLE" == "$BLANK_STRING" ]]; then

        if [ -z "$DEFAULT" ]; then
            error "You should specify default variable"
        else
            VARIABLE="$DEFAULT"
        fi
    fi

   return "$VARIABLE"
}

# Set default variables if needed.
RPCHOST=$(set_default "$RPCHOST" "127.0.0.1")
ZMQ_PUBRAWBLOCK=$(set_default "$ZMQ_PUBRAWBLOCK" "tcp://127.0.0.1:28332")
ZMQ_PUBRAWTX=$(set_default "$ZMQ_PUBRAWTX" "tcp://127.0.0.1:28333")
RPCUSER=$(set_default "$RPCUSER" "devuser")
RPCPASS=$(set_default "$RPCPASS" "devpass")
DEBUG=$(set_default "$DEBUG" "debug")
NETWORK=$(set_default "$NETWORK" "simnet")
CHAIN=$(set_default "$CHAIN" "bitcoin")
BITCOIN_NODE=$(set_default "$BITCOIN_NODE" "bitcoind")
BACKEND="bitcoind"

RPC_LISTEN=$(set_default "$RPC_LISTEN" ":10009")
REST_LISTEN=$(set_default "$REST_LISTEN" ":8080")
LISTEN=$(set_default "$LISTEN" ":9735")


exec lnd \
    --rpclisten="$RPC_LISTEN" \
    --restlisten="$REST_LISTEN" \
    --listen="$LISTEN" \
    --tlsextradomain="lnd-$NETWORK" \
    --noseedbackup \
    --logdir="/data" \
    "--$CHAIN.active" \
    "--$CHAIN.$NETWORK" \
    "--$CHAIN.node"="$BITCOIN_NODE" \
    "--$BACKEND.zmqpubrawblock"="$ZMQ_PUBRAWBLOCK" \
    "--$BACKEND.zmqpubrawtx"="$ZMQ_PUBRAWTX" \
    "--$BACKEND.rpchost"="$RPCHOST" \
    "--$BACKEND.rpcuser"="$RPCUSER" \
    "--$BACKEND.rpcpass"="$RPCPASS" \
    --debuglevel="$DEBUG" \
    "$@"
