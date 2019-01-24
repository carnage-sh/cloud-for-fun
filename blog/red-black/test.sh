#!/bin/bash

export BLACK="\033[30;41m"
export BLUE="\033[1;44m"
export RED="\033[40;31m"
export RESET="\033[0m"

while true; do
    COLOR=$(curl --silent http://localhost:9000/ | jq -r '.color')
    if [[ "$COLOR" == "red" ]]; then
      echo -e "${RED}API returns red  ${RESET}"
    elif [[ "$COLOR" == "black" ]]; then
      echo -e "${BLACK}API returns black${RESET}"
    else
      echo -e "${BLUE}API returns an ERROR${RESET}"
    fi
    sleep 1
done

