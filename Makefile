all:
	docker build --pull -t edoburu/pgbouncer .

clean:
	docker rmi edoburu/pgbouncer:latest
