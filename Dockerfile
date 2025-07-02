# Build stage
FROM node:24-slim AS builder

# Set working directory
WORKDIR /app

# Copy package files for installation
COPY package*.json ./
COPY .npmrc ./
COPY server/package*.json ./server/

# Install dependencies
RUN npm ci --ignore-scripts

# Copy source files
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:24-slim

WORKDIR /app

# Copy package files for production
COPY package*.json ./
COPY .npmrc ./
COPY server/package*.json ./server/

# Install only production dependencies
RUN npm ci --omit=dev --ignore-scripts

# Copy built files from builder stage
COPY --from=builder /app/server/build ./server/build

# Set default port values as environment variables
ENV SERVER_PORT=6277

# Document which ports the application uses internally
EXPOSE ${SERVER_PORT}

# Use ENTRYPOINT with CMD for arguments
ENTRYPOINT ["npm", "start"]