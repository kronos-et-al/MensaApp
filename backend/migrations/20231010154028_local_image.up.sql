-- Add up migration script here

ALTER TABLE image ALTER id DROP NOT NULL;
ALTER TABLE image ALTER url DROP NOT NULL;