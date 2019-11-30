#!/usr/bin/python

from procfs import Process

def add_pid_to_cgroup(cgroup, pid):
    with open(f"/sys/fs/cgroup/{cgroup}/cgroup.procs", 'a') as f:
        f.write("%d\n" % pid)

def main():
    pids = []
    with open('/sys/fs/cgroup/cpuset/league_client/cgroup.procs', 'r') as f:
        for line in f:
            pid = int(line)
            p = Process(pid)
            print(f"checking pid {pid}: {p.name()}")
            if p.name() != "LeagueClient.ex":
                pids.append(pid)
    for pid in pids:
        print(f"game: {pid}")
        add_pid_to_cgroup('cpuset/league_game', pid)

if __name__ == '__main__':
    main()
