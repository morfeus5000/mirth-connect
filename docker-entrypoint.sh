#! /bin/bash

set -e

if [ "$1" = 'java' ]; then
    chown -R mirth /opt/mirth-connect/appdata
    chown -R mirth /opt/mirth-connect/conf

    exec gosu mirth "$@"
fi

exec "$@"