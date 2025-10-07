#!/bin/bash

set -ex

PICUS_SRC_FOLDER=$1

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Customize this so the client does not include unnecessary or sensitive data in the version. 
export AUDITHUB_ZIP_EXCLUDED_DIRECTORIES='[".git",".github",".findings",".vscode","out","broadcast","cache","veridise_artifacts"]'
export AUDITHUB_ZIP_EXCLUDED_FILE_EXTENSIONS='["lcov.info","call_metrics.json",".DS_Store",".gitmodules",".gitignore",".env"]'

# Create new version of the project on AuditHub.
version_id=$(ah create-version-via-local-archive --name "@ga-${TIMESTAMP}" --source-folder ${PICUS_SRC_FOLDER})

echo ${version_id}
