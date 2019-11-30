#!/bin/bash
set -x
if [ -z "$WINEPREFIX" ]; then
	export WINEPREFIX=$HOME/secure/games/lol
fi
if [ -z "$LOL_DIR" ]; then
	LOL_DIR="$WINEPREFIX/drive_c/Riot Games/League of Legends"
fi

if [ -d /opt/wine-lol/bin ]; then
	export PATH="/opt/wine-lol/bin:$PATH"
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
	WINEDEBUG=-all DXVK_FILTER_DEVICE_NAME=${DXVK_FILTER_DEVICE_NAME:-NAVI} cgexec -g cpuset:league_client wine LeagueClient.exe
	popd
else
	# Now, set the processes to the correct cgroups
	for pname in "${nonclient_processes[@]}"; do
		wait_until_pid "$pname"
	done
	sleep 5;
	cd /sys/fs/cgroup/cpuset
	for pname in "${nonclient_processes[@]}"; do
		pid=$(pidof "$pname")
		echo "$pname:$pid"
		pidof -S '\n' "$pname" >> cgroup.procs
	done
fi
