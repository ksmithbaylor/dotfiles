#!/bin/bash

curl -s 'https://wttr.in/Canton+GA?format=3' | sed 's/.*: //' | sed 's/\+//'
