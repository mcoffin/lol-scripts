#!/bin/bash
set -e
set -x

group="games"
if [ "$1" != "" ]; then
	group="$1"
fi

if [ "$2" != "" ]; then
	client_group="$2"
else
	client_group="league_client"
fi

if [ ! -z "$3" ]; then
	game_group="$3"
else
	game_group="league_game"
fi

set_cgroup_cpuset() {
	echo "$1: $2"
	pushd "/sys/fs/cgroup/cpuset/$1"
	echo "$2" > cpuset.cpus
	popd
}

cd /sys/fs/cgroup/cpuset

# Create groups and setup permissions
for cgname in $client_group $game_group; do
	if [ ! -d "$cgname" ]; then
		mkdir -p "$cgname"
	fi
	cp cpuset.mems "$cgname"
	chgrp "$group" "$cgname"
	chgrp "$group" $cgname/*

	pushd "$cgname"
	ls -al . | awk '{if ($1 ~ /^-rw/) {print $9;}}' | xargs chmod g+rw
	popd
done
chgrp "$group" cgroup.procs
chmod g+rw cgroup.procs

# Now set cores
cpu_count=$(nproc)
set_cgroup_cpuset $client_group '0'
set_cgroup_cpuset $game_group "1-$((cpu_count-1))"
