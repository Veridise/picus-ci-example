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

ah download-artifact --task-id $task_id --step-code run-picus --name findings.json --output-file ./${PICUS_FILE}-findings.json

# Check if Picus hit a time out or produced unknown findings.
PICUS_COMPLETED=$(jq '.completed' ./${PICUS_FILE}-findings.json)

if [[ ${PICUS_COMPLETED} == "false" ]]; then
    echo "Picus was unable to verify ${PICUS_FILE}, check the logs for details."
    exit 1
fi

PICUS_CEXES=$(jq '.findings.critical' ./${PICUS_FILE}-findings.json)

if ((${PICUS_CEXES} != 0)); then
    echo "Picus found a counterexample, check the logs for details."
    exit 1
fi
