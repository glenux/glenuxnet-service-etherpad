# Etherpad Lite image for docker

This image uses an mysql container for the backend for the pads. It is based
on latest nodejs image.

## About Etherpad Lite

> *From the official website:*

Etherpad allows you to edit documents collaboratively in real-time, much like a live multi-player editor that runs in your browser. Write articles, press releases, to-do lists, etc. together with your friends, fellow students or colleagues, all working on the same document at the same time.

![alt text](http://i.imgur.com/zYrGkg3.gif "Etherpad in action")

All instances provide access to all data through a well-documented API and supports import/export to many major data exchange formats. And if the built-in feature set isn't enough for you, there's tons of plugins that allow you to customize your instance to suit your needs.

You don't need to set up a server and install Etherpad in order to use it. Just pick one of publicly available instances that friendly people from everywhere around the world have set up. Alternatively, you can set up your own instance by following our installation guide

## Quickstart

Copy-paste the following content in a `docker-compose.yml` file

```yaml
---
version: "3.4"

services:
  db:
    image: mariadb:10.3
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MARIADB_ROOT_PASSWORD: insecure
      MARIADB_DATABASE: etherpad

  etherpad:
    build:
      context: .
      dockerfile: Dockerfile
    image: glenux/etherpad:latest
    environment:
      DATABASE_URL: mysql://root:insecure:3306@db/etherpad
      ETHERPAD_ADMIN_USER: admin
      ETHERPAD_ADMIN_PASSWORD: insecure
      NODE_ENV: production
    ports:
      - 9001:9001

volumes:
  db_data:
```

Then run `docker-compose up`

Etherpad will automatically create an `etherpad` database in the specified mysql
server if it does not already exist.

You can now access Etherpad Lite from http://localhost:9001/

## Environment variables

This image supports the following environment variables:

* `ETHERPAD_TITLE`: Title of the Etherpad Lite instance. Defaults to "Etherpad".
* `ETHERPAD_PORT`: Port of the Etherpad Lite instance. Defaults to 9001.

* `ETHERPAD_ADMIN_PASSWORD`: If set, an admin account is enabled for Etherpad,
and the /admin/ interface is accessible via it.
* `ETHERPAD_ADMIN_USER`: If the admin password is set, this defaults to "admin".
Otherwise the user can set it to another username.

* `ETHERPAD_DB_HOST`: Hostname of the mysql databse to use. Defaults to `mysql`
* `ETHERPAD_DB_USER`: By default Etherpad Lite will attempt to connect as root
to the mysql container.
* `ETHERPAD_DB_PASS`: MySQL password to use, mandatory. If legacy links
are used and ETHERPAD_DB_USER is root, then `MYSQL_ENV_MYSQL_ROOT_PASSWORD` is
automatically used.
* `ETHERPAD_DB_NAME`: The mysql database to use. Defaults to *etherpad*. If the
database is not available, it will be created when the container is launched.

The generated settings.json file will be available as a volume under
*/opt/etherpad-lite/var/*.

