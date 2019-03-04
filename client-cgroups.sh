#!/bin/bash
cd /sys/fs/cgroup/cpuset
for pname in wineserver LeagueClientUx.exe LeagueClientUxRender.exe; do
	pid=$(pidof "$pname")
	echo "$pname:$pid"
	echo $pid >> cgroup.procs
done
