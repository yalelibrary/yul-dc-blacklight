[![CircleCI](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master.svg?style=svg)](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master)

# Prerequisites
- Download [Docker Dekstop](https://www.docker.com/products/docker-desktop) and log in


# Docker Development Setup
### If this is your first time working in this repo, build the base service (dependencies, etc. that don't change)
  ``` bash
  docker-compose build base
  ```

### If this is your first time working in this repo or the Dockerfile has been updated you will need to (re)build your services
  ``` bash
  docker-compose build web
  ```

### Starting the app
- Start the web service
  ``` bash
  docker-compose up web
  ```
- Access the web app at `http://localhost:3000`
- Access the solr instance at `http://localhost:8983`
- Access the image instance at `http://localhost:8182`
- Access the manifests instance at `http://localhost`

##### Accessing the web container
- Navigate to the app root directory in another tab and run:
  ``` bash
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


# Customizing Blacklight:
There are many ways to override specific behaviors and views in Blacklight. Because Blacklight is distributed as a Rails engine-based gem, all customization of Blacklight behavior should be done within your application by overriding Blacklight-provided behaviors with your own.

- To modify this text, you need to [override the Blacklight-provided view](http://guides.rubyonrails.org/engines.html#improving-engine-functionality). You can copy this file, located in the blacklight gem: `/usr/local/rvm/gems/ruby-2.6.5/gems/blacklight-7.7.0/app/views/catalog/_home_text.html.erb`
to your own application: `/home/app/webapp/app/views/catalog/_home_text.html.erb`
- [Index your own data](https://github.com/projectblacklight/blacklight/wiki/Indexing-your-data-into-solr) into Solr
- [Configure Blacklight](https://github.com/projectblacklight/blacklight/wiki#blacklight-configuration) to match your data and user-experience needs
