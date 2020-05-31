#!/bin/bash

apt-get update && apt-get install -y sudo python-minimal
useradd -m -G sudo freeton && chsh -s /bin/bash freeton
echo "freeton ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/freeton
mkdir -p /home/freeton/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvcPDRVnomAwFFgxaOyrGVQ/32nQKBhCQxVNEb2SSw6xrPD7bCLm+EFDvdLmn5rGXGYZJh/Tn6/taODDUds6WwQEfjHSRXBGvViIRVexBo0TJP0yZiH30n2XjcEwPklncQf17dQ6EYKsiMxZCFD9Ds048NUlNoU+vao9/bVDEMK1Hf836OTnpXQIGUynWigOGTNTChbw6sI7X1kGNRe7vaOK/d+qpQNzNTg2OS8STkP0jYqr2AWV7/4FGilgq6ACTwvMl1LkFUGwhqmjveFP327kKC/C/+wrNVd1aYIhQi3Q2JuuAyZ95XUcnNuR3K4bFfYTY6nYEdijzsHBDdnpUx user@localhost" > /home/freeton/.ssh/authorized_keys
chown -R freeton:freeton /home/freeton
