#!/usr/bin/python

import argparse
from procfs import Process
from sys import stderr
from time import sleep

def add_pid_to_cgroup(cgroup, pid):
    with open(f"/sys/fs/cgroup/{cgroup}/cgroup.procs", 'a') as f:
        f.write("%d\n" % pid)

def check_cgroups():
    pids = []
    with open('/sys/fs/cgroup/cpuset/league_client/cgroup.procs', 'r') as f:
        lines = []
        for line in f:
            lines.append(line)
        processes = map(lambda line: Process(int(line)), lines)
        client_processes = list(filter(lambda p: p.name() == "LeagueClient.ex", processes))
        if len(client_processes) <= 0:
            stderr.write("No LeagueClient process. Exiting.\n")
            return -1
        else:
            print(f"LeagueClient.exe: {client_processes[0].id}")
        for p in filter(lambda p: p.name() != "LeagueClient.exe", processes):
            if p.name() != "LeagueClient.ex":
                pids.append(pid)
    for pid in pids:
        print(f"game: {pid}")
        add_pid_to_cgroup('cpuset/league_game', pid)

def main():
    parser = argparse.ArgumentParser(description='Manage LoL cgroups')
    parser.add_argument('--delay', type=int, default=15)
    parser.add_argument('--no-loop', action='store_true', default=False)
    config = parser.parse_args()
    while True:
        print("checking cgroups...")
        check_cgroups()
        if config.no_loop:
            return 0
        sleep(config.delay)

if __name__ == '__main__':
    main()
