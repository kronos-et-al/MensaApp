-- Add up migration script here 
CREATE VIEW meal_detail AS (
    SELECT meal.*, 
		COALESCE(rating.average_rating, 5.0/2) as average_rating, COALESCE(rating.rating_count, 0) as rating_count
	FROM (
        -- meal
        SELECT *
        FROM meal JOIN food USING (food_id)
    ) meal LEFT JOIN (
        -- ratings
        SELECT food_id, AVG(rating::real)::real as average_rating, COUNT(*) as rating_count 
        FROM meal_rating
        GROUP BY food_id
    ) rating USING (food_id)
);


CREATE FUNCTION get_statistic(in i_food_id uuid, in i_serve_date date, 
    out new bool, out frequency integer, out last_Served date, out next_served date)
    AS $$
        SELECT 
        COUNT(*) FILTER (WHERE serve_date > i_serve_date) > 0 as new, 
        COUNT(*) FILTER (WHERE serve_date > i_serve_date - 30 * 3) as frequency,
        MAX(serve_date) FILTER (WHERE serve_date < CURRENT_DATE) as last_served,
        MIN(serve_date) FILTER (WHERE serve_date > CURRENT_DATE) as next_served 
        FROM food_plan
        WHERE food_id = i_food_id
    $$
    LANGUAGE SQL;