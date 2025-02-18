[![CircleCI](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/main.svg?style=svg)](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/main) ![Docker Image CI](https://github.com/yalelibrary/yul-dc-blacklight/workflows/Docker%20Image%20CI/badge.svg)

# Table of contents

- [Prerequisites](#prerequisites)
- [Quick Start Guide](#quick-start-guide)
- [Docker Development Setup](#docker-development-setup)
- [Install Camerata](#install-camerata)
- [Update Camerata](#update-camerata)
- [General Use](#general-use)
- [Troubleshooting](#troubleshooting)
- [Pulling or Building Docker Images](#pulling-or-building-docker-images)
- [When Installing a New Gem](#when-installing-a-new-gem)
- [Deploy an individual branch](#deploy-an-individual-branch)
- [Test coverage](#test-coverage)

# Yale Digital Library Discovery Application

This is one of the microservices applications that form the Yale digital library.

### Prerequisites

- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in

# Quick Start Guide

- To start the application without VPN and without management: 

```bash
git clone git@github.com:yalelibrary/yul-dc-camerata.git
cd yul-dc-camerata
bundle install
rake install
```
cd back into your main directory.

```
git clone git@github.com:yalelibrary/yul-dc-blacklight.git
cd yul-dc-blacklight
cam build
VPN=false cam up blacklight --without management
access at localhost:3000
```
If you get a bundle gem issue, open a new terminal window or tab and with the running blacklight server, run: 
```bash
  cam bundle blacklight
```

- To bash into containers and run specs: 

With the application already started: 
```
cam sh blacklight
bundle exec rspec spec/file/path
```

# Docker Development Setup

```bash
git clone https://github.com/yalelibrary/yul-dc-blacklight.git
```

### Change to the application directory

```bash
cd ./yul-dc-blacklight
```

### Create needed files on your command line

```bash
touch .secrets
```

### If this is your first time working in this repo or the Dockerfile has been updated you will need to pull your services

```bash
  docker-compose pull blacklight
```

### Install Camerata

Clone the yul-dc-camerata repo and install the gem.

```bash
git clone git@github.com:yalelibrary/yul-dc-camerata.git
cd yul-dc-camerata
bundle install
rake install
```

### Update Camerata

- You can get the latest version at any point by updating the code and reinstalling

```bash
cd yul-dc-camerata
git pull origin main
bundle install
rake install
```

### Dynatrace

- We've integrated Dynatrace OneAgent for monitoring our Docker container environments.
  - Instructions on configuring OneAgent can be found [here](https://github.com/yalelibrary/yul-dc-camerata/tree/main/base)

# General Use

Once camerata is installed on your system, interactions happen through the camerata command-line tool or through its alias `cam`. The camerata tool can be used to bring the development stack up and down locally, interact with the docker containers, deploy, run the smoke tests and otherwise do development tasks common to the various applications in the yul-dc application stack.

All buildin commands can be listed with `cam help` and individual usage information is available with `cam help COMMAND`. Please note that deployment commands (found in the `./bin` directory) are passed through and are therefore not listed by the help command. See the usage for those below.

To start the application stack, run `cam up` in the blacklight directory. This starts all of the applications as they are all dependencies of yul-blacklight. Camerata is smart. If you start `cam up` from a blacklight code check out it will mount that code for local development (changes to the outside code will affect the inside container). If you start the `cam up` from the blacklight application you will get the blacklight code mounted for local development and the blacklight code will run as it is in the downloaded image. You can also start the two applications both mounted for development by starting the blacklight application with `--without management` and the managment application `--without solr --withouth db` each from their respective code checkouts.

- Access the blacklight app at `http://localhost:3000`

- Access the solr instance at `http://localhost:8983`

- Access the image instance at `http://localhost:8182`

- Access the manifests instance at `http://localhost`

- Access the management app at `http://localhost:3001/management`

  - If you cannot access this url, try the [troubleshooting steps](#accessing-the-management-app)

### Troubleshooting
- See the [wiki](https://github.com/yalelibrary/yul-dc-documentation/wiki/Blacklight-Development-Setup#troubleshooting) for further information on troubleshooting.

### Running `bundle install`

- In a separate terminal window or tab than the running blacklight server, run:

  ```bash
  cam bundle blacklight
  ```

### Accessing the blacklight container
- See the [wiki](https://github.com/yalelibrary/yul-dc-documentation/wiki/Blacklight-Development-Setup#accessing-the-blacklight-container) for further information on containers.

### Indexing data
- See the [wiki](https://github.com/yalelibrary/yul-dc-documentation/wiki/Blacklight-Development-Setup#accessing-the-blacklight-container) for information on indexing data.

## Pulling or Building Docker Images

Any time you pull a branch with a Gemfile change you need to pull or build a new Docker image. If you change the Dockerfile, you need to build a new Docker image. If you change a file in ./ops you need to build a new Docker image. These are the primary times in which you need to pull or build.

## When Installing a New Gem

For the most part images are created and maintained by the CI process. However, if you change the Gemfile you need to take a few extra steps. Make sure the application is running before you make your Gemfile change. Once you've updated the Gemfile, inside the container, run `bundle && nginx -s reload`. The next time you stop your running containers you need to rebuild.

## HTTP password protection

In order to prevent search engine crawling of the system before it's ready to launch, we use HTTP password protection. This is set via environment variables. Set `HTTP_PASSWORD_PROTECT='true'` to enable this feature. Set `HTTP_PASSWORD_PROTECT='false'` to disable this feature. Set the log in and password via environment variables `HTTP_USERNAME` and `HTTP_PASSWORD` in the .secrets file

## Secrets

For the image instance to properly access images, you must also create a .secrets file with valid S3 credentials and basic auth credentials; see secrets-template for the correct format.

## Releasing a new version of Blacklight
Refer to the steps in the [Camerata repo](https://github.com/yalelibrary/yul-dc-camerata#releasing-a-new-app-version)

## Deploy an individual branch
Refer to the steps in the [Camerata repo](https://github.com/yalelibrary/yul-dc-camerata#deploy-a-branch)

## Using a New Release of the Management App or other microservices

1. Go to the yul-dc-camerata repository on Github and check the latest release number in the [.env file.](https://github.com/yalelibrary/yul-dc-camerata/blob/main/.env)

2. Edit your .env file to match

3. Run `docker-compose up blacklight`

## Writing Integration Tests

Integration tests run without styling by default. This allows for more stable tests involving Capybara and loads the pages faster.

If styling is needed for a test to pass, tag the test with `style:true`

## Test coverage

We use [simplecov](https://app.circleci.com/pipelines/github/yalelibrary/yul-dc-blacklight) to measure test coverage. More details [here](https://github.com/yalelibrary/yul-dc-documentation/wiki/Code-Coverage).

## Testing IP Access Restrictions

By default, when running locally, your IP will not be considered "On Campus," so you will not be able to view Yale Community Only items unless you log in.

To test having an IP which is considered "On Campus" so that you can view Yale Community Only items without logging in, start with `YALE_NETWORK_IPS=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.1 cam up`.
