FROM rust:latest as builder
WORKDIR /usr/src/mensa-app-backend
COPY . .
ENV SQLX_OFFLINE=true
RUN cargo install --path .

FROM debian:bullseye-slim
# RUN apt-get update && apt-get install -y extra-runtime-dependencies && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/mensa-app-backend /usr/local/bin/mensa-app-backend
EXPOSE 80/tcp

# env vars
ENV DATABASE_URL= 
ENV SMTP_SERVER=
ENV SMTP_SERVER=
ENV SMTP_PORT=
ENV SMTP_USERNAME=
ENV SMTP_PASSWORD=
ENV ADMIN_EMAIL=

CMD ["mensa-app-backend"]