# Vagrantfile  - FACT_box
This repo provides a Vagrantfile to simply test and evaluate the [FACT](https://github.com/fkie-cad/FACT_core) framework.

The box is made to boot in the background and forwards the webinterface to the local machine.
Just visit the following address to use FACT.

* http://localhost:5000

It is not required to access the box after boot.


## System requirements
Please keep in mind that FACT requests a lot of system resources. Therefore, the Vagrant VM will be build
with the follwing specs:

  * vb.cpus = 4
  * vb.memory = "12288"
  * config.disksize.size = "100GB"

Also, since the FACT_box freshly installs FACT, the whole setup needs roughly 1 hour to build. Use this time and call your mom.

## Installation steps

  ```
  $ sudo apt-get install vagrant virtualbox
  $ vagrant plugin install vagrant-reload vagrant-disksize  # reboot vm and resize disk
  $ git clone git@github.com:botlabsDev/FACT_box.git
  $ cd FACT_box
  $ vagrant up
  ```

## Troubleshooting
The following section lists known problems and fixes.

### ssh timeouts by provisioning
Sometimes the system provisioning stops after the required reboot. Rerun the command`vagrant reload` should fix this problem.
