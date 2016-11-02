#!/bin/bash

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]
then
  echo "***** AWS_SECRET_ACCESS_KEY not set - needed to auth with AWS"
  exit 1
fi

if [[ -z "$AWS_ACCESS_KEY_ID" ]]
then
  echo "***** AWS_ACCESS_KEY_ID not set - needed to auth with AWS"
  exit 1
fi

if [[ -z "$AWS_S3_BUCKET" ]]
then
  echo "***** AWS_S3_BUCKET not set - needed to upload files to"
  exit 1
fi

pushd build/html

if [[ ! -f index.html ]]
then
  echo "***** WRONG DIRECTORY"
  exit 1
else
  echo "***** Syncing"
  s3cmd --delete-removed --force sync . "s3://$AWS_S3_BUCKET/docs/"
fi
