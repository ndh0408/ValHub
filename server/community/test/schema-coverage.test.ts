import { afterEach, describe, expect, it } from 'vitest';
import { ACCOUNT_TABLE_POLICIES, buildExport } from '../src/account.js';
import { setup, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());
describe('account schema coverage (CS-39)', () => {
  it('every user-related column/FK has a reviewed export and erasure policy', () => {
    e = setup();
    const tables = e.db.prepare("SELECT name FROM sqlite_master WHERE type = 'table'").all() as { name: string }[];
    const related: string[] = [];
    for (const { name } of tables) {
      const columns = e.db.pragma(`table_info('${name}')`) as { name: string }[];
      const fks = e.db.pragma(`foreign_key_list('${name}')`) as { table: string }[];
      if (name === 'users' || columns.some((c) => /(^|_)user_id$|^reporter_id$/.test(c.name)) || fks.some((f) => f.table === 'users')) related.push(name);
    }
    expect(related.sort()).toEqual(Object.keys(ACCOUNT_TABLE_POLICIES).sort());
  });

  it('exports cached creates and erases their copies with the account', async () => {
    e = setup();
    const a = await e.login('alice');
    await e.req('POST', '/v1/posts', { token: a.token, headers: { 'idempotency-key': 'one' }, body: { kind: 'text', body: 'my text' } });
    const data = e.repo.accountData(a.user.id)!;
    expect(buildExport(data, '', e.clock.t).recentCreates).toEqual([expect.objectContaining({ response: expect.objectContaining({ body: 'my text' }) })]);
    await e.req('DELETE', '/v1/me', { token: a.token });
    for (const [table, policy] of Object.entries(ACCOUNT_TABLE_POLICIES)) {
      if (policy === 'erase') expect(e.db.prepare(`SELECT COUNT(*) AS n FROM ${table}`).get(), table).toEqual({ n: 0 });
    }
    expect(e.db.prepare('SELECT epoch FROM revoked_accounts').get()).toEqual({ epoch: 1 });
  });
});
