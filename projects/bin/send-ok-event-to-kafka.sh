#!/bin/bash -ue
# ******************************************************************************
# Execute an API smoke test request.
#
# Credits:
#   Contact:   arnold.somogyi@gmail.com
#   Copyright: Copyright (c) 2020-2026 Remal Software
#
#   This work is licensed under the Creative Commons Attribution-
#   NonCommercial 4.0 International License. To view a copy of this license,
#   visit: https://creativecommons.org
#
#   You are free to share and adapt the material for personal or hobby
#   purposes, provided you give appropriate credit and do not use the material
#   for commercial gain.
# ******************************************************************************
curl -k -X POST https://localhost:14314/api/kafka/send \
  -H "Content-Type: application/json" \
  -d '{
  "sourceSystem": "whatewer system",
  "userId": "peter",
  "payload": "{\"comment\": \"a custom event from the rest endpoint\"}",
  "createdInUtc": [
    2025,
    1,
    20,
    21,
    33,
    13
  ]
}'
