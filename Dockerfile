FROM yalelibraryit/dc-blacklight-base:latest

ADD https://time.is/just build-time
COPY ops/nginx.sh /etc/service/nginx/run
COPY ops/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY ops/env.conf /etc/nginx/main.d/env.conf

# Install Chrome so we can run system specs for Blacklight
RUN apt-get update
RUN apt-get install xdg-utils libxtst6 libxss1 libxrender1 libxfixes3 \
    libxi6 libxext6 libxdamage1 libxcursor1 libxcomposite1 libxcb-dri3-0 \
    libxcb-dri3-0 libx11-xcb1 libpangocairo-1.0-0 libpango-1.0-0 libnss3 \
    libnspr4 libgtk-3-0 libgdk-pixbuf2.0-0 libgbm1 libdrm2 fonts-liberation \
    wget
RUN rm -rf /var/lib/apt/lists/*
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

# Added this because of permissions errors runsv nginx: fatal: unable to start ./run: access denied
RUN chmod +x /etc/service/nginx/run

COPY  --chown=app . $APP_HOME

RUN /sbin/setuser app bash -l -c "set -x && \
    (bundle check || bundle install) && \
    DB_ADAPTER=nulldb bundle exec rake assets:precompile && \
    mv ./public/assets ./public/assets-new"

EXPOSE 3000

CMD ["/sbin/my_init"]
