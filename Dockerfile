# Use Node LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy app files
COPY package*.json ./
RUN npm ci

COPY . .

# Expose app on port 3000
EXPOSE 3000

# Start app
CMD [ "npm", "start" ]
