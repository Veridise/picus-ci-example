#!/bin/bash

set -e

# Relative path from the project's root directory
PICUS_FILE=$1
VERSION_ID=$2

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Launching AuditHub task
task_id=$(ah start-picus-v2-task --version-id ${VERSION_ID} --source ${PICUS_FILE} --solver z3)
# This is mainly for debugging, will let you inspect the logs.
ah monitor-task --task-id $task_id

# If both --verify and --check-completed checks pass, this means that picus verified all input modules.
ah get-task-info --task-id $task_id --output none --verify --check-completed
