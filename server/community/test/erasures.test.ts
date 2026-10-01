import fs from 'node:fs';
import path from 'node:path';
import { afterEach, describe, expect, it } from 'vitest';
import { ErasureLedger } from '../src/erasures.js';
import { deleteAccount } from '../src/account.js';
import { setup, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());
describe('erasure ledger (CS-11)', () => {
  it('replays against a restored DB and keeps a newly re-created account', async () => {
    e = setup();
    const a = await e.login('alice');
    const ledger = new ErasureLedger(path.join(e.dataDir, 'erasures.jsonl'));
    const deps = { ...e.mediaDeps(), erasureLedger: ledger };
    await deleteAccount(deps, a.user.id);
    expect(ledger.entries()).toEqual([{ id: a.user.id, at: e.clock.t, epoch: 0 }]);
    const fresh = await e.login('alice'); // SAME millisecond
    expect((await e.req('GET', '/v1/me', { token: a.token })).status).toBe(401);
    expect(await ledger.replay(deps)).toBe(0);
    expect((await e.req('GET', '/v1/me', { token: fresh.token })).status).toBe(200);
    // Simulate the account row from a pre-erasure snapshot.
    e.db.prepare('UPDATE users SET session_epoch = 0 WHERE id = ?').run(a.user.id);
    expect(await ledger.replay(deps)).toBe(1);
    expect(await ledger.replay(deps)).toBe(0);
    expect(e.repo.getUser(a.user.id)).toBeNull();
  });

  it('fails before deleting if the ledger cannot be persisted; corrupt ledger blocks replay', async () => {
    e = setup();
    const a = await e.login('alice');
    const ledger = new ErasureLedger(e.dataDir); // directory, not a writable file
    await expect(deleteAccount({ ...e.mediaDeps(), erasureLedger: ledger }, a.user.id)).rejects.toThrow();
    expect(e.repo.getUser(a.user.id)).not.toBeNull();
    const file = path.join(e.dataDir, 'erasures.jsonl');
    fs.writeFileSync(file, '{broken');
    await expect(new ErasureLedger(file).replay(e.mediaDeps())).rejects.toThrow();
  });
});
