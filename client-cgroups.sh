#!/bin/bash
cd /sys/fs/cgroup/cpuset
nonclient_processes=(
	'wineserver'
	'LeagueClientUx.exe'
	'LeagueClientUxRender.exe'
)
for pname in "${nonclient_processes[@]}"; do
	pid=$(pidof "$pname")
	echo "$pname:$pid"
	pidof -S '\n' "$pname" >> cgroup.procs
done
