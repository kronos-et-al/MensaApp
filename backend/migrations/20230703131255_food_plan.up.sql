-- Add up migration script here

CREATE DOMAIN price AS integer CHECK (VALUE >= 0);

CREATE TABLE food_plan (
  line_id uuid NOT NULL,
  food_id uuid NOT NULL,
  date date NOT NULL,
  priceStudent price NOT NULL,
  priceEmployee price NOT NULL,
  pricePupil price NOT NULL,
  priceGuest price NOT NULL,
  PRIMARY KEY (line_id, food_id, date)
);
