.PHONY: build deploy serve build-docker-image build-docs

serve:
	mkdocs serve

build:
	mkdocs build

deploy:
	bash ./scripts/deploy.sh

build-docker-image:
	docker build -t mkdocs .

build-docker:
	docker run --name a9docs -it --rm -v `pwd`:/docs mkdocs mkdocs build -f /docs/mkdocs.yml

serve-docker:
	docker run --name a9docs -it --rm -v `pwd`:/docs -p 8000:8000 mkdocs mkdocs serve -f /docs/mkdocs.yml -a 0.0.0.0:8000
