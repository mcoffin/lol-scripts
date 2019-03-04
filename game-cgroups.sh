#!/bin/bash
cd /sys/fs/cgroup/cpuset
if [ "$1" != "" ]; then
	sleeptime="$1"
else
	sleeptime=15
fi
sleep $sleeptime
pidof 'League of Legends.exe' >> league_game/cgroup.procs
