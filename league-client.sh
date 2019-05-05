#!/bin/bash

nonclient_processes=(
	'wineserver'
	'LeagueClientUx.exe'
	'LeagueClientUxRender.exe'
)

wait_until_pid() {
	pid=""
	while [ -z "$pid" ]; do
		sleep 1
		pid="$(pidof $1)"
	done
}

WINEDEBUG=-all cgexec -g cpuset:league_client wine LeagueClient.exe
pushd /sys/fs/cgroup/cpuset
for pname in "${nonclient_processes[@]}"; do
	wait_until_pid "$pname"
done
sleep 3;
popd
exec bash client-cgroups.sh
