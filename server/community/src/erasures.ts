import fs from 'node:fs';
import path from 'node:path';
import type { MediaDeps } from './media-service.js';
import { deleteAccount } from './account.js';

interface Erasure { id: string; at: number; epoch: number }
/** Outside the database snapshot. A deletion is durable here BEFORE database rows or files disappear. */
export class ErasureLedger {
  constructor(readonly file: string) {}

  append(entry: Erasure): void {
    fs.mkdirSync(path.dirname(this.file), { recursive: true });
    const fd = fs.openSync(this.file, 'a', 0o600);
    try {
      fs.writeFileSync(fd, `${JSON.stringify(entry)}\n`);
      fs.fsyncSync(fd);
    } finally { fs.closeSync(fd); }
    // A newly created ledger also needs its directory entry durable on Linux.
    if (process.platform !== 'win32') {
      const parent = fs.openSync(path.dirname(this.file), 'r');
      try { fs.fsyncSync(parent); } finally { fs.closeSync(parent); }
    }
  }

  entries(): Erasure[] {
    let text: string;
    try { text = fs.readFileSync(this.file, 'utf8'); }
    catch (e) { if ((e as NodeJS.ErrnoException).code === 'ENOENT') return []; throw e; }
    return text.split('\n').filter(Boolean).map((line) => {
      const row = JSON.parse(line) as Erasure;
      if (!/^[a-f0-9]{32}$/.test(row.id) || !Number.isSafeInteger(row.at) || !Number.isSafeInteger(row.epoch) || row.epoch < 0) {
        throw new Error('Invalid erasure ledger; repair before serving restored data');
      }
      return row;
    });
  }

  /** Idempotent; an account created after the deletion (including in the same second) is kept. */
  async replay(d: MediaDeps): Promise<number> {
    let deleted = 0;
    for (const entry of this.entries()) {
      const user = d.repo.getUser(entry.id);
      if (user && user.created_at <= entry.at && user.session_epoch <= entry.epoch) {
        if (await deleteAccount({ ...d, erasureLedger: undefined }, entry.id)) deleted++;
      }
    }
    return deleted;
  }
}
