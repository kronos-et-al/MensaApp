-- Add up migration script here
ALTER TYPE meal_type add value 'POULTRY';
COMMIT;

UPDATE food SET food_type = 'POULTRY' WHERE name ~ '(?i)ente|chicken|pute|geflügel|h[üäua]hn';