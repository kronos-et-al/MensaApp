-- Add up migration script here 
CREATE VIEW meal_detail AS (
    SELECT meal.*, COALESCE(stat.new, true) as new,
		COALESCE(stat.frequency, 0) as frequency, stat.last_served, stat.next_served,
		COALESCE(rating.average_rating, 0) as average_rating, COALESCE(rating.rating_count, 0) as rating_count
	FROM (
        -- meal
        SELECT *
        FROM meal JOIN food USING (food_id)
    ) meal LEFT JOIN (
        -- statistics
        SELECT food_id, COUNT(*) FILTER (WHERE serve_date < CURRENT_DATE) = 0 as new, 
        COUNT(*) FILTER (WHERE serve_date >= CURRENT_DATE - 30 * 3 AND serve_date < CURRENT_DATE) as frequency,
        MAX(serve_date) FILTER (WHERE serve_date < CURRENT_DATE) as last_served,
        MIN(serve_date) FILTER (WHERE serve_date > CURRENT_DATE) as next_served 
        FROM food_plan
        GROUP BY food_id
    ) stat USING (food_id) LEFT JOIN (
        -- ratings
        SELECT food_id, AVG(rating::real)::real as average_rating, COUNT(*) as rating_count 
        FROM meal_rating
        GROUP BY food_id
    ) rating USING (food_id)
);