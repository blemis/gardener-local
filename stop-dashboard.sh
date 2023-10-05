#!/usr/bin/env bash


BACK_PORT="9050"
FRONT_PORT="3030"
HTTP_PORT="8080"

function free_port() {
  lsof -ti tcp:$1| xargs kill -9
}

printf "\nStopping Gardener Dashboard...\n\n"
free_port $BACK_PORT > /dev/null 2>&1 
free_port $FRONT_PORT > /dev/null 2>&1 
free_port $HTTP_PORT > /dev/null 2>&1 
(pkill -f dashboard > /dev/null 2>&1) 
(kill $(jobs -p) > /dev/null 2>&1)