#!/bin/sh

echo "Configuring cron jobs..."

CRON_SYNC_INTERVAL=${CRON_SYNC_INTERVAL:-6}
CRON_REFRESH_INTERVAL=${CRON_REFRESH_INTERVAL:-12}

> /etc/crontabs/root

if [ "${CRON_SYNC_ENABLED:-true}" = "true" ]; then
    echo "0 */${CRON_SYNC_INTERVAL} * * * /usr/bin/curl -s http://127.0.0.1:3000/api/sync/artifacts" >> /etc/crontabs/root
    echo "Cron: sync artifacts every ${CRON_SYNC_INTERVAL} hours"
fi

if [ "${CRON_REFRESH_ENABLED:-true}" = "true" ]; then
    echo "0 */${CRON_REFRESH_INTERVAL} * * * /usr/bin/curl -s http://127.0.0.1:3000/api/utils/refresh" >> /etc/crontabs/root
    echo "Cron: refresh every ${CRON_REFRESH_INTERVAL} hours"
fi

echo "Cron configuration complete"
echo "---"
cat /etc/crontabs/root
echo "---"

exec /usr/local/bin/supervisord -c /etc/supervisord.conf
