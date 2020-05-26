.PHONY: cameo build

################################################################################
# Variables                                                                    #
################################################################################

IMAGE ?= gcr.io/dd-decaf-cfbf6/modeling-base
BUILD_COMMIT ?= $(shell git rev-parse HEAD)
SHORT_COMMIT ?= $(shell git rev-parse --short HEAD)
BUILD_DATE ?= $(shell date -u +%Y-%m-%d)
CAMEO_TAG := cameo_${BUILD_DATE}_${SHORT_COMMIT}
CAMEO_COMPILER_TAG := cameo-compiler_${BUILD_DATE}_${SHORT_COMMIT}

################################################################################
# COMMANDS                                                                     #
################################################################################

## Build the cameo Debian image.
build-cameo:
	docker pull dddecaf/tag-spy:latest
	$(eval DEBIAN_BASE_TAG := $(shell docker run --rm dddecaf/tag-spy:latest tag-spy dddecaf/wsgi-base debian))
	docker pull dddecaf/wsgi-base:$(DEBIAN_BASE_TAG)
	docker build \
		--build-arg BASE_TAG=$(DEBIAN_BASE_TAG) \
		--build-arg BUILD_COMMIT=$(BUILD_COMMIT) \
		--tag $(IMAGE):cameo \
		--tag $(IMAGE):$(CAMEO_TAG) \
		./cameo

## Build the cameo-compiler Debian image.
build-cameo-compiler:
	docker build \
		--build-arg BASE_TAG=$(CAMEO_TAG) \
		--build-arg BUILD_COMMIT=$(BUILD_COMMIT) \
		--tag $(IMAGE):cameo-compiler \
		--tag $(IMAGE):$(CAMEO_COMPILER_TAG) \
		./cameo-compiler

## Build all modeling images.
build: build-cameo build-cameo-compiler
	$(info Successfully built all images.)

## Push the cameo Debian image.
push-cameo:
	docker push $(IMAGE):cameo
	docker push $(IMAGE):$(CAMEO_TAG)

## Push the cameo-compiler Debian image.
push-cameo-compiler:
	docker push $(IMAGE):cameo-compiler
	docker push $(IMAGE):$(CAMEO_COMPILER_TAG)

## Push all modeling images.
push: push-cameo push-cameo-compiler
	$(info Successfully pushed all images.)

## Check Python dependencies for vulnerabilities.
safety:
	docker run --rm ${IMAGE}:cameo /bin/sh -c "pip install safety && safety check --full-report"

################################################################################
# Self Documenting Commands                                                    #
################################################################################

.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
