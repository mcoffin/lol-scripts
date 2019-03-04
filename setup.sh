#!/usr/bin/zsh
set -e
set -x
group="games"
if [ "$1" != "" ]; then
	group="$1"
fi
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
echo '0' > league_client/cpuset.cpus
echo '1-11' > league_game/cpuset.cpus
