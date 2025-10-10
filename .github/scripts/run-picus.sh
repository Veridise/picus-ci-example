#!//usr/bin/env bash

set -e

# Relative path from the project's root directory
PICUS_FILE=$1
VERSION_ID=$2

# Launching AuditHub task
task_id=$(ah start-picus-v2-task --version-id ${VERSION_ID} --source ${PICUS_FILE} --solver z3)

echo "task_id=$task_id"

# This is mainly for debugging, will let you inspect the logs.
ah monitor-task --task-id $task_id

# This will check for counterexamples (and exit with 1) and a potential timeout (and exit with 2)
# Since it is the last command of the script, its exit code will become the script's exit code
ah get-task-info --task-id $task_id --output none --verify --check_completed
