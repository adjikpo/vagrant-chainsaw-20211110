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
apt install -y openjdk-11-jdk

#Confirmation
java --version
echo "${color} INSTALLATION JAVA : OK "

# J'ajoute les deux clefs sur la vm
	mkdir -p /root/.ssh
	cp /vagrant/githosting_rsa /home/vagrant/.ssh/githosting_rsa
	cp /vagrant/githosting_rsa.pub /home/vagrant/.ssh/githosting_rsa.pub

	# Configuration de SSH en fonction des hosts
	cat > /home/vagrant/.ssh/config <<-MARK
	Host *
	  StrictHostKeyChecking no
	Host $GIT_HOST
	  User git
	  IdentityFile ~/.ssh/githosting_rsa
	MARK

	# Correction des permissions
	chmod 0600 /home/vagrant/.ssh/*
	chown -R vagrant:vagrant /home/vagrant/.ssh

	# Utilisation du SSH-AGENT pour charger les cl??s une fois pour toute
	# et ne pas avoir ?? retaper les password des clefs
	sed -i \
		-e '/## BEGIN PROVISION/,/## END PROVISION/d' \
		/home/vagrant/.bashrc
	cat >> /home/vagrant/.bashrc <<-MARK
	## BEGIN PROVISION
	eval \$(ssh-agent -s)
	ssh-add ~/.ssh/githosting_rsa
	## END PROVISION
	MARK

	GIT_DIR="$(basename "$GIT_REPOSITORY" |sed -e 's/.git$//')"

	# Deploy git repository
	su - vagrant -c "ssh-keyscan $GIT_HOST >> .ssh/known_hosts"
	su - vagrant -c "sort -u < .ssh/known_hosts > .ssh/known_hosts.tmp && mv .ssh/known_hosts.tmp .ssh/known_hosts"
	rm -rf "/home/vagrant/$(basename "$GIT_DIR")"
  su - vagrant -c "git clone '$GIT_REPOSITORY' '$GIT_DIR'"
	su - vagrant -c "git config --global user.name '$USER_NAME'"
	su - vagrant -c "git config --global user.email '$USER_EMAIL'"
