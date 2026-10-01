#!/bin/sh
# Daily disk-staged backup, weekly restore drill, optional encrypted off-site copy.
set -eu
umask 077
DATA_DIR="${DATA_DIR:-/data}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-14}"
INTERVAL="${BACKUP_INTERVAL_SECONDS:-86400}"
case "$KEEP_DAYS:$INTERVAL" in *[!0-9:]*|:*) echo 'Invalid backup intervals' >&2; exit 1;; esac
[ "$KEEP_DAYS" -ge 1 ] && [ "$KEEP_DAYS" -le 14 ] && [ "$INTERVAL" -ge 60 ] || exit 1
mkdir -p "$BACKUP_DIR/.tmp"
log() { echo "$(date -Iseconds) $*"; }
retention() {
  # Interrupted disk staging must not keep personal data indefinitely.
  find "$BACKUP_DIR/.tmp" -mindepth 1 -maxdepth 1 -type d \( -name 'backup.*' -o -name 'drill.*' -o -name 'restore.*' -o -name 'check.*' \) -mmin +1439 -exec rm -rf -- {} +
  find "$BACKUP_DIR" -maxdepth 1 -type f -name 'valvn-community-*' -mmin +"$((KEEP_DAYS * 1440 - 1))" -delete
  if [ -d "$BACKUP_DIR/pre-restore" ]; then
    find "$BACKUP_DIR/pre-restore" -maxdepth 1 -type f -name 'valvn-community-*' -mmin +20159 -delete
  fi
}
backup_once() (
  stage="$(mktemp -d "$BACKUP_DIR/.tmp/backup.XXXXXX")"
  drill=""
  trap 'rm -rf "$stage"; [ -z "$drill" ] || rm -rf "$drill"' EXIT HUP INT TERM
  final="$BACKUP_DIR/valvn-community-$(date +%Y%m%d-%H%M%S)-${stage##*.}.tgz"
  node dist/backup.js stage "$DATA_DIR" "$stage"
  tar czf "$final.part" -C "$stage" .
  tar tzf "$final.part" >/dev/null
  mv "$final.part" "$final"
  if [ ! -f "$BACKUP_DIR/last-drill" ] || find "$BACKUP_DIR/last-drill" -mmin +10079 | grep -q .; then
    drill="$(mktemp -d "$BACKUP_DIR/.tmp/drill.XXXXXX")"
    tar xzf "$final" -C "$drill"
    node dist/backup.js drill "$drill"
    touch "$BACKUP_DIR/last-drill"
  fi
  if [ -n "${BACKUP_OFFSITE_CMD:-}" ]; then
    [ -n "${BACKUP_AGE_RECIPIENT:-}" ] || { log 'offsite needs BACKUP_AGE_RECIPIENT'; exit 1; }
    age -r "$BACKUP_AGE_RECIPIENT" -o "$final.age.part" "$final"
    mv "$final.age.part" "$final.age"
    BACKUP_FILE="$final.age" sh -c "$BACKUP_OFFSITE_CMD"
  fi
  touch "$BACKUP_DIR/last-success"
  log 'backup and verification succeeded'
)
retention
if [ "${BACKUP_ONCE:-0}" = 1 ]; then backup_once; exit $?; fi
while true; do
  retention
  BACKUP_ONCE=1 sh "$0" || log 'backup FAILED (healthcheck stays stale)'
  sleep "$INTERVAL"
done
