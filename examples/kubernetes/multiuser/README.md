Multiuser example
=================

This installs a single PgBouncer instance that proxies to multiple databases for multiple users.

Installation
------------

Generate authentication credentials for all users:

```
../../generate-userlist >> userlist.txt
```

Update the address in `pgbouncer.ini` to point to the PostgreSQL service (default=`postgres.default`).

Generate the secrets:

```
./create-secrets
```

or:

```
kubectl create secret generic pgbouncer-example-config --from-file=pgbouncer.ini --from-file=userlist.txt
```

Install the application:

```
kubectl apply -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/multiuser/service.yml
kubectl apply -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/multiuser/deployment.yml
```

Removal
-------

```
kubectl delete -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/multiuser/service.yml
kubectl delete -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/multiuser/deployment.yml
kubectl delete secret pgbouncer-example-config
```

Connecting to the admin console
-------------------------------

When an *admin user* is defined, and it has a password in the `userlist.txt`, it can connect to the special `pgbouncer` database:

```
psql postgres://postgres@pgbouncer-example/pgbouncer  # outside container
psql postgres://127.0.0.1/pgbouncer                   # inside container
```

Various [admin console commands](https://pgbouncer.github.io/usage.html#admin-console) can be executed, for example:

```
SHOW STATS;
SHOW SERVERS;
SHOW CLIENTS;
SHOW POOLS;
```

And it allows temporary disconnecting the backend database (e.g. for restarts) while the web applications keep a connection to PgBouncer:

```
PAUSE;
RESUME;
```

About create-secrets
--------------------

The `create-secrets` script is a small wrapper to allow creating secrets without having to do BASE64 encoding yourself. The `pgbouncer-example-config.yml` is generated using:

```
kubectl create secret generic pgbouncer-example-config --from-file=pgbouncer.ini --from-file=userlist.txt
```
