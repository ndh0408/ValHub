import path from 'node:path';

export interface Config {
  port: number;
  dataDir: string;
  sessionSecret: string;
  pepper: string;
  /** e.g. https://community.example.com — no trailing slash. Empty → derive from request. */
  publicBaseUrl: string;
  /** Trust CF-Connecting-IP / X-Forwarded-* (true behind the Cloudflare Tunnel). */
  trustProxy: boolean;
}

const MIN_SECRET_LENGTH = 32;

/** Reads config from the environment; throws (fail fast) on missing / weak secrets. */
export function loadConfig(env: NodeJS.ProcessEnv): Config {
  const problems: string[] = [];
  const secret = (name: string): string => {
    const v = env[name] ?? '';
    if (v.length < MIN_SECRET_LENGTH) {
      problems.push(`${name} must be set and at least ${MIN_SECRET_LENGTH} characters long`);
    }
    return v;
  };
  const sessionSecret = secret('SESSION_SECRET');
  const pepper = secret('PEPPER');

  const portRaw = env.PORT ?? '8080';
  const port = Number(portRaw);
  if (!Number.isInteger(port) || port < 1 || port > 65535) problems.push(`PORT is invalid: ${portRaw}`);

  let publicBaseUrl = (env.PUBLIC_BASE_URL ?? '').trim().replace(/\/+$/, '');
  if (publicBaseUrl !== '') {
    try {
      const u = new URL(publicBaseUrl);
      if (u.protocol !== 'https:' && u.protocol !== 'http:') throw new Error('protocol');
      publicBaseUrl = u.origin + u.pathname.replace(/\/+$/, '');
    } catch {
      problems.push('PUBLIC_BASE_URL must be an absolute http(s) URL');
    }
  }

  if (problems.length > 0) throw new Error(`Invalid configuration:\n- ${problems.join('\n- ')}`);

  return {
    port,
    dataDir: path.resolve(env.DATA_DIR || '/data'),
    sessionSecret,
    pepper,
    publicBaseUrl,
    trustProxy: (env.TRUST_PROXY ?? 'true').toLowerCase() !== 'false',
  };
}
