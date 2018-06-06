#!/bin/bash
set -o errexit
set -o pipefail

# Usage:
# mirthconnect-wrapper.sh [--configure | --cli]
#   With no arguments/flags, configures mirth.properties (e.g. setting database
#   properties based on $DATABASE_URL), then launches Mirth Administrator and
#   an NGiNX reverse proxy. With --configure, only configures mirth.properties.
#   With --cli, launches Mirth Administrator in the background and then runs
#   mirth-cli-launcher.jar (optionally )

# For URL parsing...
. /usr/local/bin/utilities.sh
PROPERTIES_FILE=/opt/mirthconnect/conf/mirth.properties

function setup_mirth_properties() {
  # If DATABASE_URL is defined (and is a postgresql:// URL), replace the
  # default in-container Derby database connection with a PostgreSQL connection
  if [ -n "$DATABASE_URL" ]; then
    parse_url "$DATABASE_URL"

    if [ "$protocol" != "postgresql://" ]; then
      echo "ERROR: DATABASE_URL must be a postgresql:// URL"
      exit 1
    fi

    sed -i "s%^database =.*%database = postgres%" $PROPERTIES_FILE
    sed -i "s%^database.url =.*%database.url = jdbc:postgresql://${host_and_port}/${database}\?ssl=true\&sslfactory=org.postgresql.ssl.NonValidatingFactory%" $PROPERTIES_FILE
    sed -i "s%^database.username =.*%database.username = ${user}%" $PROPERTIES_FILE
    sed -i "s%^database.password =.*%database.password = ${password}%" $PROPERTIES_FILE
  fi
}

function wait_for_mirth() {
  echo "INFO Waiting for Mirth Connect to start up..."
  while ! echo exit | nc localhost 443 &> /dev/null; do echo -n .; sleep 1; done
  echo
}

function wait_and_start_nginx() {
  wait_for_mirth

  echo "INFO Launching NGiNX..."
  /usr/sbin/nginx
}

# All functions depend on updating mirth.properties
setup_mirth_properties

if [[ "$1" == "--configure" ]]; then
  exit 0

elif [[ "$1" == "--cli" ]]; then
  shift

  # Launch Mirth Server (required for CLI access)
  echo "INFO Launching Mirth Connect Administrator..."
  if ! echo exit | nc localhost 443 &> /dev/null; then
    java -jar mirth-server-launcher.jar &> /dev/null &
  fi

  wait_for_mirth
  java -jar mirth-cli-launcher.jar -a https://127.0.0.1:443 -v 0.0.0 "$@"

elif [[ "$#" -eq 0 ]]; then
  # Start NGiNX reverse proxy
  wait_and_start_nginx &

  # Launch Mirth Server
  echo "INFO Launching Mirth Connect Administrator..."
  exec java -jar mirth-server-launcher.jar

else
  echo "Unrecognized command: $1"
  exit 1
fi