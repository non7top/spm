#!/bin/sh
# Installs dist/*.deb on a bare Ubuntu image and exercises the client for real.
set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq "${DIST:-/dist}"/*.deb

RD=/usr/local/rdiff-backup/bin/rdiff-backup
$RD --version | grep -qx 'rdiff-backup 1.2.8'

# backup_new enables --no-fsync only if the installed Main.py mentions it.
grep -rq no_fsync /usr/local/rdiff-backup/lib/python2.7/site-packages/rdiff_backup/Main.py

mkdir -p /tmp/src /tmp/dst
echo hello > /tmp/src/f
$RD --no-fsync /tmp/src /tmp/dst
sleep 2
echo again > /tmp/src/f
$RD --no-fsync /tmp/src /tmp/dst
$RD --list-increments /tmp/dst | grep -q increments
echo "OK: $(. /etc/os-release && echo "$VERSION_ID")"
