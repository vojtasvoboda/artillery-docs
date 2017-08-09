.PHONY: build deploy

build:
	mkdocs build

deploy:
	bash ./scripts/deploy.sh
