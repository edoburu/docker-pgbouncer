PgBouncer Docker image
======================

This is a minimal PgBouncer image, based on Alpine Linux.

Features:

* Very small, quick to pull (just 15MB)
* Configurable using environment variables
* Uses standard Postgres port 5432, to work transparently for applications.
* Includes PostgreSQL client tools such as ``psql``, ``pg_isready``
* MD5 authentication by default.
* `/etc/pgbouncer/pgbouncer.ini` and `/etc/pbbouncer/userlist.txt` are auto-created if they don't exist.

Why use PgBouncer
-----------------

PostgreSQL connections take up a lot of memory ([about 10MB per connection](http://hans.io/blog/2014/02/19/postgresql_connection)). There is also a significant startup cost to establish a connection with TLS, hence web applications gain performance by using persistent connections.

By placing PgBouncer in between the web application and the actual PostgreSQL database, the memory and start-up costs are reduced. The web application can keep persistent connections to PgBouncer, while PgBouncer only keeps a few connections to the actual PostgreSQL server. It can reuse the same connection for multiple clients.

Available tags
--------------

Base images:

* `latest` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/master/Dockerfile)) - Default and latest version.
* `1.19.1` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/v1.19.x/Dockerfile)) - Latest version.
* `1.18.0` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/v1.18.x/Dockerfile)) - Latest version.
* `1.17.0` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/v1.17.x/Dockerfile)) - Latest version.
* `1.15.0` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/v1.15.x/Dockerfile)) - Latest version.
* `1.14.0` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/v1.14.x/Dockerfile)) - Latest version.
* `1.12.0` ([Dockerfile](https://github.com/edoburu/docker-pgbouncer/blob/v1.12.x/Dockerfile)) - Latest version.

Images are automatically rebuild on Alpine Linux updates.

Usage
-----

```sh
docker run --rm \
    -e DATABASE_URL="postgres://user:pass@postgres-host/database" \
    -p 5432:5432 \
    edoburu/pgbouncer
```

Or using separate variables:

```sh
docker run --rm \
    -e DB_USER=user \
    -e DB_PASSWORD=pass \
    -e DB_HOST=postgres-host \
    -e DB_NAME=database \
    -p 5432:5432 \
    edoburu/pgbouncer
```

Connecting should work as expected:

```sh
psql 'postgresql://user:pass@localhost/dbname'
```

Configuration
-------------

Almost all settings found in the [pgbouncer.ini](https://pgbouncer.github.io/config.html) can be defined as environment variables, except a few that make little sense in a Docker environment (like port numbers, syslog and pid settings). See the [entrypoint script](https://github.com/edoburu/docker-pgbouncer/blob/master/entrypoint.sh) for details. For example:

```sh
docker run --rm \
    -e DATABASE_URL="postgres://user:pass@postgres-host/database" \
    -e POOL_MODE=session \
    -e SERVER_RESET_QUERY="DISCARD ALL" \
    -e MAX_CLIENT_CONN=100 \
    -p 5432:5432
    edoburu/pgbouncer
```

Kubernetes integration
----------------------

For example in Kubernetes, see the [examples/kubernetes folder](https://github.com/edoburu/docker-pgbouncer/tree/master/examples/kubernetes).

Docker Compose
--------------

For example in Docker Compose, see the [examples/docker-compose folder](https://github.com/edoburu/docker-pgbouncer/tree/master/examples/docker-compose).

PostgreSQL configuration
------------------------

Make sure PostgreSQL at least accepts connections from the machine where PgBouncer runs! Update `listen_addresses` in `postgresql.conf` and accept incoming connections from your IP range (e.g. `10.0.0.0/8`) in `pg_hba.conf`:

```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             10.0.0.0/8              md5
```

Using a custom configuration
----------------------------

When the default `pgbouncer.ini` is not sufficient, or you'd like to let multiple users connect through a single PgBouncer instance, mount an updated configuration:

```sh
docker run --rm \
    -e DB_USER=user \
    -e DB_PASSWORD=pass \
    -e DB_HOST=postgres-host \
    -e DB_NAME=database \
    -v pgbouncer.ini:/etc/pgbouncer/pgbouncer.ini:ro
    -p 5432:5432
    edoburu/pgbouncer
```

Or extend the `Dockerfile`:

```Dockerfile
FROM edoburu/pgbouncer:1.11.0
COPY pgbouncer.ini userlist.txt /etc/pgbouncer/
```

When the `pgbouncer.ini` file exists, the startup script will not override it. An extra entry will be written to `userlist.txt` when `DATABASE_URL` contains credentials, or `DB_USER` and `DB_PASSWORD` are defined.

The `userlist.txt` file uses the following format:

```txt
"username" "plaintext-password"
```

or:

```txt
"username" "md5<md5 of password + username>"
```

Use [examples/generate-userlist](https://github.com/edoburu/docker-pgbouncer/blob/master/examples/generate-userlist) to generate this file:

```sh
examples/generate-userlist >> userlist.txt
```

You can also connect with a single user to PgBouncer, and from there retrieve the actual database password
by setting ``AUTH_USER``. See the example from: <https://www.cybertec-postgresql.com/en/pgbouncer-authentication-made-easy/>

Connecting to the admin console
-------------------------------

When an *admin user* is defined, and it has a password in the `userlist.txt`, it can connect to the special `pgbouncer` database:

```sh
psql postgres://postgres@hostname-of-container/pgbouncer  # outside container
psql postgres://127.0.0.1/pgbouncer                       # inside container
```

Hence this requires a custom configuration, or a mount of a custom ``userlist.txt`` in the docker file.
Various [admin console commands](https://pgbouncer.github.io/usage.html#admin-console) can be executed, for example:

```sql
SHOW STATS;
SHOW SERVERS;
SHOW CLIENTS;
SHOW POOLS;
```

And it allows temporary disconnecting the backend database (e.g. for restarts) while the web applications keep a connection to PgBouncer:

```sql
PAUSE;
RESUME;
```
