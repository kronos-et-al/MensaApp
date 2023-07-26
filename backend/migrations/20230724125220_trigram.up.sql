-- Add up migration script here

CREATE EXTENSION pg_trgm;
SET pg_trgm.similarity_threshold = 0.8;