#!/bin/bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Triggers an on-demand sync for a GCS Data Connector.
# Uses the v1alpha startConnectorRun API.
#
# Usage: bash start_connector_run.sh <project_id> <location> <collection_id>

set -euo pipefail

PROJECT_ID="${1:?Missing project_id}"
LOCATION="${2:?Missing location}"
COLLECTION_ID="${3:?Missing collection_id}"

TOKEN=$(gcloud auth application-default print-access-token 2>/dev/null || gcloud auth print-access-token)

# Use regional endpoint for non-global locations
if [ "${LOCATION}" = "global" ]; then
  API_BASE="https://discoveryengine.googleapis.com"
else
  API_BASE="https://${LOCATION}-discoveryengine.googleapis.com"
fi

# DataConnector is a singleton resource under the collection
CONNECTOR_PATH="projects/${PROJECT_ID}/locations/${LOCATION}/collections/${COLLECTION_ID}/dataConnector"

echo "Starting connector run for: ${CONNECTOR_PATH}"

# Trigger sync via startConnectorRun (v1alpha)
SYNC_RESPONSE=$(curl -s -X POST \
  "${API_BASE}/v1alpha/${CONNECTOR_PATH}:startConnectorRun" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "x-goog-user-project: ${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  -d '{}')

echo "Sync triggered. Response:"
echo "${SYNC_RESPONSE}"
