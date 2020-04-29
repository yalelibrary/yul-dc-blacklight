FROM yalelibraryit/dc-blacklight-base:latest

ADD https://time.is/just build-time
COPY ops/nginx.sh /etc/service/nginx/run
COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf

# Added this because of permissions errors runsv nginx: fatal: unable to start ./run: access denied
RUN chmod +x /etc/service/nginx/run

COPY  --chown=app . $APP_HOME

RUN /sbin/setuser app bash -l -c "set -x && \
    (bundle check || bundle install) && \
    DB_ADAPTER=nulldb bundle exec rake assets:precompile && \
    mv ./public/assets ./public/assets-new"

EXPOSE 3000

CMD ["/sbin/my_init"]
