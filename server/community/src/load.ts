import { monitorEventLoopDelay, type IntervalHistogram } from 'node:perf_hooks';

/**
 * Event-loop lag monitor for load shedding (CS-03). Node runs every request on one thread and SQLite is
 * synchronous, so when something (an expensive request, a burst) keeps the loop busy, every user waits. While the
 * lag is above a threshold the app answers 503 + Retry-After immediately (cheap) instead of queueing more work.
 *
 * The lag is the 95th percentile of the timer delays of the last full second: a single GC pause or one big upload
 * does not shed by itself, sustained lag does. `lagMs()` is a field read, safe to call on every request.
 */
export interface LoadMonitor {
  /** Current lag in milliseconds. */
  lagMs(): number;
  stop(): void;
}

/** The part of `perf_hooks.IntervalHistogram` the monitor uses (a fake one is injected in tests). */
export type DelayHistogram = Pick<IntervalHistogram, 'enable' | 'disable' | 'reset' | 'percentile'>;

export function startLoadMonitor(
  windowMs = 1000,
  resolutionMs = 20,
  makeHistogram: (resolutionMs: number) => DelayHistogram = (r) => monitorEventLoopDelay({ resolution: r }),
): LoadMonitor {
  const histogram = makeHistogram(resolutionMs);
  histogram.enable();
  let current = 0;
  const timer = setInterval(() => {
    // Recorded values are nanoseconds between two ticks (they include the sampling resolution itself).
    current = Math.max(0, histogram.percentile(95) / 1e6 - resolutionMs);
    histogram.reset();
  }, windowMs);
  timer.unref();
  return {
    lagMs: () => current,
    stop: () => {
      clearInterval(timer);
      histogram.disable();
    },
  };
}
