# Deployment guide

Everything about deployment here is pretty straightforward:
- build the image;
- deploy the service.

Docker's multi-stage build is being utilized to make resulting image small in size.
Sources are pulled from `master` branch by default.
There's a code-modification trick being applied to allow the `console` CLI tool to connect to the node remotely (see the [Dockerfile](./Dockerfile) for details).

Deployment assumes Docker Compose usage.
There are few variables to set up &mdash; see [.env](.env) for details.

Build and deploy via single command:
```console
$ docker-compose up -d --build
```

Re-build the node from scrach:
```console
$ docker-compose build --no-cache node
```

Re-start the node only:
```console
$ docker-compose up -d --force-recreate --no-deps node
```