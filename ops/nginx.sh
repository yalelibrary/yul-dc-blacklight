#!/bin/bash
set -e
if [[ ! -e /var/log/nginx/error.log ]]; then
        # The Nginx log forwarder might be sleeping and waiting
        # until the error log becomes available. We restart it in
        # 1 second so that it picks up the new log file quickly.
        (sleep 1 && sv restart /etc/service/nginx-log-forwarder)
fi

if [ -z $PASSENGER_APP_ENV ]
then
    export PASSENGER_APP_ENV=development
fi

rm -rf /home/app/webapp/.ruby*

declare -p | grep -Ev 'BASHOPTS|PWD|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

if [[ $PASSENGER_APP_ENV == "development" ]] || [[ $PASSENGER_APP_ENV == "test" ]]
then
    /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && bundle exec rails db:migrate db:test:prepare'
fi

if [[ $PASSENGER_APP_ENV == "production" ]] || [[ $PASSENGER_APP_ENV == "staging" ]]
then
    /bin/bash -l -c 'chown -R app:app /home/app/webapp/tmp' # mounted volume may have wrong permissions
    /bin/bash -l -c 'chown -R app:app /home/app/webapp/public' # mounted volume may have wrong permissions
    /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && bundle exec rake db:migrate'
    if [ -d /home/app/webapp/public/assets-new ]; then
        /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && rsync -a public/assets-new/ public/assets/'
    fi
    if [ -d /home/app/webapp/public/packs-new ]; then
        /sbin/setuser app /bin/bash -l -c 'cd /home/app/webapp && rsync -a public/packs-new/ public/packs/'
    fi
fi

exec /usr/sbin/nginx
