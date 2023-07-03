-- Add up migration script here
CREATE TABLE line (
  line_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  canteen_id uuid NOT NULL REFERENCES canteen(canteen_id),
  name text NOT NULL,
  position integer NOT NULL
);