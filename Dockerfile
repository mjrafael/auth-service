# --- Etapa 1: build ---
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

RUN go mod tidy

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/auth-service .

# --- Etapa 2: runtime (imagem mínima) ---
FROM alpine:3.19

RUN apk add --no-cache ca-certificates && \
    adduser -D -u 1000 appuser
WORKDIR /app
COPY --from=builder /out/auth-service .
USER appuser

EXPOSE 8001
ENTRYPOINT ["./auth-service"]
