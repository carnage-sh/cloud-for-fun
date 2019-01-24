#!/bin/bash

export BLUE="\033[1;44m"
export RED="\033[0;41m"
export RESET="\033[0m"

while true; do
    echo -e "${RED}This is a blue text."${RESET}
    echo -e "${BLUE}This is a blue text.${RESET}"
    sleep 1
done

