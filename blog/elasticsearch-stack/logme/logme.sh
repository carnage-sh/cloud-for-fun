#!/bin/sh

while true; do
    export ME=$(grep -m1 -ao '[0-9]' /dev/urandom | sed s/0/10/ | head -n1)
    if [ "$ME" == "1" ]; then
        echo "$(date +"[%d/%m/%Y:%H:%M:%S%z]") [WARN] - Running logme.sh ($ME)"
    else
        echo "$(date +"[%d/%m/%Y:%H:%M:%S%z]") [INFO] - Running logme.sh ($ME)"
    fi
    sleep 1
done

