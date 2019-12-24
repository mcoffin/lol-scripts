#!/bin/bash
set -x

client_cgroup=${1:-cpuset/league_client}

echo_err() {
	echo "$@" >&2
}

if [ ! -d "$WINEPREFIX" ]; then
	echo_err "WINEPREFIX is not set. please set the correct WINEPREFIX for your league of legends installation."
	exit 1
fi

if [ -z "$LOL_DIR" ]; then
	LOL_DIR="$WINEPREFIX/drive_c/Riot Games/League of Legends"
fi

# If we have wine-lol, then we should use it
if [ -d /opt/wine-lol/bin ]; then
	export PATH="/opt/wine-lol/bin:$PATH"
fi

# Exit if the cgroup doesn't exist
if [ ! -d /sys/fs/cgroup/$client_cgroup ]; then
	echo_err "league_client cgroup not created.\nConsider running setup.sh first"
	exit 1
fi

pushd "$LOL_DIR"
WINEDEBUG=-all DXVK_FILTER_DEVICE_NAME=${DXVK_FILTER_DEVICE_NAME:-NAVI} cgexec -g cpuset:league_client wine LeagueClient.exe
popd
