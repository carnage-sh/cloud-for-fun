#!/bin/bash

export BLACK="\033[30;41m"
export BLUE="\033[1;44m"
export RED="\033[40;31m"
export GREEN="\033[40;32m"
export RESET="\033[0m"

while true; do
    START=$(date +"%s")
    VERSION=$(curl --silent --max-time 5 http://$GW/hello | jq -r '.version' 2>/dev/null)
    END=$(date +"%s")
    if [[ "$VERSION" == "v1" ]]; then
        echo -e "${BLACK}API returns $VERSION, time: $(($END - $START)) ${RESET}"
    elif [[ "$VERSION" == "v2" ]]; then
      echo -e "${RED}API returns $VERSION, time: $(($END - $START)) ${RESET}"
    elif [[ "$VERSION" == "v3" ]]; then
      echo -e "${GREEN}API returns $VERSION, time: $(($END - $START)) ${RESET}"
    else
      echo -e "${BLUE}API Error ${RESET}"
    fi
    sleep 1
done

