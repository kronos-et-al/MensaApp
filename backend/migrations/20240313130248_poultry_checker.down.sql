-- Add down migration script here
UPDATE food SET food_type = 'UNKNOWN' WHERE food_type = 'POULTRY';

