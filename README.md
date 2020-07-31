[![CircleCI](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master.svg?style=svg)](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master) ![Docker Image CI](https://github.com/yalelibrary/yul-dc-blacklight/workflows/Docker%20Image%20CI/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/yalelibrary/yul-dc-blacklight/badge.svg?branch=master)](https://coveralls.io/github/yalelibrary/yul-dc-blacklight?branch=master)

# Yale Digital Library Discovery Application

This is one of the microservices applications that form the Yale digital library.

## Development guide

### Prerequisites

- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in

### Docker Development Setup

- Checkout the project

  ```bash
  git clone https://github.com/yalelibrary/yul-dc-blacklight.git
  cd yul-dc-blacklight
  docker-compose pull blacklight
  ```

### Starting the app

- Start the blacklight service and it's dependencies This command reads the docker-compose.yml file and starts all the containers described by it including blacklight, solr, the manifest service, the management app, and a iiif image server.

  ```bash
  docker-compose up blacklight
  ```

  Output from the blackight container will display in your terminal window with Solr, Cantaloupe (IIIF), and Manifest services running in the background

- Access the blacklight app at `http://localhost:3000`

- Access the solr instance at `http://localhost:8983`

- Access the image instance at `http://localhost:8182`

- Access the manifests instance at `http://localhost`

### Accessing the blacklight container

- In a separate terminal window or tab, run:

  ```bash
  docker-compose exec blacklight bash
  ```

- You will need to be inside the container to:

  - Run migrations
  - Run bundle install
  - Access the seed file
  - Access the rails console for debugging

    ```
    bundle exec rails c
    ```

  - Run rubocop

    ```
    bundle exec rubocop -a
    ```

  - Run rspec

    ```
    bundle exec rspec
    ```

  - Rebuild the code documentation

    ```
    bundle exec rake yale:docs:blacklight
    ```

### Indexing data

- First, connect to the running management application:

  - <http://localhost:3001/management/>

- Second, pull up <http://0.0.0.0:8983> in your browser

  - Connect to the blacklight-core and execute a query to confirm no data present

- Then, in the running management application(:3001), click the button 'Index Ladybird Records to Solr'

  - When the message appears above the buttons the data has been indexed

  - Visit :8983 and run the same query again and confirm data is present

  - Connect to the running blacklight app at localhost:3000

## Pulling or Building Docker Images

Any time you pull a branch with a Gemfile change you need to pull or build a new Docker image. If you change the Dockerfile, you need to build a new Docker image. If you change a file in ./ops you need to build a new Docker image. These are the primary times in which you need to pull or build.

## When Installing a New Gem

For the most part images are created and maintained by the CI process. However, if you change the Gemfile you need to take a few extra steps. Make sure the application is running before you make your Gemfile change. Once you've updated the Gemfile, inside the container, run `bundle && nginx -s reload`. The next time you stop your running containers you need to rebuild.

## HTTP password protection

In order to prevent search engine crawling of the system before it's ready to launch, we use HTTP password protection. This is set via environment variables. Set `HTTP_PASSWORD_PROTECT='true'` to enable this feature. Set `HTTP_PASSWORD_PROTECT='false'` to disable this feature. Set the login and password via environment variables `HTTP_USERNAME` and `HTTP_PASSWORD` in the .secrets file

## Secrets

For the image instance to properly access images, you must also create a .secrets file with valid S3 credentials and basic auth credentials; see secrets-template for the correct format.

## Releasing a new version

1. Decide on a new version number. We use [semantic versioning](https://semver.org/).
2. Update the version number in `.github_changelog_generator`
3. Go through all PRs since the last release and ensure that any **features** and **bug fixes** have been tagged with the appropriate label. No need to label it unless it is a feature or a bug fix.
4. Run this command: `github_changelog_generator --token $YOUR_GITHUB_TOKEN`. This will re-generate `CHANGELOG.md`.
5. Commit and merge the changes you just made with a message like "Prep for vX.Y.Z release"
6. Once those changes are merged to the `master` branch, in the github web UI go to `Releases` and tag a new release with the right version number. Paste in the release notes for this release from the top of `CHANGELOG.md`
7. Update `yul-dc-camerata` with the new version of blacklight and submit a PR.

## Using a New Release of the Management App or other microservices

1. Go to the yul-dc-camerata repository on Github and check the latest release number in the [.env file.](https://github.com/yalelibrary/yul-dc-camerata/blob/master/.env)

2. Edit your .env file to match

3. Run `docker-compose up blacklight`

## Test coverage

We use [coveralls](https://coveralls.io/github/yalelibrary/yul-dc-blacklight) to measure test coverage. More details [here](https://github.com/yalelibrary/yul-dc-blacklight/wiki/code-coverage).
