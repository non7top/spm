#!/bin/sh
# Packages the spm-built rdiff-backup prefix as a .deb. Run after
# `./spm install rdiff-backup` with SPM_PREFIX=/usr/local/rdiff-backup.
set -eu

cd "$(dirname "$0")/.."

PREFIX=/usr/local/rdiff-backup
[ -x "$PREFIX/bin/rdiff-backup" ] || { echo "build.sh: $PREFIX/bin/rdiff-backup missing; run './spm install rdiff-backup' first" >&2; exit 1; }

# The recipe is the single source of truth for the upstream version.
VERSION=$(bash -c 'source recipes/rdiff-backup && echo "${ver}-${rel}"')
PKG=rdiff-backup-spm

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
chmod 0755 "$STAGE"

install -d "$STAGE/DEBIAN" "$STAGE/usr/local" "$STAGE/usr/local/spm"
cp -a "$PREFIX" "$STAGE/usr/local/rdiff-backup"
rm -rf "$STAGE/usr/local/rdiff-backup/.spm"
install -m 0644 local.env "$STAGE/usr/local/spm/local.env"
sed -i 's|^export SPM_PREFIX=.*|export SPM_PREFIX=/usr/local/rdiff-backup|' "$STAGE/usr/local/spm/local.env"

cat > "$STAGE/DEBIAN/control" <<EOC
Package: $PKG
Version: $VERSION
Section: admin
Priority: optional
Architecture: amd64
Maintainer: Vladimir Berezhnoy <non7top@gmail.com>
Description: rdiff-backup 1.2.8 (no-fsync patched) with a private Python 2 runtime
 Built by spm into /usr/local/rdiff-backup, with its own Python 2, OpenSSL and
 librsync, for backing up to servers still running rdiff-backup 1.x (1.x and
 2.x are wire-incompatible). Does not touch /usr/bin, so it coexists with the
 distribution rdiff-backup package; source /usr/local/spm/local.env to put it
 first on PATH.
EOC

mkdir -p dist
OUT="dist/${PKG}_${VERSION}_amd64.deb"
dpkg-deb --build --root-owner-group "$STAGE" "$OUT"
echo "built $OUT"
