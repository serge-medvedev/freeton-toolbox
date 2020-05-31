# FreeTON Toolbox: Ansible

## What is it?

It provides you with unified experience of deploying the validator node on Debian/Ubuntu and RedHat/CentOS.

> NOTE: this is still a work-in-progress but is going to replace the current approach based on direct usage of Docker Compose.

## Glossary

* __Controller__: the host Ansible is set up on, e.g. your home machine
* __Validator__: the host you're going to run validator node on
* __Approver__: the host you want to confirm transactions initiated during elections

## HOWTO

1. Install Ansible on the Controller
1. Edit the [inventory](inventory) file by specifying the Validator's IP address
1. Setup Validator
    - create `freeton` user and allow it to use sudo without password(e.g., on Debian/Ubuntu)
      ```shell
      # apt-get update && apt-get install -y sudo
      # useradd -m -G sudo freeton
      # echo "freeton ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/freeton
      ```
      > NOTE: refer [this](test/vagrant/centos/bootstrap.sh) for additional steps required in RedHat/CentOS
    - make sure sshd is configured so that pubkey authentication is enabled (default);
    _optionally_ disable password authentication (recommended)
1. On the Controller, create an RSA key pair and authorize it on the Validator for the `freeton` user
    - generate keys and store them in _/opt/freeton-toolbox/.secrets_ folder (create if not exist and chown to yourself)
      ```shell
      $ ssh-keygen -b 2048 -t rsa -f /opt/freeton-toolbox/.secrets/freeton-id_rsa -q -N ""
      ```
    - authorize it to be able to login as the `freeton` user
      ```shell
      $ ssh-copy-id -i /opt/freeton-toolbox/.secrets/freeton-id_rsa freeton@1.2.3.4 # where 1.2.3.4 is the Validator's IP address
      ```
    - ensure you're able to login
      ```shell
      $ ssh -i /opt/freeton-toolbox/.secrets/freeton-id_rsa freeton@1.2.3.4
      ```
1. Deploy
    - at the end of the day (figuratively) this will run the validator node
      ```shell
      $ ansible-playbook -l validators bootstrap.yml
      ```
    - to be continued for the Approver...