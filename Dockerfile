FROM golang:1.22.0-alpine3.19 as builder

WORKDIR /src
COPY . .
RUN apk add -U \
  ca-certificates \
  tzdata

ENV TZ=America/Fortaleza
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -tags="-timetzdata" -o application .

FROM scratch

WORKDIR /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /src/application /app
COPY --from=builder /src/.env /app

EXPOSE 5000

ENTRYPOINT ["./application"]
