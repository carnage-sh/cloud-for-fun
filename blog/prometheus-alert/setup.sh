#!/bin/bash

source ./.env

sed "s~SLACK_API_URI~$SLACK_API_URI~g" <alertmanager.yml >alertmanager.slack

