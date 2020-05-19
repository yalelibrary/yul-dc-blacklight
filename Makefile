NAME   := yalelibraryit/dc-blacklight
TAG    := $$(git log -1 --pretty=%h)
IMG    := ${NAME}:${TAG}
 
build:
	@docker-compose build web
	@docker tag  ${NAME}:latest ${IMG}
 
push:
	@docker push ${IMG}
