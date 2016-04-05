#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

set -x
export OPENEDX_RELEASE=$1
CONFIG_REPO=https://github.com/chenriksson/configuration.git
CONFIG_VERSION=appsembler/azureDeploy

echo "Starting Open edX fullstack install on pid $$"
date
ps axjf

# update and install prerequisites
time sudo apt-get -y update && sudo apt-get -y upgrade
time sudo apt-get install -y build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev libfreetype6-dev python-pip python-apt python-dev libxmlsec1-dev swig
time sudo pip install pip==7.1.2
time sudo pip install --upgrade virtualenv

# gather Open edX configuration
mv server-vars.yml /tmp
cat > /tmp/extra-vars.yml <<EOL
---
edx_platform_version: "$OPENEDX_RELEASE"
certs_version: "$OPENEDX_RELEASE"
forum_version: "$OPENEDX_RELEASE"
xqueue_version: "$OPENEDX_RELEASE"
configuration_version: "$CONFIG_VERSION"
edx_ansible_source_repo: "$CONFIG_REPO"

EOL

# install Open edX
cd /tmp
time git clone $CONFIG_REPO
cd configuration
time git checkout $CONFIG_VERSION
time sudo pip install -r requirements.txt
cd playbooks

sudo ansible-playbook -i localhost, -c local vagrant-fullstack.yml -e@/tmp/server-vars.yml -e@/tmp/extra-vars.yml

# save config for update
cp /tmp/server-vars.yml /edx/app/edx_ansible
cp /tmp/extra-vars.yml /edx/app/edx_ansible

date
echo "Completed Open edX fullstack install on pid $$"