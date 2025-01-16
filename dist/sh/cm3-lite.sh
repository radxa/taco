#!/bin/bash
AUTHOR='Akgnah <setq@radxa.com>'
VERSION='0.10'
#
# taco-fan install script
#

cat > /usr/bin/taco-cm3-lite.sh << \EOF
#!/bin/bash
AUTHOR='Akgnah <setq@radxa.com>'
VERSION='0.10'
#
# Taco cm3 fan
#
BASE_PATH=/sys/class/gpio
TEMP_FILE=/sys/class/thermal/thermal_zone0/temp
FAN=22
LOW=0
HIGH=1

export_pin() {
  if [[ ! -e $BASE_PATH/gpio$1 ]]; then
    echo "$1" > $BASE_PATH/export
  fi
}

unexport_pin() {
  if [[ -e $BASE_PATH/gpio$1 ]]; then
    echo "$1" > $BASE_PATH/unexport
  fi
}

set_mode() {
  export_pin $1
  echo "out" > $BASE_PATH/gpio$1/direction
  echo "$2" > $BASE_PATH/gpio$1/value
  if [[ "$3" == "clean" ]]; then
    unexport_pin $1
  fi
}

turn_on() {
  set_mode $FAN $HIGH
}

turn_off() {
  set_mode $FAN $LOW clean
}

trap turn_off SIGINT

function get_temp() {
  if [[ "$(cat $TEMP_FILE)" -gt "50000" ]]; then
    turn_on
  else
    turn_off
  fi
}

if [[ $1 == "on" ]]; then
  turn_on
else
  turn_off
  exit 0
fi

for (( ; ; ))
do
  sleep 30s
  get_temp
done

exit 0
EOF

chmod +x /usr/bin/taco-cm3-lite.sh

cat > /lib/systemd/system/taco-cm3-lite.service << EOF
[Unit]
Description=Taco cm3 fan

[Service]
ExecStart=/usr/bin/taco-cm3-lite.sh on
ExecStop=/usr/bin/taco-cm3-lite.sh off
Type=simple

[Install]
WantedBy=multi-user.target
EOF

systemctl enable taco-cm3-lite.service

if [ -d /run/systemd/system ]; then
  systemctl --system daemon-reload > /dev/null || true
fi

systemctl start taco-cm3-lite.service > /dev/null
