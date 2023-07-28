-- Add up migration script here

CREATE DOMAIN price AS integer CHECK (VALUE >= 0);


CREATE TABLE food_plan (
  line_id uuid NOT NULL REFERENCES line(line_id),
  food_id uuid NOT NULL REFERENCES food(food_id),
  serve_date date NOT NULL,
  price_student price NOT NULL,
  price_employee price NOT NULL,
  price_guest price NOT NULL,
  price_pupil price NOT NULL,
  PRIMARY KEY (line_id, food_id, serve_date)
);
