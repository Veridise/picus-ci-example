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

# Retreive all metadata from the task.
task_info_json=$(ah get-task-info --task-id $task_id | grep -v "^+")

# Download findings json.
JSON_FILE=./${TIMESTAMP}-findings.json
picus_findings_id=$(echo "$task_info_json" | jq -r '.artifacts[] | select(.name == "findings.json") | .id')
ah get-task-artifact --task-id $task_id --artifact-id $picus_findings_id --output-file ${JSON_FILE}

# Check if Picus hit a time out or produced unknown findings.
PICUS_COMPLETED=$(jq '.completed' ${JSON_FILE})

if [[ ${PICUS_COMPLETED} == "false" ]]; then
    echo "Picus was unable to verify ${PICUS_FILE}, check the logs for details."
    exit 1
fi

PICUS_CEXES=$(jq '.findings.critical' ${JSON_FILE})

if ((${PICUS_CEXES} != 0)); then
    echo "Picus found a counterexample, check the logs for details."
    exit 1
fi
