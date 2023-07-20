-- Add up migration script here 
CREATE VIEW meal_detail AS (
    SELECT * FROM (
        -- meal
        SELECT *
        FROM meal JOIN food USING (food_id) JOIN food_plan USING (food_id) 
    ) meal JOIN (
        -- statistics
        SELECT food_id, (COUNT(*) = 0) as new, 
        COUNT(*) FILTER (WHERE serve_date > CURRENT_DATE - 30 * 3) as frequency,
        MAX(serve_date) FILTER (WHERE serve_date < CURRENT_DATE) as last_served,
        MIN(serve_date) FILTER (WHERE serve_date > CURRENT_DATE) as next_served 
        FROM food_plan
        GROUP BY food_id
    ) stat USING (food_id) JOIN (
        -- ratings
        SELECT food_id, AVG(rating::real)::real as average_rating, COUNT(*) as rating_count 
        FROM meal_rating
        GROUP BY food_id
    ) rating USING (food_id)
);