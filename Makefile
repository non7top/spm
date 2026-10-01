export DOCKER_UID := $(shell id -u)
export DOCKER_GID := $(shell id -g)

.PHONY: build package matrix shell destroy

# Builds the whole rdiff-backup chain (openssl, curl, python2, librsync, ...)
# from source into /usr/local/rdiff-backup, the prefix the fleet already uses.
build:
	docker compose run --rm dev ./spm install rdiff-backup

package:
	docker compose run --rm dev ./debian/build.sh

matrix:
	docker compose -f docker-compose.matrix.yml run --rm jammy
	docker compose -f docker-compose.matrix.yml run --rm noble
	docker compose -f docker-compose.matrix.yml run --rm resolute

shell:
	docker compose run --rm dev bash

destroy:
	docker compose down -v
