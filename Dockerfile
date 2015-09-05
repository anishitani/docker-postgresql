FROM anishitani/docker-cache

MAINTAINER André Nishitani <andre.nishitani@gmail.com>

ENV PG_VERSION 9.4

# Includes initialization script inside folder scripts
ADD start.sh /scripts/
RUN chmod +x /scripts/start.sh

RUN /scripts/init_squid_cache.sh

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
  && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update && apt-get install -y postgresql-$PG_VERSION

RUN /scripts/stop_squid_cache.sh

USER postgres

# Sets postgres password
RUN /etc/init.d/postgresql start && psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres'";

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/$PG_VERSION/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/scripts/start.sh"]
