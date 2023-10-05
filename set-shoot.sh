#!/bin/bash
gardenctl kubeconfig --raw --garden garden-local --project local --shoot local >> crap.yaml
export KUBECONFIG=./crap.yaml
printf "\nKUBECONFIG now set to SHOOT cluster...\n\n"
