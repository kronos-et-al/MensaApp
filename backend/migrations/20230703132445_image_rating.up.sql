-- Add up migration script here
CREATE DOMAIN vote as smallint CHECK (VALUE = -1 OR VALUE = 1);

CREATE TABLE image_rating (
  image_id uuid NOT NULL REFERENCES image(image_id),
  user_id uuid NOT NULL,
  rating vote NOT NULL,
  PRIMARY KEY (image_id, user_id)
);