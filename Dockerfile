FROM node:20-alpine AS runner
WORKDIR /app

# Set production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy pre-built files
COPY --chown=nextjs:nodejs ./.next ./.next
COPY --chown=nextjs:nodejs ./public ./public
COPY package.json package-lock.json* ./

# Install only production dependencies
RUN npm ci --only=production

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]

