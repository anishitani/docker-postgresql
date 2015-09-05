#!/bin/sh

/usr/lib/postgresql/$PG_VERSION/bin/postgres \
  -D /var/lib/postgresql/$PG_VERSION/main \
  -c config_file=/etc/postgresql/$PG_VERSION/main/postgresql.conf
