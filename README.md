PgBouncer Docker image
======================

This is a minimal PgBouncer image, based on Alpine Linux.

Features:

* Very small, quick to pull (just 8MB)
* Using LibreSSL
* Configurable using environment variables
* Uses standard Postgres port 5432, to work transparently for applications.
* MD5 authentication


Available tags
--------------

Base images:

- `1.8.1` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/master/Dockerfile)) - Default and latest version.


Usage
-----

```sh
docker run --rm \
    -e DATABASE_URL="postgres://user:pass@postgres-host/database" \
    -e POOL_MODE=session \
    -e "SERVER_RESET_QUERY=DISCARD ALL" \
    -e MAX_CLIENT_CONN=100 \
    edoburu/pgbouncer
```

Or using separate variables:

```sh
docker run --rm \
    -e DB_USER=user \
    -e DB_PASSWORD=pass \
    -e DB_HOST=postgres-host \
    -e DB_NAME=database \
    -e POOL_MODE=session \
    -e "SERVER_RESET_QUERY=DISCARD ALL" \
    -e MAX_CLIENT_CONN=100 \
    edoburu/pgbouncer
```

Almost all settings found in the [pgbouncer.ini](https://pgbouncer.github.io/config.html) can be defined as environment variables, except a few that make little sense in a Docker environment (like port numbers, syslog and pid settings). See the [startup script](https://github.com/edoburu/docker-pgbouncer/blob/master/startup.sh) for details.
