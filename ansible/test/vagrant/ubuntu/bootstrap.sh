#!/bin/bash

apt-get update && apt-get install -y sudo
useradd -m -G sudo freeton && chsh -s /bin/bash freeton
echo "freeton ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/freeton

