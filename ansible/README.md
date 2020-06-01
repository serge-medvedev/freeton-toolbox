# FreeTON Toolbox: Ansible

## What is it?

It provides you with unified experience of deploying the validator node on Debian/Ubuntu and RedHat/CentOS.

> NOTE: this is still a work-in-progress but is going to replace the current approach based on direct usage of Docker Compose.

## Glossary

* __Controller__: the host Ansible is set up on, e.g. your home machine
* __Validator__: the host you're going to run validator node on
* __Approver__: the host you want to confirm transactions initiated during elections

## HOWTO

1. Make Controller able to communicate with Validator via ssh passwordslessly
    - generate an RSA key pair for that
      ```console
      $ ssh-keygen -b 2048 -t rsa -f /tmp/freeton-id_rsa -q -N "" # pubkey will have *.pub extension
      ```
1. Setup Validator (example for Debian/Ubuntu, refer to [this](test/vagrant/centos/bootstrap.sh) for additional steps required in RedHat/CentOS)
    - make sure _python2_ and _sudo_ are installed
      ```console
      # apt-get update && apt-get install python-minimal sudo
      ```
    - create `freeton` user and allow it to use sudo without password
      ```console
      # useradd -m -G sudo freeton
      # echo "freeton ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/freeton
      ```
    - authorize the RSA key generated on the Controller
      ```console
      # mkdir -p /home/freeton/.ssh
      # echo "<contents of freeton-id_rsa.pub>" > /home/freeton/.ssh/authorized_keys
      # chown -R freeton:freeton /home/freeton
      ```
    - make sure sshd is configured so that pubkey authentication is enabled (default);
    _optionally_ disable password authentication (recommended)
1. Deploy
    - install Ansible
    - get the Toolbox
      ```console
      $ sudo git clone https://github.com/serge-medvedev/freeton-toolbox.git /opt/freeton-toolbox
      $ sudo chown -R $(id -u):$(id -g) /opt/freeton-toolbox
      ```
    - move the RSA key pair generated at the first step to _/opt/freeton-toolbox/.secrets_
      ```console
      $ mkdir -p /opt/freeton-toolbox/.secrets
      $ mv /tmp/freeton-id_rsa* /opt/freeton-toolbox/.secrets/
      ```
    - edit the [inventory](inventory) file by specifying the Validator's IP address
    - install Ansible playbook requirements
      ```console
      $ cd /opt/freeton-toolbox/ansible
      $ ansible-galaxy install -r requirements
    - at the end of the day (figuratively) this will run the validator node
      ```console
      $ ansible-playbook -l validators bootstrap.yml
      ```
    - to be continued for the Approver...