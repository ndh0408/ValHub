import { describe, it, expect, vi, afterEach } from 'vitest';
import { WatchdogState, localHealthUrl, parseHealth, readHealth, type HealthSample } from '../src/watchdog.js';
import { Counters } from '../src/metrics.js';

const now = 1_800_000_000_000;
const healthy: HealthSample = { writable: true, freeBytes: 512 * 1024 * 1024, walBytes: 0,
  loopLagMs: 0, http: { requests: 0, serverErrors: 0 } };
describe('local watchdog', () => {
  afterEach(() => vi.unstubAllGlobals());
  it('handles degraded 503 bodies but rejects redirect/error/oversized responses', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response(JSON.stringify(healthy), { status: 503 }));
    vi.stubGlobal('fetch', fetchMock);
    const url = localHealthUrl('http://127.0.0.1:8080/healthz/deep');
    expect(await readHealth(url)).toEqual(healthy);
    expect(fetchMock.mock.calls[0]![1]).toMatchObject({ redirect: 'error' });
    for (const response of [new Response('', { status: 302 }), new Response('secret', { status: 500 }),
      new Response('x'.repeat(17000)), new Response('{"ok":true}')]) {
      fetchMock.mockResolvedValueOnce(response);
      expect(await readHealth(url)).toBeNull();
    }
    fetchMock.mockRejectedValueOnce(new Error('token and raw body'));
    expect(await readHealth(url)).toBeNull();
  });
  it('rejects off-host, forwarded/credentialed, redirected and arbitrary-path URLs', () => {
    for (const url of ['https://127.0.0.1/healthz/deep', 'http://localhost/healthz/deep',
      'http://example.com/healthz/deep', 'http://user:token@127.0.0.1/healthz/deep',
      'http://127.0.0.1/healthz/deep?secret=x', 'http://127.0.0.1/v1/users',
      'http://127.0.0.1/healthz/deep#secret']) expect(() => localHealthUrl(url)).toThrow();
    expect(localHealthUrl('http://127.0.0.1:8080/healthz/deep').port).toBe('8080');
    expect(localHealthUrl('http://[::1]:8080/healthz/deep').hostname).toBe('[::1]');
  });
  it('requires a complete bounded numeric schema, excluding server error bodies', () => {
    expect(parseHealth(healthy)).toEqual(healthy);
    for (const value of [null, [], { ok: false }, { ...healthy, freeBytes: NaN },
      { ...healthy, walBytes: -1 }, { ...healthy, writable: 'true' },
      { ...healthy, http: { requests: 1, serverErrors: 2 } }]) expect(() => parseHealth(value)).toThrow();
  });
  it('requires three probe failures; a successful probe resets the run', () => {
    const state = new WatchdogState();
    expect(state.sample(null, now, now, now)).toEqual([]);
    expect(state.sample(null, now, now, now)).toEqual([]);
    expect(state.sample(null, now, now, now)).toEqual(['probe_failed']);
    expect(state.sample(healthy, now, now, now)).toEqual([]);
    expect(state.sample(null, now, now, now)).toEqual([]);
  });
  it('reports unsafe disk and stale/missing/future backup markers immediately', () => {
    const state = new WatchdogState();
    expect(state.sample({ ...healthy, writable: false, freeBytes: 1, walBytes: 129 * 1024 * 1024 },
      now, null, now - 9 * 86_400_000)).toEqual(['disk_unwritable', 'disk_low', 'wal_large', 'backup_stale', 'drill_stale']);
    expect(state.sample(healthy, now, now + 120_000, now + 120_000)).toEqual(['backup_stale', 'drill_stale']);
    expect(state.sample(healthy, now, now - 25 * 3_600_000, now - 7 * 86_400_000)).toEqual([]);
    expect(state.sample(healthy, now, now - 27 * 3_600_000, now)).toEqual(['backup_stale']);
  });
  it('samples sustained lag and 5xx rate, resets on process restart and low volume', () => {
    const state = new WatchdogState();
    expect(state.sample(healthy, now, now, now)).toEqual([]);
    for (let i = 1; i <= 3; i++) {
      const result = state.sample({ ...healthy, loopLagMs: 250, http: { requests: i * 100, serverErrors: i * 10 } }, now, now, now);
      expect(result).toEqual(i < 3 ? [] : ['loop_lag', 'server_errors']);
    }
    expect(state.sample(healthy, now, now, now)).toEqual([]);
    expect(state.sample({ ...healthy, http: { requests: 1, serverErrors: 1 } }, now, now, now)).toEqual([]);
  });
  it('HTTP totals remain monotonic across security log drains', () => {
    const counters = new Counters();
    for (const status of [200, 201, 404, 429, 500, 503]) counters.recordHttp(status);
    counters.inc('shed');
    expect(counters.drain()).toEqual({ shed: 1 });
    expect(counters.httpTotals()).toEqual({ requests: 6, serverErrors: 2 });
    expect(counters.drain()).toEqual({});
  });
});
