PgBouncer usage in Kubernetes
=============================

These example files give a fully functional PgBouncer inside the cluster.
Make sure the secrets are properly configured to match your database.

Installation
------------

Edit the secrets file to match the database/username/password settings.

```sh
kubectl create secret generic pgbouncer-example-env --from-env-file="pgbouncer-example-env.secrets"  # or run ./create-secrets
kubectl apply -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/service.yml
kubectl apply -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/deployment.yml
```

The `create-secrets` is a small wrapper to allow creating secrets without having to do BASE64 encoding yourself. Given an input file like:

```
DB_HOST=postgres.default
DB_USER=username
DB_PASSWORD=password
```

It generates the following YAML, and either creates the secret or updates the existing secret.

```yaml
apiVersion: v1
data:
  DB_HOST: cG9zdGdyZXMuZGVmYXVsdA==
  DB_PASSWORD: cGFzc3dvcmQ=
  DB_USER: dXNlcm5hbWU=
kind: Secret
metadata:
  name: pgbouncer-example-env
  namespace: default
```

Connecting
----------

Inside any pods, the service should be reachable with the DNS name `postgres-example` and `postgres-example.default` (FQDN: `servicename.namespace.svc.cluster.local`). Thus you can connect to it using:

```sh
psql 'postgresql://user:pass@pgbouncer.default/dbname'
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
kubectl delete -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/service.yml
kubectl delete -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/deployment.yml
kubectl delete secret pgbouncer-example-env
```
