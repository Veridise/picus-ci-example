#!/bin/bash

set -e

# Relative path from the project's root directory
PICUS_FILE=$1
VERSION_ID=$2

# Launching AuditHub task
task_id=$(ah start-picus-v2-task --version-id ${VERSION_ID} --source ${PICUS_FILE} --solver z3)
# This is mainly for debugging, will let you inspect the logs.
ah monitor-task --task-id $task_id

# Retrieve all metadata from the task.
task_info_json=$(ah get-task-info --task-id $task_id | grep -v "^+")

# Check if Picus found counterexamples
PICUS_CEXES=$(echo "$task_info_json" | jq '.findings_counters.critical')
if ((${PICUS_CEXES} != 0)); then
    echo "Picus found counterexample(s), check the logs for details."
    exit 1
fi

# Check if Picus hit a time out.
PICUS_COMPLETED=$(echo "$task_info_json" | jq '.steps[] | select(.code == "run-picus") | .completed_without_timeout')
if [[ ${PICUS_COMPLETED} == "false" ]]; then
    echo "Picus was unable to verify ${PICUS_FILE} due to timeout, check the logs for details."
    exit 1
fi
