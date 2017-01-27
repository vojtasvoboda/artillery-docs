#!/bin/bash

set -euxo pipefail

: "${AWS_ACCESS_KEY_ID?Needed to auth with AWS}"
: "${AWS_SECRET_ACCESS_KEY?Needed to auth with AWS}"
: "${AWS_S3_BUCKET?Need to know where files should go}"

pushd build/html

if [[ ! -f index.html ]]
then
  echo "***** WRONG DIRECTORY"
  exit 1
else
  echo "***** Syncing"
  s3cmd --access_key="$AWS_ACCESS_KEY_ID" --secret_key="$AWS_SECRET_ACCESS_KEY" --delete-removed --force sync . "s3://$AWS_S3_BUCKET/docs/"
fi
