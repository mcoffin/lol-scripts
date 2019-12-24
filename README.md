# lol-scripts

`lol-scripts` is a collection of shell scripts for helping to run League of Legends on Linux in Wine.

LeagueClient has some concurrency bugs that may cause crashing on startup, and another that will cause a tight loop where the client eats up tons of CPU. As a workaround for these problems, `lol-scripts` uses `cgroups` to schedule the LeagueClient process on only one core, and put the other related processes on all cores.


# Usage

## Pre-requisites

`lol-scripts` requires a `bash` shell, and the `cgexec` program from `libcgroup`.

If you're on an arch-based distro, this can be obtained from the [`libcgroup`](https://aur.archlinux.org/packages/libcgroup) package on [AUR](https://aur.archlinux.org).

## TL;DR

```bash
sudo ./setup.sh # Creates cgroups, and sets permissions properly.
WINEPREFIX=/path/to/pfx ./league-client.sh # Runs the league client in the cgroups created by setup.sh
./game-cgroups.py & # Runs in the background to re-schedule non-client processes to run on all cores
```

# Scripts

| Script | Usage | Example | Description |
| ------ | ----- | ------- | ----------- |
| `setup.sh` | `sudo ./setup.sh [unix_group] [client_cgroup] [game_cgroup]` | `sudo ./setup.sh games league_client league_game` | Sets up cgroups with the right permissions for the given group. Replace the `[unix_group]` argument with your username to give your user access to the cgroups. This script must be run as a privileged user, but then the rest may be run as a regular user. |
| `league-client.sh` | `./league-client.sh [client_cgroup]` | `WINEPREFIX=/path/to/pfx ./league-client.sh cpuset/league_client` | Launches the league of legends client in the restricted cgroup |
| `game-cgroups.py` | `./game-cgroups.py [options]` | `./game-cgroups.py --delay 10 --client-cgroup cpuset/league_client --game-cgroup cpuset/league_game` | Monitors the client cgroup, and puts all processes that aren't the client into the game cgroup |
