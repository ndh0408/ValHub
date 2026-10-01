/**
 * Aggregate counters for the security / abuse log line (CS-31). Names are fixed strings or route patterns
 * (`/v1/posts/:id`), never user data, so nothing here identifies anyone. Drained once a minute by main.ts.
 */
export class Counters {
  private readonly map = new Map<string, number>();
  private requests = 0;
  private serverErrors = 0;

  /** Monotonic process totals for the local watchdog; draining log counters does not reset them. */
  recordHttp(status: number): void {
    this.requests++;
    if (status >= 500) this.serverErrors++;
  }

  httpTotals(): { requests: number; serverErrors: number } {
    return { requests: this.requests, serverErrors: this.serverErrors };
  }

  inc(name: string, by = 1): void {
    // Bounded: an unexpected flood of distinct names cannot grow the map without limit.
    if (!this.map.has(name) && this.map.size >= 500) return;
    this.map.set(name, (this.map.get(name) ?? 0) + by);
  }

  /** Returns the counts since the last drain and starts again from zero. */
  drain(): Record<string, number> {
    const out = Object.fromEntries([...this.map.entries()].sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0)));
    this.map.clear();
    return out;
  }

  get(name: string): number {
    return this.map.get(name) ?? 0;
  }
}
