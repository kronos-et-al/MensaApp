-- Add up migration script here

CREATE TABLE meal (
  food_id uuid PRIMARY KEY REFERENCES food(food_id)
);
