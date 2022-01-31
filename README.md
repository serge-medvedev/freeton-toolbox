# [REPO IS ARCHIVED] Re-structured and maintained version lives [here](https://github.com/everscale-tools/dockerfiles)

# FreeTON Toolbox

## What is it good for?

This toolbox allows you to:
- have a validator node up & running in no time (almost)
- automatically participate in validators elections
- monitor your setup via informative dashboard based on TICK stack

Additionally you'll be able to analyze validator's logs, parsed and ready to be aggregated, grouped and filtered.

![dashboard view](gallery/dashboard-1.png)

## Approach
Everything is dockerized so that you, for instance, can (re-)build validator node from scratch with a single command.

Docker handles crashes and restarts service automatically.

## Disclaimer
Details of installation and setup of tools mentioned below, e.g. Docker or Docker Compose, are out of scope of this guide.

## Validator setup
We'll be running validator node in a Docker container so you'll need __Docker__ and __Docker Compose__ installed.
Also we'll need __git__ to clone this repo :)

0. Make sure you're able to run `docker` and `docker-compose` commands without using `sudo`
    ```bash
    ### By default those commands require sudo. Add yourself to the 'docker' group to change it:
    $ sudo usermod -aG docker $(id -un)
    ### Re-login:
    $ su - $(id -un)
    ```

1. Run the folder structure initialization script
    ```bash
    $ export FSINIT_URL=https://raw.githubusercontent.com/serge-medvedev/freeton-toolbox/master/fsinit.sh
    $ curl -s "$FSINIT_URL" | sudo bash -s $(id -u) $(id -g)
    ```

2. Build the image and run the container

    > NOTE: For the fastest syncing with the network we'll use `tmpfs` bind mount.
    The process is fully automatic: when fastsync is completed, the data will be moved to persistent storage and the node - restarted.
    In the future `tmpfs` approach will be rather impossible due to DB growth but for now it works just well.

    ```bash
    $ cd /opt/freeton-toolbox/validator
    $ docker-compose build --build-arg EXTERNAL_UID=$(id -u) --build-arg EXTERNAL_GID=$(id -g) freeton-validator-dev
    ### Run the validator container:
    $ docker-compose up -d freeton-validator-dev
    ### Let the validator start syncing and after a while you'll be able to see its status by doing this:
    $ docker-compose exec freeton-validator-dev ./check_node_sync_status.sh
    ### Validator logs may be monitored with another one (press Ctrl+C to exit):
    $ docker-compose logs --tail 500 --follow freeton-validator-dev
    ```

3. Run FreeTON Staking Manager
    ```bash
    $ docker-compose up -d freeton-staking-manager
    ```

4. Now, you might want to set up the dashboard to visualize some of the runtime metrics.
    ```bash
    $ docker-compose up -d influxdb telegraf chronograf
    ```
    Open the Chronograf in your browser by visiting `http://<your server ip>:8888`, go to the 'Dashboards' tab and add a new one by importing [the config](validator/tick/dashboard.json).
    You may need to modify network interface name in the 'Network Usage' visualization.

That's it! Your validator node is all set.

## Operator setup

This one is much simpler. We'll have to run a periodic [cron job](operator/crontab) to monitor transactions initiated by the Validator and confirm them locally.

1. Repeat steps 0 and 1 of the previous section

2. Put the custodian keys in `/opt/freeton-toolbox/.secrets/deploy.keys.json`

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

4. Install `jq`
    ```bash
    ### Debian/Ubuntu
    $ sudo apt-get install jq
    ### RedHat/CentOS
    $ sudo yum install jq
    ```
5. Review [a job script](operator/transactions-monitor.sh) and import the crontab
    ```bash
    $ crontab /opt/freeton-toolbox/operator/crontab
    ```

That's it! Your setup is ready to automatically confirm transactions intiated by the Validator.

## Roadmap
- add Ansible Playbook(s) to automate software installation and setup operations (in progress)
- add actionable alerts (via Kapacitor, in progress)
