# Use official Bun image
FROM oven/bun:1-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy the rest of the app
COPY . .

# Build the app
RUN bun run build

# --- Production image ---
FROM oven/bun:1-alpine

WORKDIR /app

# Copy only the built files and necessary configs
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose the port
EXPOSE 3000

# Start the app using Bun
CMD ["bun", "run", "start:prod"]
