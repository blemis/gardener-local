#!/usr/bin/env bash
#
# Wrapper around wait-for.sh
#
SRC=${HOME}/scripts
NAMESPACE=garden-local ${SRC}/wait-for.sh shoot local APIServerAvailable ControlPlaneHealthy ObservabilityComponentsHealthy EveryNodeReady SystemComponentsHealthy