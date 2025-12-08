# Builder stage
FROM oven/bun:1-alpine AS builder
WORKDIR /app

COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

# Production stage  
FROM oven/bun:1-alpine
WORKDIR /app

# Copy everything needed for production
COPY --from=builder /app/package.json ./
COPY --from=builder /app/bun.lockb* ./
COPY --from=builder /app/next.config.* ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

EXPOSE 3000

# Use Node.js to run Next.js (Bun doesn't fully support Next.js standalone yet)
CMD ["./node_modules/.bin/next", "start", "-p", "3000"]
