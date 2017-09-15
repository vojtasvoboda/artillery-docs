.PHONY: build deploy serve

serve:
	mkdocs serve

build:
	mkdocs build

deploy:
	bash ./scripts/deploy.sh
