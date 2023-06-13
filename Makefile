IMAGE_NAME=edoburu/pgbouncer
IMAGE_VERSION=v1.19.1
PATCH_NUMBER=p0

docker:
	docker build --pull -t $(IMAGE_NAME):$(IMAGE_VERSION)-$(PATCH_NUMBER) .

push:
	docker push $(IMAGE_NAME):$(IMAGE_VERSION)-$(PATCH_NUMBER)
