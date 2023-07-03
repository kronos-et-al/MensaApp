-- Add up migration script here
CREATE TABLE canteen (
  canteen_id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name text NOT NULL
);