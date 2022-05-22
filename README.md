<!-- markdownlint-disable-next-line html line_length -->
# <img style="float: left; margin-right: .2em;" src="https://raw.githubusercontent.com/fpiesche/docker-hercules/main/hercules-icon.png" alt="Hercules logo"/> Hercules in Docker

A Docker setup for building and containerising the Ragnarok Online
server emulator Hercules.

<!-- markdownlint-disable line_length -->
[![Docker images](https://github.com/fpiesche/docker-hercules/actions/workflows/build-images.yaml/badge.svg)](https://github.com/fpiesche/docker-hercules/actions/workflows/build-images.yaml)

[![hadolint](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-docker.yaml/badge.svg)](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-docker.yaml)
[![Helm](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-helm.yaml/badge.svg)](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-helm.yaml)
[![Markdown](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-markdown.yaml/badge.svg)](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-markdown.yaml)
[![Shellcheck](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-shellcheck.yaml/badge.svg)](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-shellcheck.yaml)
[![yamllint](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-yamllint.yaml/badge.svg)](https://github.com/fpiesche/docker-hercules/actions/workflows/lint-yamllint.yaml)
<!-- markdownlint-enable line_length -->

## What is this?

This repository specifically contains everything you need to build a Hercules
server with minimal effort, provided you have a working Docker installation. If
you're happy to run pre-built Docker containers made using this setup, check out
the "How do I run a Ragnarok Online server with this?" section further down.

<!-- markdownlint-disable-next-line line_length -->
If you want to know what Docker is, [here is a good overview](https://www.zdnet.com/article/what-is-docker-and-why-is-it-so-darn-popular/).

## How does this work?

The Dockerfile is a three-stage definition for Docker:

- Step 1 (`build_hercules`) will bring up a Linux (Debian Bullseye,
specifically) container, install all the necessary requirements for compiling
Hercules, build Hercules and copy all the files required for Hercules alone into
a separate distribution directory *inside the container*.

<!-- markdownlint-disable line_length -->
- Step 2 (`export_build`) will copy the distribution created in the
`build_hercules` step to an empty container. This can be used to easily copy the
build out of the build containers to your host machine by using [the `--output` parameter for `docker build`](https://docs.docker.com/engine/reference/commandline/build/#custom-build-outputs):


      docker build --target export_build \
        --output type=tar,dest=hercules.tar

  will build Hercules and save the finished build in the `hercules.tar` archive
  in your current directory.
<!-- markdownlint-enable line_length -->

- Step 3 (`build_image`) will take the build produced by the `build_hercules`
step and copy it into another Debian Bullseye container, all prepared so you can
simply run the Hercules server with a single `docker run` command.

If you just want to run a server without making your own build, there are
standard images built and published from this repository via
[automated builds](https://github.com/fpiesche/hercules-docker/actions) whenever a new version of Hercules is released.

These images are always built with the current release version of Hercules, for
Intel/AMD (most home computers), ARMv6 (Raspberry Pi 1), ARMv7 (Raspberry Pi 2
and equivalents) and ARM64 (Raspberry Pi 3 or 4 and equivalents) systems and
available in both Classic and Renewal mode.

## How do I run a Ragnarok Online server with this?

I'm making images available for both Renewal and Classic servers using both the
latest packet version supported by Hercules and packet version `20180418`, which
matches the "Noob Pack" client download available on the Hercules forums for
ease of use.

In order to run any of these images, you will of course first need to
[install Docker](https://docs.docker.com/get-docker/) on the computer you want
to run the server on.

<!-- markdownlint-disable-next-line line_length -->
Then, download the [docker-compose.yaml](https://github.com/fpiesche/hercules-docker/blob/main/docker-compose.yaml)
file from this repository and copy it somewhere. You can just use it as is to
just bring up a server, but do feel free to have a closer look at its contents.
There are a number of variables you can edit to e.g. lock down database access
more tightly.

To bring up your Ragnarok game server and the database it needs, open a command
prompt or terminal window, navigate to where you saved the `docker-compose.yaml`
file and simply run `docker-compose up -d`. Docker will download the images for
the game and database servers and start them.

If you want to watch things happen, just run `docker-compose up` to run the
services in the foreground. To exit out of this view, simply press Ctrl-C;
**NOTE** that this will shut down the services though!

You can check the status of your services with `docker ps`; this should list
both the database and game_servers containers as "running" once they have
started. They will continue running in the background even if you close the
command-line window and you should be able to create accounts and connect to the
server.

## How do I build Hercules with this?

### I'd rather build my own Docker image

Simply run `docker build . -t hercules`. This will run the build and package it
up in a local image tagged `hercules`, which you can run either with
`docker run hercules` or using the `docker-compose.yml` file (above) to bring
up an entire setup with its own database service and everything.

## I don't want to run Hercules from a Docker image. Can I just get the build?

You can run only the first stage of the Dockerfile to build Hercules without
packaging it up in an image. To just build Hercules and copy the build to your
local machine, run:

```bash
docker build . -t hercules --target export_build \
  --output type=local,dest=out.tar
```

Note that this **will** be a Linux build, so if you want to run this on a
Windows host you might need to put some more work in. I'd be happy to accept
pull requests to make this all work with and produce Windows builds, too!

## I'd rather build a Renewal server. And what about packet version [whatever]?

To build a Renewal rather than a Classic server or a specific packet version,
modify your `docker build` command with the `HERCULES_SERVER_MODE` and/or
`HERCULES_PACKET_VERSION` build arguments:

```bash
docker build . -t hercules [--target build_hercules] \
  --build-arg HERCULES_SERVER_MODE=[classic|renewal] \
  --build-arg HERCULES_PACKET_VERSION=[whatever]
```

## I'm a developer. Can I use this with my own copy of the Hercules source code?

Sure you can! Simply remove the existing `hercules` directory in this repository
and copy your copy of the source code there instead. Any builds created from
then on will be built from this copy instead.

If you already have a git repository with the Hercules source for your
modifications or plugins, you could also simply replace the submodule:

```bash
git submodule deinit hercules
rm -rf hercules
git submodule add https://github.com/me/my-hercules-repo ./hercules
```

Read up on [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
for more information on how that all works.
