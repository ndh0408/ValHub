#!/bin/sh
# ValVN community backup loop. Runs inside the valvn-backup container (same image as the API, unprivileged
# user, read-only root): every BACKUP_INTERVAL_SECONDS it writes
#
#   /backup/valvn-community-YYYYmmdd-HHMM.tgz   containing  snap.db  (consistent SQLite snapshot)  and  media/
#
# and deletes archives older than BACKUP_KEEP_DAYS. The quarantine directory (content hidden by reports,
# already purged after 30 days) is deliberately NOT backed up, to keep hidden content out of long-lived copies.
#
# Privacy: an archive still contains what users later deleted, until it ages out (BACKUP_KEEP_DAYS,
# default 14) — that is the retention stated in the README / privacy policy. Files are created 0600.
#
# BACKUP_ONCE=1  take one backup now and exit (manual backup, tests). Exit status 0 = ok, 1 = failed.
set -u
umask 077

DATA_DIR="${DATA_DIR:-/data}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-14}"
INTERVAL="${BACKUP_INTERVAL_SECONDS:-86400}"
TMP="${BACKUP_TMP:-/tmp}"

log() { echo "$(date -Iseconds) $*"; }

backup_once() {
  stamp="$(date +%Y%m%d-%H%M)"
  final="$BACKUP_DIR/valvn-community-$stamp.tgz"
  part="$final.part"
  rm -f "$TMP/snap.db" "$part"

  # 1) consistent snapshot of the live database (SQLite online backup API, WAL-aware) + integrity check
  if ! DATA_DIR="$DATA_DIR" SNAP="$TMP/snap.db" node -e "
    const D = require('better-sqlite3');
    const src = new D(process.env.DATA_DIR + '/community.db');
    src.backup(process.env.SNAP).then(() => {
      src.close();
      const snap = new D(process.env.SNAP, { readonly: true });
      const ok = snap.pragma('integrity_check', { simple: true });
      snap.close();
      if (ok !== 'ok') { console.error('integrity_check: ' + ok); process.exit(1); }
    }).catch((e) => { console.error(e.message); process.exit(1); });
  "; then
    log "backup FAILED: database snapshot"
    rm -f "$TMP/snap.db"
    return 1
  fi

  # 2) archive snapshot + media (media may not exist yet); written under a temporary name, then renamed
  if [ -d "$DATA_DIR/media" ]; then
    tar czf "$part" -C "$TMP" snap.db -C "$DATA_DIR" media
  else
    tar czf "$part" -C "$TMP" snap.db
  fi
  status=$?
  rm -f "$TMP/snap.db"
  # tar exit 1 = "file changed as we read it" (an upload landed): the archive is still usable
  if [ "$status" -gt 1 ] || ! tar tzf "$part" >/dev/null 2>&1; then
    log "backup FAILED: archive"
    rm -f "$part"
    return 1
  fi
  mv "$part" "$final"
  log "backup ok: $(basename "$final") ($(wc -c < "$final") bytes)"

  # 3) retention (only after a successful backup, so a broken run never deletes the last good one)
  find "$BACKUP_DIR" -maxdepth 1 -name 'valvn-community-*.tgz' -mtime +"$KEEP_DAYS" -print -delete 2>/dev/null \
    | while read -r old; do log "removed old backup: $(basename "$old")"; done
  find "$BACKUP_DIR" -maxdepth 1 -name 'valvn-community-*.tgz.part' -mmin +60 -delete 2>/dev/null
  return 0
}

if [ "${BACKUP_ONCE:-0}" = "1" ]; then
  backup_once
  exit $?
fi

log "backup loop started: every ${INTERVAL}s, keeping ${KEEP_DAYS} days"
while true; do
  # After a container restart, do not take an extra backup if a recent one exists: wait out the interval.
  newest="$(find "$BACKUP_DIR" -maxdepth 1 -name 'valvn-community-*.tgz' -printf '%T@\n' 2>/dev/null | sort -n | tail -1)"
  if [ -n "$newest" ]; then
    age=$(( $(date +%s) - ${newest%.*} ))
    if [ "$age" -lt "$INTERVAL" ]; then
      wait_for=$(( INTERVAL - age ))
      log "last backup is ${age}s old, next in ${wait_for}s"
      sleep "$wait_for"
    fi
  fi
  backup_once || true
  sleep "$INTERVAL"
done
