#!/bin/bash
cd /sys/fs/cgroup/cpuset
sleeptime="${1:-15}"
sleep $sleeptime
pidof 'League of Legends.exe' >> league_game/cgroup.procs
