# Use Node LTS image
# FROM node:18-alpine

# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy only package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the project
COPY . .

# Build the app
RUN npm run build

# Install a simple static server
RUN npm install -g serve

# Expose the port
EXPOSE 5000

# Serve the built app
CMD ["serve", "-s", "public", "-l", "5000"]
