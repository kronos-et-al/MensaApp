-- Add up migration script here
CREATE TYPE food_type AS ENUM ('VEGAN','VEGETARIAN','BEEF','BEEF_AW','PORK','PORK_AW','FISH','UNKNOWN');

CREATE TABLE food (
  food_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  food_type food_type DEFAULT 'UNKNOWN' NOT NULL
);