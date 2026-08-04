# syntax=docker/dockerfile:1
# Use the official Node.js image as the base
FROM node:25.9.0-bookworm-slim

# Create and switch to folder for all the app code
WORKDIR /usr/src/app

# Copy the NPM config into the image and use it to install the app's dependencies
COPY app/package.json app/package-lock.json ./
RUN npm ci --omit=dev

# Copy the rest of the app code into the image. We copy the app code separately as it changes more often than the
# app's dependencies, so we get better use from the Docker build cache.
COPY app/*.js ./
COPY app/views ./views

# Run the app as user node
USER node

# By default, the app listens on this port, so we advertise it in the metadata of the image
EXPOSE 8080

# Set the default command to run the app
CMD ["npm", "start"]
