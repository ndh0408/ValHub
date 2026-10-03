import { afterEach, describe, expect, it, vi } from 'vitest';
import { SESSION_TTL_SECONDS } from '../src/crypto.js';
import { PNG, setup, SKIN_A, WEAPON_1, type Env } from './helpers.js';

let e: Env;
afterEach(() => e?.close());

function barrier() {
  let release!: () => void;
  let enter!: () => void;
  const gate = new Promise<void>(r => { release = r; });
  const entered = new Promise<void>(r => { enter = r; });
  return {release, entered, async wait() { enter(); await gate; }};
}

const actions = [
  {name:'vote',method:'PUT',path:`/v1/skins/${SKIN_A}/vote`,table:'skin_votes',body:{weaponUuid:WEAPON_1}},
  {name:'review',method:'PUT',path:`/v1/skins/${SKIN_A}/review`,table:'skin_reviews',body:{weaponUuid:WEAPON_1,rating:4,body:'Review'}},
  {name:'shared store',method:'POST',path:'/v1/posts',table:'posts',body:{kind:'store',payload:{date:'2026-09-01',offers:[{skinUuid:SKIN_A,cost:1775}]}}},
  {name:'LFG',method:'POST',path:'/v1/lfg',table:'lfg_posts',body:{region:'ap',mode:'competitive',partyCode:'ABC123',slots:2,agents:[SKIN_A]}},
] as const;
const count = (table: string) => (e.db.prepare(`SELECT COUNT(*) AS n FROM ${table}`).get() as {n:number}).n;

async function revoke(mode: string, a: {token:string;user:{id:string}}) {
  if (mode === 'logout') {
    expect((await e.req('POST','/v1/auth/logout',{token:a.token})).status).toBe(204);
  } else if (mode === 'erase and recreate' || mode === 'erase and recreate same second') {
    expect((await e.req('DELETE','/v1/me',{token:a.token})).status).toBe(204);
    if (mode === 'erase and recreate') e.clock.t += 1000;
    await e.login('alice');
  } else if (mode === 'restriction') {
    e.repo.addSanction({userId:a.user.id,kind:'restrict',until:null,reason:'spam',now:e.clock.t});
  } else if (mode === 'expiry') {
    e.clock.t += (SESSION_TTL_SECONDS + 1) * 1000;
  }
}

describe('authorization after asynchronous validation', () => {
  for (const action of actions) {
    for (const mode of ['none','logout','erase and recreate','erase and recreate same second','restriction','expiry']) {
      it(`${action.name}: ${mode} while catalog validation is pending`, async () => {
        const b = barrier();
        e = setup({content:{async isKnown() {await b.wait();return true;}}});
        const a = await e.login('alice');
        const pending = e.req(action.method,action.path,{token:a.token,body:action.body});
        await b.entered;
        await revoke(mode,a);
        b.release();
        const res = await pending;
        expect(res.status).toBe(mode==='none'?200:mode==='restriction'?403:401);
        expect(count(action.table)).toBe(mode==='none'?1:0);
        expect(e.errors).toEqual([]);
      });
    }
  }

  for (const mode of ['none','logout','erase and recreate','erase and recreate same second','restriction','expiry']) {
    it(`media: ${mode} during blob write leaves no unauthorized row/blob`, async () => {
      e = setup();
      const a = await e.login('alice');
      const b = barrier();
      const put = e.media.put.bind(e.media);
      vi.spyOn(e.media,'put').mockImplementation(async (key,bytes) => {
        await b.wait();
        await put(key,bytes);
      });
      const pending = e.req('POST','/v1/media',{token:a.token,raw:PNG,headers:{'content-type':'image/png'}});
      await b.entered;
      await revoke(mode,a);
      b.release();
      const res = await pending;
      expect(res.status).toBe(mode==='none'?200:mode==='restriction'?403:401);
      expect(count('media')).toBe(mode==='none'?1:0);
      expect((await e.media.list()).length).toBe(mode==='none'?1:0);
      expect(e.errors).toEqual([]);
    });
  }

  it('duplicate pending upload cannot restart or replay after logout', async () => {
    e = setup();
    const a = await e.login('alice');
    const b = barrier();
    const put = e.media.put.bind(e.media);
    const write = vi.spyOn(e.media,'put').mockImplementation(async (key,bytes) => {
      await b.wait();
      await put(key,bytes);
    });
    const lookup = vi.spyOn(e.repo,'getRequestKey');
    const opts = {token:a.token,raw:PNG,headers:{'content-type':'image/png','idempotency-key':'pending-upload'}};
    const first = e.req('POST','/v1/media',opts);
    await b.entered;
    const second = e.req('POST','/v1/media',opts);
    await vi.waitFor(() => expect(lookup).toHaveBeenCalledTimes(2));
    await revoke('logout',a);
    b.release();
    const responses = await Promise.all([first,second]);
    expect(responses.map(r=>r.status)).toEqual([401,401]);
    expect(write).toHaveBeenCalledTimes(1);
    expect(count('media')).toBe(0);
    expect(count('request_keys')).toBe(0);
    expect(await e.media.list()).toEqual([]);
    expect(e.errors).toEqual([]);
  });

  it('revalidation does not charge the coarse request bucket twice', async () => {
    e = setup({tuning:{userRequestLimitPerMin:1}});
    const a = await e.login('alice');
    expect((await e.req('PUT',`/v1/skins/${SKIN_A}/vote`,{token:a.token,body:{weaponUuid:WEAPON_1}})).status).toBe(200);
    expect((await e.req('GET','/v1/me',{token:a.token})).status).toBe(429);
    expect(count('skin_votes')).toBe(1);
  });

  it('comment cannot attach after its visible parent is hidden during validation', async () => {
    e = setup();
    const a = await e.login('alice');
    const post = await e.req('POST','/v1/posts',{token:a.token,body:{kind:'text',body:'Parent'}});
    const getPost = e.repo.getPost.bind(e.repo);
    vi.spyOn(e.repo,'getPost').mockImplementationOnce((id,viewer) => {
      const visible = getPost(id,viewer);
      queueMicrotask(() => e.db.prepare('UPDATE posts SET hidden=1 WHERE id=?').run(id));
      return visible;
    });
    const result = await e.req('POST',`/v1/posts/${post.json.id}/comments`,{token:a.token,body:{body:'Late comment'}});
    expect(result.status).toBe(404);
    expect(count('comments')).toBe(0);
    expect(e.errors).toEqual([]);
  });
});
