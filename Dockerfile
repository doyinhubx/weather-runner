# Stage 1: Build the app using Node
# FROM node:20-alpine AS builder
FROM node:20-alpine@sha256:ae6ee91a652d927de01d550c29f863a52f1da390c89df95f3ceba256d1e62604 AS builder

# Set working directory
WORKDIR /app

# Copy and install only production dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the files and build
COPY . .
RUN npm run build

# Stage 2: Serve with minimal runtime
FROM node:20-alpine AS runtime

# Install only `serve` globally
RUN npm install -g serve

# Set working directory
WORKDIR /app

# Copy built static files from builder stage
COPY --from=builder /app/public ./public

# Expose port
EXPOSE 8080

# Serve built app
CMD ["serve", "-s", "public", "-l", "8080"]
