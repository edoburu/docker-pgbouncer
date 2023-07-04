IMAGE_NAME=edoburu/pgbouncer
IMAGE_VERSION=latest

docker-x86:
	docker buildx build \
		--platform linux/amd64 \
		-t $(IMAGE_NAME):$(IMAGE_VERSION) \
		-f ./Dockerfile \
		--load \
		.

# to build arm64 on amd64
# sudo apt install -y qemu-user-static binfmt-support && docker buildx create --use
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
