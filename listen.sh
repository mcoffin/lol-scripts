#!/bin/bash
set -e

verbose_mode=false
kill_mode=false

while getopts ":v" arg; do
	case $arg in
		k)
			kill_mode=true
			;;
		v)
			verbose_mode=true
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done
export verbose_mode="$verbose_mode"
shift $((OPTIND - 1))

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
	if [ ! -n "$pids" ]; then
		return;
	fi
	if [ "$verbose_mode" == "true" ]; then
		echo "$3 has pids ($pids)"
	fi
	procs_file="/sys/fs/cgroup/$1/$2/cgroup.procs"
	for pid in $pids; do
		count=$(grep -i "$pid" "$procs_file" | wc -l)
		if [ $count -le 0 ]; then
			if [ "$verbose_mode" == "true" ]; then
				printf "setting \"%s\" (%d) as member of \"%s\"\n" "$3" "$pid" "$1:$2"
			fi
			echo "$pid" >> $procs_file
		fi
	done
}

function cpu_usage() {
		client_pid="$(pidof LeagueClient.exe)"
		if [ -n "$client_pid" ] && [ -n "$(pidof 'League of Legends.exe')" ]; then
			client_cpu=$(cpu_usage $client_pid)
			if [ "$verbose_mode" == "true" ]; then
				echo "client ($client_pid) cpu usage: $client_cpu"
			fi
			if [ $(echo "$client_cpu 80.0" | awk '{print ($1 > $2);}') -gt 0 ]; then
				client_cpu_counter=$((client_cpu_counter + 1))
				if [ "$verbose_mode" == "true" ]; then
					echo "client cpu usage over threshold... $client_cpu_counter/$((60 / interval))"
				fi
				interval_threshold=$((60 / interval))
				if [ $client_cpu_counter -ge $interval_threshold ]; then
					if [ "$verbose_mode" == "true" ]; then
						echo "killing client ($client_pid) due to high CPU usage: $client_cpu"
					fi
					kill $client_pid
				fi
			else
				client_cpu_counter=0
			fi
		else
			client_cpu_counter=0
		fi
	# proc_stats="$(sed -E "s/\\(.+\\)\s+//" < /proc/$1/stat)"
	# proc_stats="$proc_stats $(awk '{print $1;}' < /proc/uptime)"
	# proc_stats="$proc_stats $(getconf CLK_TCK)"
	# echo "$proc_stats" | awk '{
	# 	utime = $13;
	# 	stime = $14;
	# 	cutime = $15;
	# 	cstime = $16;
	# 	starttime = $21;
	# 	total_time = utime + stime + cutime + cstime;
	# 	uptime = $52;
	# 	clk_tck = $53;
	# 	used_seconds = (uptime - (starttime / clk_tck));
	# 	usage = 100 * ((total_time / clk_tck) / used_seconds);
	# 	printf "%.2f", usage;
	# }'
	ps -eo pid,pcpu | awk "\$1 == \"$1\" {print \$2;}"
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

client_cpu_counter=0

while true; do
	for i in "${!processes[@]}"; do
		if [ "$verbose_mode" == "true" ]; then
			echo "ensuring \"${processes[$i]}\" is a member of \"cpuset:${groups[$i]}\""
		fi
		ensure_cgroup cpuset "${groups[$i]}" "${processes[$i]}"
	done
	if [ "$kill_mode" == "true" ]; then
		client_pid="$(pidof LeagueClient.exe)"
		if [ -n "$client_pid" ] && [ -n "$(pidof 'League of Legends.exe')" ]; then
			client_cpu=$(cpu_usage $client_pid)
			if [ "$verbose_mode" == "true" ]; then
				echo "client ($client_pid) cpu usage: $client_cpu"
			fi
			if [ $(echo "$client_cpu 80.0" | awk '{print ($1 > $2);}') -gt 0 ]; then
				client_cpu_counter=$((client_cpu_counter + 1))
				if [ "$verbose_mode" == "true" ]; then
					echo "client cpu usage over threshold... $client_cpu_counter/$((60 / interval))"
				fi
				interval_threshold=$((60 / interval))
				if [ $client_cpu_counter -ge $interval_threshold ]; then
					if [ "$verbose_mode" == "true" ]; then
						echo "killing client ($client_pid) due to high CPU usage: $client_cpu"
					fi
					kill $client_pid
				fi
			else
				client_cpu_counter=0
			fi
		else
			client_cpu_counter=0
		fi
	fi
	sleep $interval
done
