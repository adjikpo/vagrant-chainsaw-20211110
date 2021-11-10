#!/bin/sh

set -e
set -u

USER_EMAIL=""
USER_NAME=""
GIT_HOST=""
GIT_REPOSITORY=""
HOSTNAME="$(hostname)"

if [ ! -f /vagrant/.env ]; then
	>&2 echo "ERROR: unable to find /vagrant/.env file"
	exit 1
fi
if ! grep -q '^USER_EMAIL=' /vagrant/.env ; then
	>&2 echo "ERROR: unable to find USER_EMAIL key in /vagrant/.env file"
	exit 1
fi
eval "$(grep '^USER_EMAIL=' /vagrant/.env)"

if ! grep -q '^USER_NAME=' /vagrant/.env ; then
	>&2 echo "ERROR: unable to find USER_NAME key in /vagrant/.env file"
	exit 1
fi
eval "$(grep '^USER_NAME=' /vagrant/.env)"

if ! grep -q '^GIT_HOST=' /vagrant/.env ; then
	>&2 echo "ERROR: unable to find GIT_HOST key in /vagrant/.env file"
	exit 1
fi
eval "$(grep '^GIT_HOST=' /vagrant/.env)"

if ! grep -q '^GIT_REPOSITORY=' /vagrant/.env ; then
	>&2 echo "ERROR: unable to find GIT_REPOSITORY key in /vagrant/.env file"
	exit 1
fi
eval "$(grep '^GIT_REPOSITORY=' /vagrant/.env)"

## Verifier que la paire de clefs pour GITHUB est presente avant de continuer

if [ ! -f /vagrant/githosting_rsa ]; then
	>&2 echo "ERROR: unable to find /vagrant/githosting_rsa keyfile"
	exit 1
fi
if [ ! -f /vagrant/githosting_rsa.pub ]; then
	>&2 echo "ERROR: unable to find /vagrant/githosting_rsa.pub keyfile"
	exit 1
fi

export DEBIAN_FRONTEND=noninteractive

color='\e[1;36m'

#install packages
echo "${color} INSTALLATION PKG : START"
# update the debian pkg
apt-get -qq update --allow-releaseinfo-change
apt -qq install -y \
  vim \
  git \
  tree \
  curl \
  apt-transport-https \
  ca-certificates \
  wget \
  gnupg2 \
  software-properties-common \
  net-tools \
  make
echo "${color} INSTALLATION PKG : OK "

#install java 11
echo "${color} INSTALLATION JAVA : START"
apt install openjdk-11-jdk

#Confirmation
java --version
echo "${color} INSTALLATION JAVA : OK "
