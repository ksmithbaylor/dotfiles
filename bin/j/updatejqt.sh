#!/bin/bash
#
# update (or install) the qtide binaries
#
# run from the J install directory

cd "$(dirname "$0")"
bin/jconsole -js "exit install'qtide'"
