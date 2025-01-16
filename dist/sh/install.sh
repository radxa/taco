#!/bin/bash
AUTHOR='Akgnah <setq@radxa.com>'
VERSION='0.10'
MODEL=`tr -d '\0' < /proc/device-tree/model`
#
# taco-fan install script
#
CM3_URL='https://github.com/radxa/taco/raw/refs/heads/master/dist/sh/cm3-lite.sh'
CM4_URL='https://github.com/radxa/taco/raw/refs/heads/master/dist/sh/cm4-lite.sh'

echo
echo '*** Taco Fan install for CM3/CM4'
echo
echo '*** Please report problems to dev@radxa.com and we will try to fix.'
echo

if [[ "$MODEL" =~ 'Raspberry' ]]; then
  curl -sL $CM4_URL | sudo -E bash -
else
  curl -sL $CM3_URL | sudo -E bash -
fi
