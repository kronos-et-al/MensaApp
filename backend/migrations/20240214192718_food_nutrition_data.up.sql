-- Add up migration script here

CREATE DOMAIN weight_domain as INT CHECK (VALUE > 0);
CREATE DOMAIN energy_domain as INT CHECK (VALUE > 0);

CREATE TABLE food_nutrition_data (
    energy energy_domain NOT NULL,
    protein weight_domain NOT NULL,
    carbohydrates weight_domain NOT NULL,
    sugar weight_domain NOT NULL,
    fat weight_domain NOT NULL,
    saturated_fat weight_domain NOT NULL,
    salt weight_domain NOT NULL,
    food_id uuid NOT NULL REFERENCES food(food_id),
    PRIMARY KEY (food_id)
);