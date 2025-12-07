# ============================================
# Slim runtime-only Dockerfile for Next.js 15
# ============================================

FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy built Next.js app
COPY .next ./.next
COPY public ./public

# Set environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

EXPOSE 3000

# Start the application
CMD ["node", "server.js"]

