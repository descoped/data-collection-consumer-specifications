SHELL=/bin/bash -x

DC_RELEASE_IMAGE=descoped/data-collector:latest
DC_LOCAL_IMAGE=data-collector:dev
DC_PORT=9990

.PHONY: default
default: | help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

#
# docker-compose postgres
#

.PHONY: pull-postgres
pull-postgres: ## Pull images
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml pull

.PHONY: start-postgres
start-postgres: ## Start postgres
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml up -d

.PHONY: start-postgres-with-console
start-postgres-with-console: ## Start postgres with console
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml up

.PHONY: tail-postgres
tail-postgres: ## Tail postgres
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml logs -f

.PHONY: stop-postgres
stop-postgres: ## Stop postgres
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml down

.PHONY: stop-postgres-clean
stop-postgres-clean: ## Stop postgres and remove anonymous volumes
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml down -v

.PHONY: remove-postgres
remove-postgres: ## Remove postgres
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-postgres.yml rm

.PHONY: open-postgres-adminer
open-postgres-adminer: ## Open a web based DB admin tool in your browser
	@open http://localhost:8980/?pgsql=172.17.0.1:15432&username=rdc&db=rdc

#
# docker-compose gcs
#

.PHONY: pull-gcs
pull-gcs: ## Pull images
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-gcs.yml pull

.PHONY: start-gcs
start-gcs: ## Start gcs
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-gcs.yml up -d

.PHONY: tail-gcs
tail-gcs: ## Tail gcs
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-gcs.yml logs -f

.PHONY: stop-gcs
stop-gcs: ## Stop gcs
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-gcs.yml down

.PHONY: stop-gcs-clean
stop-gcs-clean: ## Stop gcs and remove anonymous volumes
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-gcs.yml down -v

.PHONY: remove-gcs
remove-gcs: ## Remove gcs
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-gcs.yml rm

.PHONY: open-gcs-adminer
open-gcs-adminer: ## Open a web based DB admin tool in your browser
	@open http://localhost:8980/?pgsql=172.17.0.1:15432&username=rdc&db=rdc

#
# docker-compose filesystem
#

.PHONY: pull-filesystem
pull-filesystem: ## Pull images
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem.yml pull

.PHONY: start-filesystem
start-filesystem: ## Start filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem.yml up -d

.PHONY: start-filesystem-with-console
start-filesystem-with-console: ## Start filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem.yml up

.PHONY: start-filesystem-using-secrets-with-console
start-filesystem-using-secrets-with-console: ## Start filesystem using secret manager
	@WORKDIR=$(PWD) PROFILE=filesystem-secrets DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem-secrets.yml up

.PHONY: tail-filesystem
tail-filesystem: ## Tail filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem.yml logs -f

.PHONY: stop-filesystem
stop-filesystem: ## Stop filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem.yml down -v

.PHONY: remove-filesystem
remove-filesystem: ## remove filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-filesystem.yml rm

#
# docker-compose kafka
#

.PHONY: pull-kafka
pull-kafka: ## Pull images
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-kafka.yml pull

.PHONY: start-kafka
start-kafka: ## Start kafka
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-kafka.yml up -d

.PHONY: tail-postgres
tail-kafka: ## Tail kafka
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-kafka.yml logs -f

.PHONY: stop-kafka
stop-kafka: ## Stop kafka
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-kafka.yml down

.PHONY: stop-kafka-clean
stop-kafka-clean: ## Stop kafka and remove anonymous volumes
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-kafka.yml down -v

.PHONY: remove-kafka
remove-kafka: ## Remove kafka
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_RELEASE_IMAGE} docker-compose -f docker-compose-kafka.yml rm

#
# build data collector dev image
#

.PHONY: build-data-collector-dev-image
build-data-collector-dev-image: ## Build data collector dev image
	@cd .. && mvn clean install -DskipTests && cd data-collector-docker && mvn clean verify dependency:copy-dependencies -DskipTests && docker build -t ${DC_LOCAL_IMAGE} -f Dockerfile-dev .

.PHONY: update-data-collector-dev-image
update-data-collector-dev-image: ## Update data collector dev image
	@cd ../data-collector-docker && docker build -t ${DC_LOCAL_IMAGE} -f Dockerfile-dev .

#
# docker-compose postgres-dev
#

.PHONY: start-postgres-dev
start-postgres-dev: ## Start postgres-dev
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-postgres.yml up -d

.PHONY: start-postgres-dev-with-console
start-postgres-dev-with-console: ## Start postgres-dev-with-console
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-postgres.yml up

.PHONY: tail-postgres-dev
tail-postgres-dev: ## Tail postgres-dev
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-postgres.yml logs -f

.PHONY: stop-postgres-dev
stop-postgres-dev: ## Stop postgres-dev
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-postgres.yml down

.PHONY: stop-postgres-dev-clean
stop-postgres-dev-clean: ## Stop postgres-dev and remove anonymous volumes
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-postgres.yml down -v

.PHONY: remove-postgres-dev
remove-postgres-dev: ## Remove postgres-dev
	@WORKDIR=$(PWD) PROFILE=postgres DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-postgres.yml rm

#
# docker-compose gcs-dev
#

.PHONY: start-gcs-dev
start-gcs-dev: ## Start gcs-dev
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-gcs.yml up -d

.PHONY: tail-gcs-dev
tail-gcs-dev: ## Tail gcs-dev
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-gcs.yml logs -f

.PHONY: stop-gcs-dev
stop-gcs-dev: ## Stop gcs-dev
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-gcs.yml down

.PHONY: stop-gcs-dev-clean
stop-gcs-dev-clean: ## Stop gcs-dev and remove anonymous volumes
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-gcs.yml down -v

.PHONY: remove-gcs-dev
remove-gcs-dev: ## Remove gcs-dev
	@WORKDIR=$(PWD) PROFILE=gcs DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-gcs.yml rm


#
# docker-compose filesystem-dev
#

.PHONY: pull-filesystem-dev
pull-filesystem-dev: ## Pull images
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem.yml pull

.PHONY: start-filesystem-dev
start-filesystem-dev: ## Start filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem.yml up -d

.PHONY: start-filesystem-with-console-dev
start-filesystem-with-console-dev: ## Start filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem.yml up

.PHONY: start-filesystem-using-secrets-with-console-dev
start-filesystem-using-secrets-with-console-dev: ## Start filesystem using secret manager dev
	@WORKDIR=$(PWD) PROFILE=filesystem-secrets DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem-secrets.yml up

.PHONY: tail-filesystem-dev
tail-filesystem-dev: ## Tail filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem.yml logs -f

.PHONY: stop-filesystem-dev
stop-filesystem-dev: ## Stop filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem.yml down -v

.PHONY: remove-filesystem-dev
remove-filesystem-dev: ## remove filesystem
	@WORKDIR=$(PWD) PROFILE=filesystem DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-filesystem.yml rm

#
# docker-compose kafka-dev
#

.PHONY: start-kafka-dev
start-kafka-dev: ## Start kafka-dev
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-kafka.yml up -d

.PHONY: tail-kafka-dev
tail-kafka-dev: ## Tail kafka-dev
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-kafka.yml logs -f

.PHONY: stop-kafka-dev
stop-kafka-dev: ## Stop kafka-dev
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-kafka.yml down

.PHONY: stop-kafka-dev-clean
stop-kafka-dev-clean: ## Stop kafka-dev and remove anonymous volumes
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-kafka.yml down -v

.PHONY: remove-kafka-dev
remove-kafka-dev: ## Remove kafka-dev
	@WORKDIR=$(PWD) PROFILE=kafka DC_IMAGE=${DC_LOCAL_IMAGE} docker-compose -f docker-compose-kafka.yml rm

#
# execute consumer specifications
#

.PHONY: ping-ske-freg
ping-ske-freg: ## Ping SKE FREG Playground
	@ping-ske-freg.sh

#curl --cert $(PWD/certs/ske-test-certs/testauth-public.pem:$(PASSPHRASE) --key `$(PWD/certs/ske-test-certs/testauth-key.pem -kvi -o /dev/null https://folkeregisteret-api-konsument-playground.sits.no/folkeregisteret/offentlig-med-hjemmel/api/v1/hendelser/feed/?seq=1

.PHONY: collect-freg-playground
collect-freg-playground: ## Collect freg playground
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/ske-freg-playground-spec.json

.PHONY: collect-freg-konsument-test
collect-freg-konsument-test: ## Collect konsument test
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/ske-freg-konsument-test-spec.json

.PHONY: collect-freg-bulk-uttrekk-prod
collect-freg-bulk-uttrekk-prod: ## Collect freg bulk uttrekk
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/ske-freg-bulk-uttrekk-spec.json

.PHONY: collect-sirius-person-utkast
collect-sirius-person-utkast: ## Collect sirius person utkast
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/ske-sirius-person-utkast-spec.json

.PHONY: collect-sirius-person-fastsatt
collect-sirius-person-fastsatt: ## Collect sirius person fastsatt
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/ske-sirius-person-fastsatt-spec.json

.PHONY: collect-sirius-person-utkast-prod
collect-sirius-person-utkast-prod: ## Collect sirius person utkast prod
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'accept: application/xml' -d @specs/ske-sirius-person-utkast-spec-prod.json

.PHONY: collect-sirius-person-fastsatt-prod
collect-sirius-person-fastsatt-prod: ## Collect sirius person fastsatt prod
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'accept: application/xml' -d @specs/ske-sirius-person-fastsatt-spec-prod.json

.PHONY: collect-tvinn-test
collect-tvinn-test: ## Collect tvinn Test
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/toll-tvinn-test-spec.json

.PHONY: collect-tvinn-api-test
collect-tvinn-api-test: ## Collect tvinn API-test
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/toll-tvinn-api-test-spec.json

.PHONY: collect-altinn-test
collect-altinn-test: ## Collect Altinn 3 Test
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/altinn3-test-spec.json

.PHONY: collect-moveit-test
collect-moveit-test: ## Collect MoveIt Test
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/moveit-test-spec.json

.PHONY: collect-enheter-test
collect-enheter-test: ## Collect enheter test
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/enhetsregisteret-test-spec.json

.PHONY: collect-enheter-download
collect-enheter-download: ## Collect enheter download (huge file)
	@curl -X PUT -i localhost:${DC_PORT}/tasks -H 'content-type: application/json' -d @specs/enhetsregisteret-download-spec.json

.PHONY: list-tasks
list-tasks: ## List running tasks
	@curl -X GET localhost:${DC_PORT}/tasks && printf "\n"

.PHONY: cancel-task
cancel-task: ## Cancel running tasks 'make cancel-task'
	@echo "curl -X DELETE -i localhost:${DC_PORT}/tasks/TASK_ID"

.PHONY: health
health: ## Health
	@curl -X GET localhost:${DC_PORT}/health

.PHONY: health-all
health-all: ## Health show all
	@curl -X GET localhost:${DC_PORT}/health?all

.PHONY: health-alive
health-alive: ## Health Alive
	@curl -X GET -i localhost:${DC_PORT}/health/alive

.PHONY: health-ready
health-ready: ## Health Ready
	@curl -X GET -i localhost:${DC_PORT}/health/ready
