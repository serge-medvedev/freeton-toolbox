#!/bin/bash

yum update -y && yum install -y sudo
useradd -m -G wheel freeton
echo "freeton ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/freeton
mkdir /home/freeton/.ssh && restorecon -R -v /home/freeton/.ssh

