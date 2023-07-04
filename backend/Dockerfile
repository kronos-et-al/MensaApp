FROM rust:1.67 as builder
WORKDIR /usr/src/mensa-app-backend
COPY . .
RUN cargo install --path .

FROM debian:bullseye-slim
# RUN apt-get update && apt-get install -y extra-runtime-dependencies && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/mensa-app-backend /usr/local/bin/mensa-app-backend
CMD ["mensa-app-backend"]