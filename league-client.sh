#!/bin/bash
set -x
if [ -z "$LOL_DIR" ]; then
	LOL_DIR="$WINEPREFIX/drive_c/Riot Games/League of Legends"
fi

if [ ! -d /sys/fs/cgroup/cpuset/league_client ]; then
	(>&2 echo "league_client cgroup not created.\nConsider running setup.sh first")
	exit 1
fi

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

# If the client isn't already launched, launch it.
current_pid="$(pidof LeagueClient.exe)"
if [ -z "$current_pid" ]; then
	pushd "$LOL_DIR"
	WINEDEBUG=-all DXVK_FILTER_DEVICE_NAME=590 cgexec -g cpuset:league_client wine LeagueClient.exe
	for pname in "${nonclient_processes[@]}"; do
		wait_until_pid "$pname"
	done
	sleep 5;
	popd
fi

# Now, set the processes to the correct cgroups
cd /sys/fs/cgroup/cpuset
for pname in "${nonclient_processes[@]}"; do
	pid=$(pidof "$pname")
	echo "$pname:$pid"
	pidof -S '\n' "$pname" >> cgroup.procs
done
