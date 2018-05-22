Linux based docker image for pgbouncer
Forked and Inspired by https://github.com/edoburu/docker-pgbouncer

Build Docker Image
```
docker build -t pgbouncer .
```

Run Docker Container (Settings for serverless architecture using database)
```sh
docker run --rm \
    -e DATABASE_URL="postgres://user:pass@postgres-host/database" \
    -p 5432:5432 \ 
    -e POOL_MODE=transaction \
    -e MAX_CLIENT_CONN=2000 \ 
    -e DEFAULT_POOL_SIZE=20 pgbouncer
```

Connect to pgbouncer
```
psql 'postgresql://user:pass@localhost/dbname'
```
