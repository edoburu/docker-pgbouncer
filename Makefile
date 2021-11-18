IMAGE_NAME=us.gcr.io/taxfyle-ci/pgbouncer
ifndef TAG
TAG=latest
endif

docker:
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

push:
	docker push $(IMAGE_NAME):$(TAG)
