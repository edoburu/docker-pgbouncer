IMAGE_NAME=edoburu/pgbouncer
IMAGE_VERSION=latest

docker:
	docker build --pull -t $(IMAGE_NAME):$(IMAGE_VERSION) .

docker-x86:
	docker buildx build \
		--platform linux/amd64 \
		-t $(IMAGE_NAME):$(IMAGE_VERSION) \
		-f ./Dockerfile \
		--load \
		.

docker-arm:
	docker buildx build \
		--platform linux/arm64 \
		-t $(IMAGE_NAME):$(IMAGE_VERSION) \
		-f ./Dockerfile \
		--load \
		.

push:
	docker buildx build \
		--platform linux/arm64,linux/amd64 \
		-t $(IMAGE_NAME):$(IMAGE_VERSION) \
		-f ./Dockerfile \
		--push \
		.
