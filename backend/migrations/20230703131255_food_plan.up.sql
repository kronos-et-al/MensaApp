-- Add up migration script here

CREATE DOMAIN price AS integer CHECK (VALUE >= 0);

CREATE TYPE prices AS (
  student price,
  employee price,
  guest price,
  pupil price
);

CREATE TABLE food_plan (
  line_id uuid NOT NULL REFERENCES line(line_id),
  food_id uuid NOT NULL REFERENCES food(food_id),
  serve_date date NOT NULL,
  prices prices NOT NULL,
  PRIMARY KEY (line_id, food_id, serve_date)
);
