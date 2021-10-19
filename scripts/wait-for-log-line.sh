#!/bin/bash

CONTAINER=$1
LOG_LINE=$2

until poetry run docker-compose logs "$CONTAINER" | grep "$LOG_LINE"; do
    echo -n .
    sleep 1
done
