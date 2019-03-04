#!/bin/bash
set -e

verbose_mode=false

while getopts ":v" arg; do
	case $arg in
		v)
			verbose_mode=true
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done

# Parse arguments
interval=5
if [ "$1" != "" ]; then
	if [ "$1" -eq "$1"]; then
		interval="$1"
	fi
fi

# ensure_group CGTYPE CGNAME PROC_NAME
# ensure that all processes with the name PROC_NAME are scheduled under a given cgroup
function ensure_cgroup() {
	pids="$(pidof "$3" || true)"
	# If no process that matches exists, then we're done
	if [ ! -n "$pid" ]; then
		return;
	fi
	procs_file="/sys/fs/cgroup/$1/$2/cgroup.procs"
	for pid in $pids; do
		count=$(grep -i "$pid" "$procs_file" | wc -l)
		if [ $count -le 0 ]; then
			if [ "$verbose_mode" == "true" ]; then
				printf "setting \"%s\" (%d) as member of %s\n" "$3" "$pid" "$1:$2"
			fi
			echo "$pid" >> $procs_file
		fi
	done
}

processes=(
	'League of Legends.exe'
	'LeagueClient.exe'
	'LeagueClientUx.exe'
	'LeagueClientUxRender.exe'
)
groups=(
	'league_game'
	'league_client'
	'.'
	'.'
)

while true; do
	for i in "${!processes[@]}"; do
		if [ "$verbose_mode" == "true" ]; then
			echo "ensuring \"${processes[$i]}\" is a member of \"cpuset/${groups[$i]}\""
		fi
		ensure_cgroup cpuset "${groups[$i]}" "${processes[$i]}"
	done
	sleep $interval
done
