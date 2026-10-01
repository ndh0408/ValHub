#!/bin/sh
# Local Docker host runbook. Dry-run by default; --yes restores after staging + an undo backup.
set -eu
umask 077
ARCHIVE="${1:-}"
CONFIRM="${2:-}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
COMPOSE="${COMPOSE:-docker compose}"
IMAGE="${IMAGE:-valvn-community:latest}"
VOLUME="${VOLUME:-valvn-community-data}"
[ -f "$ARCHIVE" ] || { echo 'usage: restore.sh <archive.tgz> [--yes]' >&2; exit 1; }
ARCHIVE_DIR="$(cd "$(dirname "$ARCHIVE")" && pwd)"
ARCHIVE_NAME="$(basename "$ARCHIVE")"
mkdir -p "$BACKUP_DIR/.tmp" "$BACKUP_DIR/pre-restore"
BACKUP_ABS="$(cd "$BACKUP_DIR" && pwd)"
# Disk staging in /work, no 512 MB tmpfs; this invocation never touches the live volume.
docker run --rm --user 1000:1000 --entrypoint sh -v "$ARCHIVE_DIR":/in:ro -v "$BACKUP_ABS":/work "$IMAGE" -c '
  set -eu
  stage="$(mktemp -d /work/.tmp/check.XXXXXX)"
  trap '\''rm -rf "$stage"'\'' EXIT HUP INT TERM
  node dist/backup.js extract "/in/$1" "$stage"
  node dist/backup.js verify "$stage"
' sh "$ARCHIVE_NAME"
if [ "$CONFIRM" != --yes ]; then echo 'dry run verified; re-run with --yes to restore'; exit 0; fi
$COMPOSE stop valvn-community valvn-backup
# The current erasure ledger remains in /data. Undo copies also expire after 14 days.
docker run --rm --user 1000:1000 --entrypoint sh -e BACKUP_ONCE=1 -e BACKUP_DIR=/out -e BACKUP_KEEP_DAYS=14 \
  -v "$VOLUME":/data -v "$BACKUP_ABS/pre-restore":/out "$IMAGE" ops/backup-loop.sh
# Re-check before mutation. Merge snapshot ledger into current ledger and replay BEFORE serving restored data.
docker run --rm --user 1000:1000 --entrypoint sh -v "$VOLUME":/data -v "$ARCHIVE_DIR":/in:ro -v "$BACKUP_ABS":/work "$IMAGE" -c '
  set -eu
  stage="$(mktemp -d /work/.tmp/restore.XXXXXX)"
  trap '\''rm -rf "$stage"'\'' EXIT HUP INT TERM
  node dist/backup.js extract "/in/$1" "$stage"
  if [ -f "$stage/erasures.jsonl" ]; then cat "$stage/erasures.jsonl" >> /data/erasures.jsonl; fi
  rm -f /data/community.db /data/community.db-wal /data/community.db-shm
  rm -rf /data/media /data/quarantine
  mv "$stage/snap.db" /data/community.db
  if [ -d "$stage/media" ]; then mv "$stage/media" /data/media; else mkdir -p /data/media; fi
  node dist/cli.js replay-erasures
  node -e '\''const D = require("better-sqlite3"); const d = new D("/data/community.db"); d.prepare("DELETE FROM media WHERE status = ?").run("quarantined"); d.close();'\''
' sh "$ARCHIVE_NAME"
$COMPOSE up -d valvn-community valvn-backup
healthy() { $COMPOSE exec -T valvn-community node -e "fetch('http://127.0.0.1:8080/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))" >/dev/null 2>&1; }
i=0
until healthy || [ "$i" -ge 30 ]; do i=$((i + 1)); sleep 2; done
healthy || { echo 'restore healthcheck FAILED; inspect services and undo archive' >&2; exit 1; }
$COMPOSE exec -T valvn-community node dist/cli.js stats
echo 'restore verified; undo archives are in pre-restore/ (14-day retention)'
