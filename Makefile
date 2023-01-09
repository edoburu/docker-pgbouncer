IMAGE_NAME=edoburu/pgbouncer
IMAGE_VERSION=1.18.0

docker:
	docker build --pull -t $(IMAGE_NAME):$(IMAGE_VERSION) .

push:
	docker push $(IMAGE_NAME):$(IMAGE_VERSION)
