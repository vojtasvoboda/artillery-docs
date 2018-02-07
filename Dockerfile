FROM node:8-alpine

WORKDIR /docs

ENV MKDOCS_VERSION="0.16.3"

RUN \
    apk add --no-cache --update \
        ca-certificates \
        bash \
        python2 \
        python2-dev \
        py-setuptools && \
    easy_install-2.7 pip && \
    pip install mkdocs==${MKDOCS_VERSION} && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

USER node

CMD ["/usr/bin/bash"]

