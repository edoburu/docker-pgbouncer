PgBouncer usage in Kubernetes
=============================

TL;DR:

* [singleuser](https://github.com/edoburu/docker-pgbouncer/tree/master/examples/kubernetes/singleuser) - one PgBouncer for a single database.
* [multiuser](https://github.com/edoburu/docker-pgbouncer/tree/master/examples/kubernetes/multiuser) - one PgBouncer for multiple databases and users.

Possible usages
---------------

Using PgBouncer is possible in different situations:

* A single instance per application (see the [singleuser example](https://github.com/edoburu/docker-pgbouncer/tree/master/examples/kubernetes/singleuser))
* A shared instance for many applications (see the [multiuser example](https://github.com/edoburu/docker-pgbouncer/tree/master/examples/kubernetes/multiuser)).
* A single instance inside your application pod. This ensures the PgBouncer Pod lives close to the application, reducing connection time.

When PgBouncer runs inside the application Pod, it can be accessed via `localhost`. Otherwise, use the service DNS name (`servicename` or `servicename.namespace`) to connect to it.


Connecting
----------

Inside any Pod, the example service should be reachable with the DNS name `pgbouncer-example` and `pgbouncer-example.default` (FQDN: `servicename.namespace.svc.cluster.local`). Thus you can connect to it using:

```sh
psql 'postgresql://user:pass@pgbouncer-example.default/dbname'
```

From the host machine, use the service ClusterIP adress, found via:

```sh
kubectl get services
```

Make sure PostgreSQL at least accepts connections from the machine where PgBouncer runs! Update `listen_addresses` in `postgresql.conf` and accept incoming connections from your IP range (e.g. `10.0.0.0/8`) in `pg_hba.conf`:

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             10.0.0.0/8              md5
```

Removing the example
---------------------

```sh
kubectl delete deployment pgbouncer-example
kubectl delete service pgbouncer-example
kubectl delete secret pgbouncer-example-env     # singleuser example
kubectl delete secret pgbouncer-example-config  # multiuser example
```
