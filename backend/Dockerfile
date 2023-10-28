FROM rust:latest as builder
WORKDIR /usr/src/mensa-app-backend
COPY . .
ENV SQLX_OFFLINE=true
RUN cargo install --path . --profile release

# actual running image
FROM debian:bookworm-slim

# install http dependencies (through curl)
RUN apt-get update && apt-get install -y curl tzdata && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/mensa-app-backend /usr/local/bin/mensa-app-backend
RUN mensa-app-backend -h
EXPOSE 80/tcp
VOLUME /data/images

# env vars
ENV DATABASE_URL= 
ENV SMTP_SERVER=
ENV SMTP_SERVER=
ENV SMTP_USERNAME=
ENV SMTP_PASSWORD=
ENV ADMIN_EMAIL=
ENV GOOGLE_PROJECT_ID=
ENV SERVICE_ACCOUNT_JSON=/data/service_account.json
ENV IMAGE_DIR=/data/images


ENTRYPOINT ["mensa-app-backend"]