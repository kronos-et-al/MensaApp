-- Add up migration script here

CREATE DOMAIN weight as integer CHECK (VALUE >= 0);
CREATE DOMAIN energy as integer CHECK (VALUE >= 0);

CREATE TABLE food_nutrition_data (
    energy energy NOT NULL,
    protein weight NOT NULL,
    carbohydrates weight NOT NULL,
    sugar weight NOT NULL,
    fat weight NOT NULL,
    saturated_fat weight NOT NULL,
    salt weight NOT NULL,
    food_id uuid NOT NULL REFERENCES food(food_id),
    PRIMARY KEY (food_id)
);