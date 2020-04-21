[![CircleCI](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master.svg?style=svg)](https://circleci.com/gh/yalelibrary/yul-dc-blacklight/tree/master)

# Running with Docker (recommended)

1. docker-compose build base
2. docker-compose build web
3. docker-compose up web
4. docker-compose exec web bash <-- to connect to the container

You should now be able to access your rails app at `http://localhost` and your solr instance at `http://localhost:8983`

## Indexing sample data

`bundle exec rake yale:load_voyager_sample_data`

# Not encouraged: Running locally

## Prerequisites

- Download [Postgresql](https://postgresapp.com/)
- Install bundle - `gem install bundler`

## Get Started

- Open the Postgresql app and press the "start" button
- Navigate to the repo in your terminal and run `bundle install`
- Run `rake db:create`

  - this should create a "blacklight_yul_development" database and a "blacklight_yul_test" database

- Run `rake db:migrate`

- Start the solr_wrapper

  ```bash
  bundle exec solr_wrapper
  ```

- Start the server

  ```bash
  rails s
  ```

- Visit <http://localhost:3000/>

  - If you get an error the first time, refresh the page

## Troubleshooting

- Error: "PG::UnableToSend: no connection to the server"

  - Solution: Make sure that you pressed "start" in the Postgresql app. If you open it, it should say "running" and there should be 2 three tiered images. Once for the blacklight_yul_development db and one for the blacklight_yul_test db
