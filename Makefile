IMAGE_NAME=lapierre/pgbouncer
IMAGE_VERSION=1.14.0

docker:
	        docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) .
			docker tag $(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_NAME):latest

push:
			docker push $(IMAGE_NAME):$(IMAGE_VERSION)
			docker push $(IMAGE_NAME):latest
