#!/bin/sh
# Restore the community server from a backup archive made by ops/backup-loop.sh.
#
#   scripts/restore.sh /path/to/valvn-community-YYYYmmdd-HHMM.tgz            # dry run: checks the archive, changes nothing
#   scripts/restore.sh /path/to/valvn-community-YYYYmmdd-HHMM.tgz --yes      # really restore
#
# Run it on the Docker host, from anywhere (it finds ops/ next to itself; docker compose must find the
# stack: run it from server/community or set COMPOSE="docker compose -f /path/docker-compose.yml").
# What it does (with --yes):
#   1. verifies the archive (contains snap.db and opens as a healthy SQLite database);
#   2. stops valvn-community and valvn-backup;
#   3. saves the CURRENT data as a normal backup archive in $BACKUP_DIR/pre-restore/ (your undo: restore that one);
#   4. replaces community.db (+ WAL files) and media/ in the data volume with the archive's; the quarantine
#      directory is removed too (it is not part of backups) and rows that were quarantined are dropped;
#   5. starts the services again, waits for /healthz and prints row counts.
#
# Needs: docker compose v2 and the valvn-community:latest image (docker compose build). No secrets needed.
# Environment: BACKUP_DIR (default ./backups), COMPOSE (default "docker compose"), IMAGE (default valvn-community:latest),
#              VOLUME (default valvn-community-data).
set -eu

ARCHIVE="${1:-}"
CONFIRM="${2:-}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
COMPOSE="${COMPOSE:-docker compose}"
IMAGE="${IMAGE:-valvn-community:latest}"
VOLUME="${VOLUME:-valvn-community-data}"

die() { echo "restore: $*" >&2; exit 1; }
say() { echo "restore: $*"; }

[ -n "$ARCHIVE" ] || die "usage: scripts/restore.sh <backup.tgz> [--yes]"
[ -f "$ARCHIVE" ] || die "no such file: $ARCHIVE"
command -v docker >/dev/null 2>&1 || die "docker not found"

ARCHIVE_DIR="$(cd "$(dirname "$ARCHIVE")" && pwd)"
ARCHIVE_NAME="$(basename "$ARCHIVE")"
OPS_DIR="$(cd "$(dirname "$0")/.." && pwd)/ops"
[ -f "$OPS_DIR/backup-loop.sh" ] || die "cannot find ops/backup-loop.sh next to this script"

# ---- 1. verify the archive (in a throwaway container: the host may have no tar / sqlite tooling) -------------
say "checking $ARCHIVE_NAME ..."
docker run --rm --user 1000:1000 --entrypoint sh -v "$ARCHIVE_DIR":/in:ro --tmpfs /tmp:size=512m "$IMAGE" -c '
  set -eu
  tar tzf "/in/$1" > /tmp/list
  grep -qx "snap.db" /tmp/list || { echo "archive has no snap.db" >&2; exit 1; }
  tar xzf "/in/$1" -C /tmp snap.db
  node -e "
    const D = require(\"better-sqlite3\");
    const d = new D(\"/tmp/snap.db\", { readonly: true });
    const ok = d.pragma(\"integrity_check\", { simple: true });
    if (ok !== \"ok\") { console.error(\"integrity_check: \" + ok); process.exit(1); }
    const n = (t) => d.prepare(\"SELECT COUNT(*) AS n FROM \" + t).get().n;
    console.log(\"snapshot ok: \" + n(\"users\") + \" users, \" + n(\"posts\") + \" posts, \" + n(\"media\") + \" media rows, \" + n(\"skin_votes\") + \" votes\");
  "
  echo "media files in archive: $(grep -c "^media/u/.*\.\(jpg\|png\|webp\)$" /tmp/list || true)"
' sh "$ARCHIVE_NAME" || die "the archive is not a valid backup"

if [ "$CONFIRM" != "--yes" ]; then
  say "dry run: nothing changed. Re-run with --yes to restore (the current data is saved first)."
  exit 0
fi

# ---- 2-3. stop services, save the current state as a backup archive -----------------------------------------
mkdir -p "$BACKUP_DIR/pre-restore"
BACKUP_ABS="$(cd "$BACKUP_DIR" && pwd)"
say "stopping services ..."
$COMPOSE stop valvn-community valvn-backup >/dev/null 2>&1 || true

say "saving the current data to $BACKUP_DIR/pre-restore/ ..."
docker run --rm --user 1000:1000 --entrypoint sh \
  -e BACKUP_ONCE=1 -e BACKUP_DIR=/out -e BACKUP_KEEP_DAYS=36500 \
  -v "$VOLUME":/data -v "$BACKUP_ABS/pre-restore":/out -v "$OPS_DIR/backup-loop.sh":/backup-loop.sh:ro \
  --tmpfs /tmp:size=512m "$IMAGE" /backup-loop.sh \
  || die "could not save the current data; nothing was changed (start the services again: docker compose up -d)"
UNDO="$(ls -1t "$BACKUP_ABS"/pre-restore/valvn-community-*.tgz 2>/dev/null | head -1 || true)"

# ---- 4. replace database and media ----------------------------------------------------------------------------
say "restoring ..."
docker run --rm --user 1000:1000 --entrypoint sh -v "$VOLUME":/data -v "$ARCHIVE_DIR":/in:ro --tmpfs /tmp:size=512m "$IMAGE" -c '
  set -eu
  umask 077
  tar xzf "/in/$1" -C /tmp
  rm -f /data/community.db /data/community.db-wal /data/community.db-shm
  rm -rf /data/media /data/quarantine
  mv /tmp/snap.db /data/community.db
  if [ -d /tmp/media ]; then mv /tmp/media /data/media; else mkdir -p /data/media; fi
  node -e "
    const D = require(\"better-sqlite3\");
    const d = new D(\"/data/community.db\");
    const r = d.prepare(\"DELETE FROM media WHERE status = ?\").run(\"quarantined\");
    console.log(\"quarantined media rows dropped: \" + r.changes);
    d.close();
  "
' sh "$ARCHIVE_NAME" || die "restore failed part-way: the previous data is in ${UNDO:-$BACKUP_DIR/pre-restore/} (README: Restore runbook)"

# ---- 5. start again ------------------------------------------------------------------------------------------
say "starting services ..."
$COMPOSE up -d valvn-community valvn-backup >/dev/null
healthy() {
  $COMPOSE exec -T valvn-community node -e "fetch('http://127.0.0.1:8080/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))" >/dev/null 2>&1
}
i=0
until healthy || [ "$i" -ge 30 ]; do i=$((i + 1)); sleep 2; done
if healthy; then
  say "healthy again."
else
  say "WARNING: the API did not become healthy within 60 s: check 'docker compose logs valvn-community'."
fi
$COMPOSE exec -T valvn-community node dist/cli.js stats || true
say "done. To undo: scripts/restore.sh ${UNDO:-$BACKUP_DIR/pre-restore/<archive>} --yes"
