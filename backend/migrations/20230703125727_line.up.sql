-- Add up migration script here
CREATE TABLE line (
  line_id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  canteen_id uuid NOT NULL REFERENCES canteen(canteen_id),
  name text NOT NULL,
  position integer NOT NULL
);