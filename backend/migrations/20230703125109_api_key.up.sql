-- Add up migration script here
CREATE TABLE api_key (
  api_key text PRIMARY KEY,
  description text NOT NULL
);
