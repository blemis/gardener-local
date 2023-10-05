#!/usr/bin/env bash
#
# Wrapper around wait-for.sh
#
SRC=${HOME}/scripts
. ${SRC}/wait-for.sh seed local GardenletReady SeedSystemComponentsHealthy ExtensionsReady