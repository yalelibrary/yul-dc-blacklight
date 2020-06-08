[![CircleCI](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master.svg?style=svg)](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master) ![Docker Image CI](https://github.com/yalelibrary/yul-dc-blacklight/workflows/Docker%20Image%20CI/badge.svg)

# Yale Digital Library Discovery Application

This is one of the microservices applications that form the Yale digital library.

## Development guide

### Prerequisites

- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in

### Docker Development Setup

- If this is your first time working in this repo or the Dockerfile.base has been updated, (re)build the base service (dependencies, etc. that don't change often)

  ```bash
      docker-compose build base
  ```

- If this is your first time working in this repo or the Dockerfile has been updated you will need to (re)build those services

  ```bash
    docker-compose build
  ```

### Starting the app

- Start the blacklight service

  ```bash
  docker-compose up
  ```

- Access the blacklight app at `http://localhost:3000`

- Access the solr instance at `http://localhost:8983`

- Access the image instance at `http://localhost:8182`

- Access the manifests instance at `http://localhost`

### Accessing the blacklight container

- Navigate to the app root directory in another tab and run:

  ```bash
  docker-compose exec blacklight bash
  ```

- You will need to be inside the container to:

  - Run migrations
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

- First, connect to the running management application container:

  ```bash
    docker-compose exec management bash
  ```

- Then, on that running management container:

  ```bash
  SOLR_CORE=blacklight-core bundle exec rake yale:index_fixture_data
  ```

## Using the Makefile

You can also use the Makefile to build an image locally, and/or push it to dockerhub:

```
make build <- build the blacklight image

make push <-push an already build image

make build push <-build and then push the image up to dockerhub
```

When you use make build, a new blacklight image is built, and tagged as both :latest, and the current git sha. When pushing to dockerhub, only the git sha version is pushed.

```
yalelibraryit/dc-blacklight        d915b32 <-git sha   1c2d8977cf5b <- note same image id
yalelibraryit/dc-blacklight        latest              1c2d8977cf5b
```

In the case above, only yalelibraryit/dc-blacklight:d915b32 will be available on dockerhub.

## Environment Variables for Development

Create .env.development to override anything in .env. The following values must be overridden.

```
SOLR_URL=http://solr:8983/solr/blacklight-core
POSTGRES_HOST=db
IIIF_MANIFESTS_BASE_URL=http://localhost/manifests/
```

## HTTP password protection

In order to prevent search engine crawling of the system before it's ready to launch, we use HTTP password protection. This is set via environment variables. Set `HTTP_PASSWORD_PROTECT='true'` to enable this feature. Set `HTTP_PASSWORD_PROTECT='false'` to disable this feature. Set the login and password via environment variables `HTTP_USERNAME` and `HTTP_PASSWORD`

## Releasing a new version

1. Decide on a new version number. We use [semantic versioning](https://semver.org/).
2. Update the version number in `.github_changelog_generator`
3. github_changelog_generator --user yalelibrary --project yul-dc-blacklight --token $YOUR_GITHUB_TOKEN
4. Commit and merge the changes you just made.
5. Once those changes are merged to the `master` branch, in the github web UI go to `Releases` and tag a new release with the right version number. Paste in the release notes for this version from the changelog you generated. In the release notes, split out `Features`, `Bug Fixes`, and `Other`
6. Once the CI build has completed for `master`, tag and push a docker hub image with the same release number:

  ```
  docker pull yalelibraryit/dc-blacklight:f93089f70e18d6c6d77ee1a6b3b4866b6d284078 <-- the tag created by circleci
  docker tag yalelibraryit/dc-blacklight:f93089f70e18d6c6d77ee1a6b3b4866b6d284078 yalelibraryit/dc-blacklight:v1.2.1 <-- the new, semantically versioned tag
  docker push yalelibraryit/dc-blacklight:v1.2.1 <-- now our semantically versioned tag will be available from docker hub
  ```

7. Update `yul-dc-camerata` with the new version of blacklight and submit a PR.
