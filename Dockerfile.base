FROM phusion/passenger-ruby26

RUN echo 'Downloading Packages' && \
  curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update -qq && \
  apt-get install -y --no-install-recommends build-essential nodejs yarn tzdata libsasl2-dev rsync && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  echo 'Packages Downloaded'

RUN yarn && \
  yarn config set no-progress && \
  yarn config set silent

RUN rm /etc/nginx/sites-enabled/default
COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf

ENV APP_HOME /home/app/webapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=4

COPY --chown=app Gemfile* $APP_HOME/
RUN gem install bundler -v 2.1.4
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

COPY --chown=app . $APP_HOME

# Added this because of permissions errors
RUN chown -R app $APP_HOME

# this is so that these items are cached and only have to be updated
RUN /sbin/setuser app /bin/bash -l -c "cd /home/app/webapp && DB_ADAPTER=nulldb bundle exec rake assets:precompile"

# Asset complie and migrate if prod, otherwise just start nginx
ADD ops/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
RUN rm -f /etc/service/nginx/down
