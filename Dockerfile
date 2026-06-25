FROM yalelibraryit/dc-base:v1.4.7
ENV NODE_OPTIONS="--openssl-legacy-provider"

COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf
# Asset compile and migrate if prod, otherwise just start nginx
COPY ops/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run
RUN rm -f /etc/service/nginx/down

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
BUNDLE_JOBS=4
RUN /sbin/setuser app bash -l -c "gem install bundler -v 4.0.11"

COPY --chown=app Gemfile* $APP_HOME/
RUN /sbin/setuser app bash -l -c "bundle check || bundle install"

COPY  --chown=app . $APP_HOME


RUN /sbin/setuser app bash -l -c " \
    DB_ADAPTER=nulldb yarn install --frozen-lockfile --ignore-scripts && \
    yarn run uv-install && yarn run uv-config && \
    bundle exec rake assets:precompile && \
    mv ./public/assets ./public/assets-new"
