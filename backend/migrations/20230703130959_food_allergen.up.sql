-- Add up migration script here

CREATE TYPE allergen AS ENUM ('CA','DI','EI','ER','FI','GE','HF','HA','KA','KR','LU','MA','ML','PA','PE','PI','QU','RO','SA','SE','SF','SN','SO','WA','WE','WT','LA','GL');

CREATE TABLE food_allergen (
  food_id uuid REFERENCES food(food_id),
  allergen allergen NOT NULL,
  PRIMARY KEY (food_id, allergen)
);