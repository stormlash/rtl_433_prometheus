# May be built from x86_64, using cross-build-start magic.

# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.15 as gobuilder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -mod=readonly -a -v rtl_433_prometheus.go

FROM --platform=linux/arm/v6 hertzg/rtl_433:alpine-3.12-latest as rtl_433

WORKDIR /
COPY --from=gobuilder /app/rtl_433_prometheus /

EXPOSE 9550
ENTRYPOINT ["/rtl_433_prometheus"]
CMD ["--subprocess", "/usr/local/bin/rtl_433 -F json"]
