import { isIP } from 'node:net';

/**
 * The rate-limit identity of a client address (before it is hashed): IPv4 as it is, IPv6 reduced to its /64
 * prefix. A residential or mobile IPv6 subscriber owns at least a /64 and can rotate through 2^64 addresses in it,
 * so keying on the full address would make every per-IP limit useless against IPv6. IPv4-mapped IPv6 addresses
 * (`::ffff:203.0.113.7`) are the IPv4 address. Anything that is not an IP address keeps a bounded raw form.
 */
export function ipKey(raw: string): string {
  let ip = raw.trim();
  if (ip.startsWith('[') && ip.endsWith(']')) ip = ip.slice(1, -1);
  const zone = ip.indexOf('%');
  if (zone >= 0) ip = ip.slice(0, zone);
  const mapped = /^::ffff:(\d{1,3}(?:\.\d{1,3}){3})$/i.exec(ip);
  if (mapped?.[1] && isIP(mapped[1]) === 4) return mapped[1];
  const kind = isIP(ip);
  if (kind === 4) return ip;
  if (kind === 6) {
    const groups = expandIpv6(ip);
    if (groups) return `${groups.slice(0, 4).join(':')}::/64`;
  }
  return ip.toLowerCase().slice(0, 64);
}

/** The 8 hextets of an IPv6 address, lower case, 4 digits each; null when it cannot be parsed. */
function expandIpv6(ip: string): string[] | null {
  let text = ip.toLowerCase();
  // A trailing dotted IPv4 (::1.2.3.4) is two hextets.
  const v4 = /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.exec(text);
  if (v4) {
    const n = v4.slice(1, 5).map(Number);
    if (n.some((x) => x > 255)) return null;
    const hi = ((n[0]! << 8) | n[1]!).toString(16);
    const lo = ((n[2]! << 8) | n[3]!).toString(16);
    text = `${text.slice(0, v4.index)}${hi}:${lo}`;
  }
  const halves = text.split('::');
  if (halves.length > 2) return null;
  const head = halves[0] ? halves[0].split(':') : [];
  const tail = halves.length === 2 && halves[1] ? halves[1].split(':') : [];
  const missing = 8 - head.length - tail.length;
  if (halves.length === 1 ? head.length !== 8 : missing < 0) return null;
  const all = halves.length === 1 ? head : [...head, ...Array<string>(missing).fill('0'), ...tail];
  if (all.length !== 8 || all.some((g) => !/^[0-9a-f]{1,4}$/.test(g))) return null;
  return all.map((g) => g.padStart(4, '0'));
}

/**
 * True for loopback, private (RFC 1918 / ULA), link-local and carrier-grade-NAT / Tailscale (100.64/10) addresses:
 * the addresses a reverse proxy or tunnel connects from inside the host or its container network. A forwarded-client
 * header is only believed when the TCP peer is such an address, so a client that reaches the server directly cannot
 * choose its own rate-limit identity.
 */
export function isPrivateAddress(raw: string): boolean {
  const ip = ipKeyForPeer(raw);
  const kind = isIP(ip);
  if (kind === 4) {
    const [a, b] = ip.split('.').map(Number) as [number, number];
    return (
      a === 10 ||
      a === 127 ||
      (a === 172 && b >= 16 && b <= 31) ||
      (a === 192 && b === 168) ||
      (a === 169 && b === 254) ||
      (a === 100 && b >= 64 && b <= 127)
    );
  }
  if (kind === 6) {
    const lower = ip.toLowerCase();
    return lower === '::1' || /^f[cd][0-9a-f]{2}:/.test(lower) || /^fe[89ab][0-9a-f]:/.test(lower);
  }
  return false;
}

/** The peer address as a plain IPv4 / IPv6 string (mapped IPv4 unwrapped, zone removed). */
function ipKeyForPeer(raw: string): string {
  let ip = raw.trim();
  const zone = ip.indexOf('%');
  if (zone >= 0) ip = ip.slice(0, zone);
  const mapped = /^::ffff:(\d{1,3}(?:\.\d{1,3}){3})$/i.exec(ip);
  return mapped?.[1] ?? ip;
}
