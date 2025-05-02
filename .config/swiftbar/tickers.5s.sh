#!/bin/bash
# <xbar.title>BTC Price</xbar.title>

function ticker() {
  SYMBOL=$1
  LABEL=$2
  VALUE=$(curl -s https://api.exchange.coinbase.com/products/$SYMBOL/ticker | jq -r .bid)
  ROUNDED=$(echo -ne $VALUE | sed 's/\..*//')
  echo -ne $LABEL: \$$(LC_ALL=en_US numfmt --grouping $ROUNDED) '  '
}

ticker BTC-USD BTC
ticker ETH-USD ETH
