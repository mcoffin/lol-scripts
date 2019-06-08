#!/usr/bin/zsh
set -e
set -x
group="games"
if [ "$1" != "" ]; then
	group="$1"
fi

set_cgroup_cpuset() {
	echo "$1: $2"
	pushd "/sys/fs/cgroup/cpuset/$1"
	echo "$2" > cpuset.cpus
	popd
}

cd /sys/fs/cgroup/cpuset

# Create groups and setup permissions
for cgname in league_game league_client; do
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
set_cgroup_cpuset league_client '0'
set_cgroup_cpuset league_game "1-$((cpu_count-1))"
