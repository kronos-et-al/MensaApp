-- Add up migration script here

CREATE DOMAIN weight_domain as smallint CHECK (VALUE > 0);
CREATE DOMAIN energy_domain as smallint CHECK (VALUE > 0);

CREATE TABLE food_env_score (
    energy energy_domain NOT NULL,
    protein weight_domain NOT NULL,
    carbohydrates weight_domain NOT NULL,
    sugar weight_domain NOT NULL,
    fat weight_domain NOT NULL,
    saturated_fat weight_domain NOT NULL,
    salt weight_domain NOT NULL,
    food_id uuid NOT NULL REFERENCES meal(food_id),
    PRIMARY KEY (food_id)
);