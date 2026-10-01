#!/bin/sh
# Isolated image check; no API service, compose stack or production volume is started.
set -eu
umask 077
SMOKE_ROOT="$(mktemp -d /tmp/wp-srv.XXXXXX)"
export SMOKE_ROOT
trap 'rm -rf "$SMOKE_ROOT"' EXIT HUP INT TERM
export DATA_DIR="$SMOKE_ROOT/data" BACKUP_DIR="$SMOKE_ROOT/backups" BACKUP_ONCE=1
mkdir -p "$DATA_DIR" "$BACKUP_DIR/pre-restore"
node --input-type=module <<'JS'
import assert from 'node:assert/strict';
import sharp from 'sharp';
import fs from 'node:fs/promises';
import path from 'node:path';
import { createServer } from 'node:http';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { decodeImage } from './dist/image-decoder.js';
const input = await sharp({ create: { width: 2, height: 3, channels: 3, background: 'red' } })
  .withMetadata({ orientation: 6 }).jpeg().toBuffer();
const clean = await decodeImage(input);
const metadata = await sharp(clean.bytes).metadata();
assert.equal(metadata.width, 3);
assert.equal(metadata.height, 2);
assert.equal(metadata.exif, undefined);
for (const name of ['last-success', 'last-drill']) await fs.writeFile(path.join(process.env.BACKUP_DIR, name), '');
const server = createServer((_req, res) => { res.setHeader('content-type', 'application/json');
  res.end(JSON.stringify({ writable: true, freeBytes: 512 * 1024 * 1024, walBytes: 0,
    loopLagMs: 0, http: { requests: 10, serverErrors: 0 } })); });
await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
try {
  const { stdout } = await promisify(execFile)(process.execPath, ['dist/watchdog.js', '--once'], {
    env: { ...process.env, WATCHDOG_URL: `http://127.0.0.1:${server.address().port}/healthz/deep`,
      WATCHDOG_BACKUP_DIR: process.env.BACKUP_DIR, WATCHDOG_ALERT_HOOK: '' }, timeout: 10000 });
  assert.equal(JSON.parse(stdout).watchdog, 'ok');
} finally { await new Promise((resolve) => server.close(resolve)); }
// Do not make the later backup/drill check pass using the monitoring fixture markers.
for (const name of ['last-success', 'last-drill']) await fs.unlink(path.join(process.env.BACKUP_DIR, name));
console.log('native decoder and watchdog smoke passed');
JS
node --input-type=module <<'JS'
import fs from 'node:fs';
import path from 'node:path';
import { openDatabase } from './dist/db/database.js';
import { ErasureLedger } from './dist/erasures.js';
const dir = process.env.DATA_DIR;
const db = openDatabase(path.join(dir, 'community.db'));
const id = 'a'.repeat(32), key = `u/${id}/${'b'.repeat(32)}.png`;
db.prepare('INSERT INTO users(id,created_at,updated_at) VALUES(?,?,?)').run(id, 1, 1);
db.prepare('INSERT INTO media(key,user_id,content_type,size,created_at) VALUES(?,?,?,?,?)').run(key,id,'image/png',3,1);
fs.mkdirSync(path.dirname(path.join(dir,'media',key)),{recursive:true});
fs.writeFileSync(path.join(dir,'media',key),'png');
// Simulate a snapshot older than an erasure: replay must delete this account on the extracted copy.
new ErasureLedger(path.join(dir,'erasures.jsonl')).append({id,at:2,epoch:0});
db.close();
JS
age-keygen -o "$SMOKE_ROOT/age.key" 2>/dev/null
BACKUP_AGE_RECIPIENT="$(age-keygen -y "$SMOKE_ROOT/age.key")"
BACKUP_OFFSITE_CMD='cp "$BACKUP_FILE" "$SMOKE_ROOT/offsite.age"'
export BACKUP_AGE_RECIPIENT BACKUP_OFFSITE_CMD
sh ops/backup-loop.sh
node dist/backup.js health "$BACKUP_DIR"
archive="$(find "$BACKUP_DIR" -maxdepth 1 -name '*.tgz' -type f | head -n 1)"
[ -n "$archive" ] && [ -f "$SMOKE_ROOT/offsite.age" ]
age -d -i "$SMOKE_ROOT/age.key" -o "$SMOKE_ROOT/decrypted.tgz" "$SMOKE_ROOT/offsite.age"
cmp "$archive" "$SMOKE_ROOT/decrypted.tgz"
node dist/backup.js extract "$archive" "$SMOKE_ROOT/restore"
node dist/backup.js drill "$SMOKE_ROOT/restore"
node --input-type=module <<'JS'
import assert from 'node:assert/strict';
import Database from 'better-sqlite3';
import path from 'node:path';
const restored = new Database(path.join(process.env.SMOKE_ROOT,'restore/community.db'),{readonly:true});
assert.equal(restored.prepare('SELECT count(*) AS n FROM users').get().n,0);
assert.equal(restored.prepare('SELECT count(*) AS n FROM media').get().n,0);
restored.close();
const live = new Database(path.join(process.env.DATA_DIR,'community.db'),{readonly:true});
assert.equal(live.prepare('SELECT count(*) AS n FROM users').get().n,1);
assert.equal(live.prepare('SELECT count(*) AS n FROM media').get().n,1);
live.close();
JS
# Retention must still run when off-site transfer fails, and failure must not advance health.
touch "$BACKUP_DIR/valvn-community-old.tgz" "$BACKUP_DIR/pre-restore/valvn-community-old.tgz"
touch -d '16 days ago' "$BACKUP_DIR/valvn-community-old.tgz" "$BACKUP_DIR/pre-restore/valvn-community-old.tgz"
mkdir -p "$BACKUP_DIR/.tmp/backup.abandoned"
touch -d '25 hours ago' "$BACKUP_DIR/.tmp/backup.abandoned"
touch -d '10 days ago' "$BACKUP_DIR/last-success"
BACKUP_OFFSITE_CMD='exit 23'
export BACKUP_OFFSITE_CMD
if sh ops/backup-loop.sh; then echo 'failed hook accepted' >&2; exit 1; fi
if node dist/backup.js health "$BACKUP_DIR"; then echo 'stale health accepted' >&2; exit 1; fi
[ ! -e "$BACKUP_DIR/valvn-community-old.tgz" ]
[ ! -e "$BACKUP_DIR/pre-restore/valvn-community-old.tgz" ]
[ ! -e "$BACKUP_DIR/.tmp/backup.abandoned" ]
[ -z "$(find "$BACKUP_DIR/.tmp" -mindepth 1 -print -quit)" ]
# Operator-supplied archives must not extract links even with an otherwise allowed name.
mkdir -p "$SMOKE_ROOT/unsafe/media"
ln -s /etc/passwd "$SMOKE_ROOT/unsafe/media/link"
tar czf "$SMOKE_ROOT/unsafe.tgz" -C "$SMOKE_ROOT/unsafe" .
if node dist/backup.js extract "$SMOKE_ROOT/unsafe.tgz" "$SMOKE_ROOT/unsafe-out" >/dev/null 2>&1; then
  echo 'unsafe archive accepted' >&2; exit 1
fi
echo 'WP-SRV isolated backup/encryption/replay/retention/failure checks passed'
