FROM node:18.12-bullseye-slim AS node

#### runtime ####
FROM ubuntu:jammy-20221101 AS runtime

COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/
RUN corepack disable && corepack enable

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    tini \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node \
    && install -d -o node -g node /app \
    && install -d -o node -g node /home/node/.npm

WORKDIR /app
USER node
EXPOSE 3000

ENV NODE_ENV=production

#### source ####
FROM runtime AS source
COPY package.json package-lock.json* ./
RUN --mount=type=cache,target=/home/node/.npm,uid=1000,gid=1000 \
    npm ci
COPY --chown=node:node . .

#### builder (production) ####
FROM source AS builder
RUN npm run build

#### runner (production) ####
FROM runtime AS runner
ENV NEXT_TELEMETRY_DISABLED 1

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
