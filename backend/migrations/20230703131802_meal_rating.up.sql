-- Add up migration script here

CREATE DOMAIN rating as smallint CHECK (VALUE > 0 AND VALUE <= 5);

CREATE TABLE meal_rating (
  user_id uuid NOT NULL REFERENCES user(user_id),
  food_id uuid NOT NULL REFERENCES meal(food_id),
  rating rating NOT NULL,
  PRIMARY KEY (user_id, food_id)
);