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
./league-client.sh # Launches LeagueClient.exe properly. Re-run every time a game ends and the client re-opens, or it will run slowly
# Once the game starts, alt-tab, and run
./game-cgroups.sh 0 # Schedules the game tasks properly. The first argument is the amount of time to wait before running the task in seconds (default: 15)
```
