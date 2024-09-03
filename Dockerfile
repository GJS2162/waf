# Stage 1: Build Caddy with xcaddy
FROM golang:1.21-alpine as builder

# Install dependencies
RUN apk add --no-cache git

# Install xcaddy
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# Create a working directory for building Caddy
WORKDIR /build

# Build Caddy with Coraza WAF module
RUN xcaddy build --with github.com/corazawaf/coraza-caddy/v2

# Stage 2: Use a minimal Caddy image
FROM caddy:2.8.4-alpine

# Copy the built Caddy binary from the builder stage
COPY --from=builder /build/caddy /usr/bin/caddy

# Copy the Caddyfile to the container
COPY Caddyfile /etc/caddy/Caddyfile

# Expose port 8080
EXPOSE 8080

# Start Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
