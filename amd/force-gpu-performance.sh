#!/bin/bash
set -e
card=${1:-card0}
level=${2:-high}

pushd /sys/class/drm/$card/device
echo "$level" | sudo tee power_dpm_force_performance_level
popd
