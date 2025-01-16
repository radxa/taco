#!/bin/bash
AUTHOR='Akgnah <setq@radxa.com>'
VERSION='0.10'
MODEL=`tr -d '\0' < /proc/device-tree/model`
DISTRO=`cat /etc/os-release | grep ^ID= | sed -e 's/ID\=//g'`
#
# taco-fan install script
#
DEB_URL='https://github.com/radxa/taco/raw/refs/heads/master/dist/deb/taco-fan-${VERSION}.deb'

confirm() {
  printf "%s [Y/n] " "$1"
  read resp < /dev/tty
  if [ "$resp" == "Y" ] || [ "$resp" == "y" ] || [ "$resp" == "yes" ]; then
    return 0
  fi
  if [ "$2" == "abort" ]; then
    echo -e "Abort.\n"
    exit 0
  fi
  return 1
}

apt_check() {
  packages="python3-rpi.gpio python3"
  need_packages=""

  idx=1
  for package in $packages; do
    if ! apt list --installed 2> /dev/null | grep "^$package/" > /dev/null; then
      pkg=$(echo "$packages" | cut -d " " -f $idx)
      need_packages="$need_packages $pkg"
    fi
    ((++idx))
  done

  if [ "$need_packages" != "" ]; then
    echo -e "\nPackage(s) $need_packages is required.\n"
    confirm "Would you like to apt-get install the packages?" "abort"
    apt-get update
    apt-get install --no-install-recommends $need_packages -y
  fi
}

deb_install() {
  TEMP_DEB="$(mktemp)"
  curl -sL "$DEB_URL" -o "$TEMP_DEB"
  dpkg -i "$TEMP_DEB"
  rm -f "$TEMP_DEB"
}


apt_check
deb_install
