-- Add up migration script here
CREATE TABLE canteen (
  canteen_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  position integer NOT NULL
);