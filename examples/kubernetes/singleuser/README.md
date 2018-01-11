Singleuser example
==================

This installs a single PgBouncer instance that accepts a single user for a single database.
This can be used to bind PgBouncer to your web application, or even include a simular configuration inside a pod.

Installation
------------

Enter the proper values in `pgbouncer-example-env.secrets`.

Generate the secrets:

```
./create-secrets
```

or:

```
kubectl create secret generic pgbouncer-example-env --from-env-file="pgbouncer-example-env.secrets"
```

Install the application:

```
kubectl apply -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/singleuser/service.yml
kubectl apply -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/singleuser/deployment.yml
```

Removal
-------

```
kubectl delete -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/singleuser/service.yml
kubectl delete -f https://raw.githubusercontent.com/edoburu/docker-pgbouncer/master/examples/kubernetes/singleuser/deployment.yml
kubectl delete secret pgbouncer-example-env
```

About create-secrets
--------------------

The `create-secrets` script is a small wrapper to allow creating secrets without having to do BASE64 encoding yourself. Given an input file like:

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

