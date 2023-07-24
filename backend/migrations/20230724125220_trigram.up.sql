-- Add up migration script here

SET pg_trgm.similarity_threshold = 0.8;
CREATE EXTENSION pg_trgm;
