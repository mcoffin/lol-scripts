#!/bin/bash
set -e
set -x

if [ "$WINEPREFIX" == "" ]; then
	cd /var/games/lol
	export WINEPREFIX=`pwd`
else
	cd "$WINEPREFIX"
fi
cd "drive_c/Riot Games/League of Legends"

wineserver -k
wineserver -w
WINEDEBUG=-all cgexec -g cpuset:league_client wine LeagueClient.exe

uxpid=""
uxrpid=""

while [ "$uxpid" == "" ] || [ "$uxrpid" == "" ]; do
	sleep 1;
	uxpid="$(pidof "LeagueClientUx.exe" || true)"
	uxrpid="$(pidof "LeagueClientUxRender.exe" || true)"
done
echo "Client started..."
bash $(dirname "$0")/client-cgroups.sh
