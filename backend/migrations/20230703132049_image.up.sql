-- Add up migration script here

CREATE TABLE image (
  image_id uuid DEFAULT gen_random_uuid()  PRIMARY KEY,
  user_id uuid NOT NULL,
  food_id uuid NOT NULL REFERENCES meal(food_id),
  id text NOT NULL,
  url text NOT NULL,
  link_date date NOT NULL DEFAULT CURRENT_DATE,
  last_verified_date date NOT NULL DEFAULT CURRENT_DATE,
  approved boolean NOT NULL DEFAULT false,
  currently_visible boolean NOT NULL DEFAULT true
); 