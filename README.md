# FreeTON Toolbox

## What is it good for?

This toolbox allows you to:
- have a validator node up & running in no time (almost)
- automatically participate in validators elections (confirming multisig transactions)

## Approach
The main idea is to use trusted mail server as a message broker to send notifications from the Validator to the Operator &ndash; separate entity which confirms transactions with its custodian key pair. There may be more than one Operator.

## Disclaimer
All you'll see below works well for me on the __TESTNET__. I didn't test it on the MAINNET.

Details of installation and setup of tools mentioned below, i.e. Docker, Docker Compose, cron, msmtp and imapfilter are out of scope of this guide, though Toolbox provides you with sample config files which require minimal modifications to get the job done.

## Validator setup
We'll be running validator node in a Docker container so you'll need __Docker__ and __Docker Compose__ installed.
Validator script is required to be run periodically so we'll need some kind of __cron__ (e.g. cronie or fcron).
To send email notifications we'll use __msmtp__ utility (see the [configuration file sample](validator/msmtp/msmtprc)).
Also we'll need __git__ to clone this repo :)

1. Start by adding yourself to the `docker` group to be able to run `docker` and `docker-commpose` commands without `sudo`
    ```bash
    $ sudo usermod -aG docker <your user id>
    ```

2. Get the Toolbox
    ```bash
    ### Create a home for the Toolbox. This requires root priviledges.
    $ sudo mkdir /opt/freeton-toolbox
    ### Change the owner of that directory to your non-root user:
    $ sudo chown <your user id>:<your primary group id> /opt/freeton-toolbox
    ### Clone the repo to /opt/freeton-toolbox directory:
    $ git clone https://github.com/serge-medvedev/freeton-toolbox.git /opt/freeton-toolbox
    ```

3. Create a dedicated directory for the [cron job](validator/crontab) logs
    ```bash
    $ sudo mkdir -p /var/log/freeton-toolbox
    ### Change the owner of that directory to your non-root user since the cron job will run without root priviledges:
    $ sudo chown <your user id>:<your primary group id> /var/log/freeton-toolbox
    ```

4. Build the image and run the container

    For the fastest syncing with the network we'll use `tmpfs` bind mount to store the DB and regular disk volume to store the backup. It means that validator machine must have enough RAM, swap and disk space to contain the FreeTON DB.
    
    In the future `tmpfs` approach will be rather impossible due to DB growth but for now it works just well.

    ```bash
    $ cd /opt/freeton-toolbox/validator
    $ docker-compose build --build-arg EXTERNAL_UID=$(id -u) --build-arg EXTERNAL_GID=$(id -g)
    ### Run the validator container:
    $ docker-compose up -d
    ### Let the validator start syncing and after a while you'll be able to see its status by doing this:
    $ docker-compose exec freeton-validator-dev ./check_node_sync_status.sh
    ### Validator logs may be monitored with another one (press Ctrl+C to exit):
    $ docker-compose logs --tail 500 --follow freeton-validator-dev
    ```

5. When the validator node is synced, import the crontab to periodically run the validator script
    ```bash
    ### IMPORTANT: before you continue, change the fake email address with a valid recipient's one in the crontab file!
    ### Also, you may want to change the stake amount which is specified there, too.
    $ crontab /opt/freeton-toolbox/validator/crontab
    ```

That's it! Your validator node is all set.

## Operator setup

This one is much simpler. We'll have to run a periodic [cron job](operator/crontab) to get email notifications sent by the Validator and confirm those transactions locally. To do this we'll be using __imapfilter__ utility (see the [configuration file sample](operator/imapfilter/config.lua)) for dealing with emails and dockerized version of `tonos-cli` utility for dealing with transactions.

1. Repeat steps 1, 2 and 3 of the previous section

2. Put custodian keys in the file `/opt/freeton-toolbox/.secrets/deploy.keys.json`

3. Build the `tonos-cli` image:
    ```bash
    $ cd /opt/freeton-toolbox/tonos-cli
    ### Build the image.
    $ docker-compose build
    ### Now it can be used like that:
    $ docker-compose run --rm tonos-cli-dev run -1:e76112c3834a0253af3443296349f90c7a5439c08f9675f442d50df37a03fc5c getCustodians '{}'
    ### To show the help message run:
    $ docker-compose run --rm tonos-cli-dev --help
    ```

    Note the presense of config files ([one](tonos-cli/tonlabs-cli.conf-dev.json), [two](tonos-cli/tonlabs-cli.conf.json)) which are being used to store default values keeping your commands nice and clear.

4. Import the crontab to periodically run __imapfilter__ to check email notifications
    ```bash
    $ crontab /opt/freeton-toolbox/operator/crontab
    ```

    __IMPORTANT__: cron job handles __ONLY UNREAD__ messages, thus if you want to read them (e.g. on your phone), don't forget to mark them unread afterwards.

That's it! Your setup is ready to automatically confirm transactions intiated by the Validator.

## Roadmap
- add Ansible Playbook(s) to automate software installation and setup operations
