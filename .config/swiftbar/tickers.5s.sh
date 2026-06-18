#!/bin/bash
# <xbar.title>BTC Price</xbar.title>

function coinbase() {
  SYMBOL=$1
  LABEL=$2
  VALUE=$(curl -s https://api.exchange.coinbase.com/products/$SYMBOL/ticker | jq -r .bid)
  ROUNDED=$(echo -ne $VALUE | sed 's/\..*//')
  echo -ne $LABEL: \$$(LC_ALL=en_US numfmt --grouping $ROUNDED) '  '
}

function stock() {
  SYMBOL=$1
  LABEL=$1
  RESPONSE=$(curl -s https://stockanalysis.com/api/quotes/s/$SYMBOL)
  VALUE=$(echo ${RESPONSE} | jq .data.ep)
  if [[ $VALUE == "null" ]]; then
    VALUE=$(echo ${RESPONSE} | jq .data.p)
  fi
  ROUNDED=$(printf '%0.2f' $VALUE)
  echo -ne $LABEL: \$$(LC_ALL=en_US numfmt --grouping $ROUNDED) '  '
}

coinbase BTC-USD BTC
coinbase ETH-USD ETH
stock CRCL
