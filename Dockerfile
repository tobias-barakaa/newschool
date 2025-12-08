# ============================================

# Multi-stage Dockerfile for Next.js 15 + Node 20

# ============================================

# -------------------------

# 1. Dependencies Stage

# -------------------------

FROM node:20-alpine AS deps

# Install minimal build tools for native modules

RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files

COPY package.json package-lock.json* ./

# Use npm ci if lockfile exists, fallback to npm install

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# -------------------------

# 2. Builder Stage

# -------------------------

FROM node:20-alpine AS builder
WORKDIR /app

# Copy node_modules from deps stage

COPY --from=deps /app/node_modules ./node_modules

# Copy full project

COPY . .

# Build Next.js app

RUN npm run build

# -------------------------

# 3. Production Stage

# -------------------------

FROM node:20-alpine AS runner
WORKDIR /app

# Set environment variables

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create a non-root user

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built app from builder

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Switch to non-root user

USER nextjs

# Expose the port

EXPOSE 3000

# Start the app

CMD ["npm", "run", "start:prod"]
