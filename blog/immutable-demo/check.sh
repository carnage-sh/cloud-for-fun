#!/bin/bash

curl http://127.0.0.1:8500/v1/agent/services |jq
curl http://127.0.0.1:8500/v1/health/checks/color  |jq
