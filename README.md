[![CircleCI](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master.svg?style=svg)](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master) ![Docker Image CI](https://github.com/yalelibrary/yul-dc-blacklight/workflows/Docker%20Image%20CI/badge.svg)

# Prerequisites

- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in

# Docker Development Setup

## If this is your first time working in this repo, build the base service (dependencies, etc. that don't change)

```bash
  docker-compose build base
```

## If this is your first time working in this repo or the Dockerfile has been updated you will need to (re)build your services

```bash
  docker-compose build web
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
In order to prevent search engine crawling of the system before it's ready to launch, we use HTTP password protection. This is set via environment variables.
Set `HTTP_PASSWORD_PROTECT='true'` to enable this feature.
Set `HTTP_PASSWORD_PROTECT='false'` to disable this feature.
Set the login and password via environment variables `HTTP_USERNAME` and `HTTP_PASSWORD`

## Starting the app

- Start the web service

  ```bash
  docker-compose up web
  ```

- Access the web app at `http://localhost:3000`
- Access the solr instance at `http://localhost:8983`
- Access the image instance at `http://localhost:8182`
- Access the manifests instance at `http://localhost`

### Accessing the web container

- Navigate to the app root directory in another tab and run:

  ```bash
  docker-compose exec web bash
  ```

- You will need to be inside the container to:

  - Run migrations
  - Access the seed file
  - Access the rails console for debugging

    ```
    bundle exec rails c
    ```

  - Index sample data (if you press "search" and don't have data, run this command)

    ```
    bundle exec rake yale:load_voyager_sample_data
    ```
  - Run rubocop
    ```
    bundle exec rubocop -a
    ```
  - Run rspec
    ```
    bundle exec rspec
    ```

# Customizing Blacklight:

There are many ways to override specific behaviors and views in Blacklight. Because Blacklight is distributed as a Rails engine-based gem, all customization of Blacklight behavior should be done within your application by overriding Blacklight-provided behaviors with your own.

- To modify this text, you need to [override the Blacklight-provided view](http://guides.rubyonrails.org/engines.html#improving-engine-functionality). You can copy this file, located in the blacklight gem: `/usr/local/rvm/gems/ruby-2.6.5/gems/blacklight-7.7.0/app/views/catalog/_home_text.html.erb` to your own application: `/home/app/webapp/app/views/catalog/_home_text.html.erb`
- [Index your own data](https://github.com/projectblacklight/blacklight/wiki/Indexing-your-data-into-solr) into Solr
- [Configure Blacklight](https://github.com/projectblacklight/blacklight/wiki#blacklight-configuration) to match your data and user-experience needs
