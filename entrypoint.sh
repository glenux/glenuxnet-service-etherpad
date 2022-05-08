#!/bin/sh
set -e

eval "$(sh /parseurl.sh "$DATABASE_URL" ETHERPAD_DB)"

# ETHERPAD_DB_PASS is mandatory in mysql container, so we're not offering
# any default. If we're linked to MySQL through legacy link, then we can try
# using the password from the env variable MYSQL_ENV_MYSQL_ROOT_PASSWORD
# if [ "$ETHERPAD_DB_USER" = 'root' ]; then
#   : ${ETHERPAD_DB_PASS:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
# fi

if [ -z "$ETHERPAD_DB_USER" ]; then 
  echo >&2 'error: missing required ETHERPAD_DB_USER environment variable'
  echo >&2 '  Did you forget to -e ETHERPAD_DB_USER=... ?'
  exit 1
fi

if [ -z "$ETHERPAD_DB_PASS" ]; then
  echo >&2 'error: missing required ETHERPAD_DB_PASS environment variable'
  echo >&2 '  Did you forget to -e ETHERPAD_DB_PASS=... ?'
  exit 1
fi

RANDOM_STRING="$(node -p "require('crypto').randomBytes(32).toString('hex')")}"

# Sanitize DB information
ETHERPAD_DB_HOST="${ETHERPAD_DB_HOST:-}"
ETHERPAD_DB_PORT="${ETHERPAD_DB_PORT:-3306}"

# Sanitize etherpad info
ETHERPAD_PORT="${ETHERPAD_PORT:-9001}"
ETHERPAD_SESSION_KEY="${ETHERPAD_SESSION_KEY:-$RANDOM_STRING}"
ETHERPAD_TITLE="${ETHERPAD_TITLE:-Etherpad}"

# Wait for database
echo "Waiting MySQL/MariaDB to be available on port 3306..."

while ! nc -z "${ETHERPAD_DB_HOST}" "${ETHERPAD_DB_PORT}" ; do
  sleep 1 # wait for 1/10 of the second before check again
done

echo "Service MySQL/MariaDB seems ready"
sleep 1

# Check if database already exists
RESULT="$(mysql \
  "-u${ETHERPAD_DB_USER}" \
  "-p${ETHERPAD_DB_PASS}" \
  "-P${ETHERPAD_DB_PORT}" \
  "-h${ETHERPAD_DB_HOST}" \
  --skip-column-names \
  -e "SHOW DATABASES LIKE '${ETHERPAD_DB_NAME}'")"

if [ "$RESULT" != "$ETHERPAD_DB_NAME" ]; then
  # mysql database does not exist, create it
  echo "Creating database ${ETHERPAD_DB_NAME}"

  mysql "-u${ETHERPAD_DB_USER}" \
    "-p${ETHERPAD_DB_PASS}" \
    "-P${ETHERPAD_DB_PORT}" \
    "-h${ETHERPAD_DB_HOST}" \
      -e "create database ${ETHERPAD_DB_NAME}"
fi

if ! [ -f settings.json ]; then
  echo "Creating database configuration"
  cat <<- EOF > settings.json
  {
    "title": "${ETHERPAD_TITLE}",
    "ip": "0.0.0.0",
    "port" :${ETHERPAD_PORT},
    "skinName": "colibris",
    "sessionKey" : "${ETHERPAD_SESSION_KEY}",
    "trustProxy" : false,
    "minify" : true,
    "defaultPadText" : "Welcome to Etherpad!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nIMPORTANT: this pad will be deleted after 30 days. Please don't consider it as document storage.",
    "dbType" : "mysql",
    "dbSettings" : {
          "user"    : "${ETHERPAD_DB_USER}",
          "host"    : "${ETHERPAD_DB_HOST}",
          "password": "${ETHERPAD_DB_PASS}",
          "database": "${ETHERPAD_DB_NAME}"
        },
EOF

  if [ -n "$ETHERPAD_ADMIN_PASSWORD" ]; then
    ETHERPAD_ADMIN_USER="${ETHERPAD_ADMIN_USER:-admin}"
    echo "Creating admin user configuration for $ETHERPAD_ADMIN_USER/$ETHERPAD_ADMIN_PASSWORD"

    cat <<-EOF >> settings.json
      "users": {
        "${ETHERPAD_ADMIN_USER}": {
          "password": "${ETHERPAD_ADMIN_PASSWORD}",
          "is_admin": true
        }
      },
EOF
  fi

  cat <<- EOF >> settings.json
  }
EOF
fi

if ! grep -q '/* GLENUX BEGIN */' src/static/css/pad.css ; then
	cat >> src/static/css/pad.css <<-MARK
	/* GLENUX BEGIN */
	body#innerdocbody {
  		font-size: 16px;
  		line-height: 20px
	}
	MARK
fi

exec "$@"

