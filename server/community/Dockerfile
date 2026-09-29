# syntax=docker/dockerfile:1

# ---- build: install all deps (native better-sqlite3), compile TS, prune dev deps
FROM node:22-bookworm-slim AS build
WORKDIR /app
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 make g++ \
 && rm -rf /var/lib/apt/lists/*
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY tsconfig.json tsconfig.build.json ./
COPY src ./src
RUN npm run build && npm prune --omit=dev --no-audit --no-fund

# ---- runtime: same base (glibc) as the build stage so the native module matches
FROM node:22-bookworm-slim
ENV NODE_ENV=production \
    PORT=8080 \
    DATA_DIR=/data
WORKDIR /app
COPY --from=build --chown=root:root /app/node_modules ./node_modules
COPY --from=build --chown=root:root /app/dist ./dist
COPY --chown=root:root package.json ./
COPY --chown=root:root migrations ./migrations
RUN mkdir -p /data && chown node:node /data
USER node
EXPOSE 8080
VOLUME ["/data"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD ["node", "-e", "fetch('http://127.0.0.1:'+(process.env.PORT||8080)+'/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
CMD ["node", "dist/main.js"]
