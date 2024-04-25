FROM node:21.6.0-alpine

RUN apk --no-cache add \
    python3 \
    make \
    g++ \
    libc6-compat

ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copy only package.json first to take advantage of Docker caching
COPY package.json ./

# Install app dependencies and generate package-lock.json
RUN npm install

# Copy the rest of the application code
COPY . .

# Use npm ci to install dependencies based on the lock file
RUN npm ci --omit=dev

# Change ownership to non-root user
RUN chown -R node:node .

# Arguments and environment variables

ARG OTEL_SERVICE_NAME
ARG OTEL_EXPORTER_OTLP_ENDPOINT
ARG OTEL_NODE_RESOURCE_DETECTORS
ARG OTEL_EXPORTER_OTLP_PROTOCOL
ENV OTEL_EXPORTER_OTLP_PROTOCOL $OTEL_EXPORTER_OTLP_PROTOCOL
ENV OTEL_SERVICE_NAME $OTEL_SERVICE_NAME
ENV OTEL_EXPORTER_OTLP_ENDPOINT $OTEL_EXPORTER_OTLP_ENDPOINT
ENV OTEL_NODE_RESOURCE_DETECTORS $OTEL_NODE_RESOURCE_DETECTORS

# Switch to non-root user
USER node

# ENTRYPOINT ["node", "--require", "@opentelemetry/auto-instrumentations-node/register", "./node_modules/@openintegrationhub/ferryman/runGlobal.js"]

ENTRYPOINT ["node", "--require", "@opentelemetry/auto-instrumentations-node/register", "./app.js"]