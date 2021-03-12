#!/bin/bash
set -euxo pipefail


# ensure login credentials
vagrant cloud auth login

# create Base VM and ensure Base VM is online
vagrant box update || true
vagrant destroy -f || true
vagrant up

PROJ_ROOT=$(pwd)
BOX_NAME=FACTbox
ACCOUNT=botlabs-dev
BOX_FOLDER=createBoxForVagrantCloud
VAGRANT_BOX_FILE=VagrantBoxFile
VIRTUAL_BOX_NAME=$(vboxmanage list vms | grep FACT | head -n 1 | cut -d '"' -f 2)
VERSION=$(curl --silent "https://api.github.com/repos/fkie-cad/FACT_core/releases/latest" | jq -r .tag_name  | tr -d "v//")
VERSION=$VERSION.$(date +'%Y%m%d')

# print overview
echo "++++++++++++++++++++++++++++++"
echo "Account: " $ACCOUNT
echo "Virtualbox Name:" $VIRTUAL_BOX_NAME
echo "Vagrantbox Name:" $BOX_NAME
echo "Version: " $VERSION
echo "++++++++++++++++++++++++++++++"

# add default ssh Vagrant key
BASH_ADD_VAGRANT_KEY="wget --no-check-certificate https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O /tmp/authorized_keys;
                      cat /tmp/authorized_keys >> .ssh/authorized_keys;
                      chmod 700 .ssh;
                      chmod 600 .ssh/authorized_keys;
                      chown -R vagrant:vagrant .ssh;"
# clean VM
BASH_CLEAN_VM="sudo apt-get clean;
               sudo dd if=/dev/zero of=/EMPTY bs=1M;
               sudo rm -f /EMPTY;
               echo ''>~/.bash_history && history;"

vagrant ssh -- -t $BASH_ADD_VAGRANT_KEY
vagrant ssh -- -t $BASH_CLEAN_VM

exit
rm -rf $BOX_FOLDER
mkdir -p $BOX_FOLDER
cp $VAGRANT_BOX_FILE $BOX_FOLDER/
cd $BOX_FOLDER

# create box
vagrant package --base $VIRTUAL_BOX_NAME --output $BOX_NAME.box --vagrantfile $VAGRANT_BOX_FILE

# add box locally to Vagrant and start it for debug reasons
#vagrant box add testBox $BOX_NAME.box
#vagrant init testBox
#vagrant up

exit
# upload box
hash=$(sha1sum $BOX_NAME.box | cut -d " " -f 1)
echo "vagrant cloud publish $ACCOUNT/$BOX_NAME $VERSION virtualbox $BOX_NAME.box --box-VERSION $VERSION --force --release -c $hash -C sha1 "
vagrant cloud publish $ACCOUNT/$BOX_NAME $VERSION virtualbox $BOX_NAME.box --box-VERSION $VERSION --force --release -c $hash -C sha1

# clean
cd $PROJ_ROOT

vagrant destroy --force
rm -rf $BOX_FOLDER
rm -rf .vagrant
