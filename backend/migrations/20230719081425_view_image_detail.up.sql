-- Add up migration script here

CREATE FUNCTION image_rank(link_date date, upvote bigint, downvote bigint, 
report_count bigint, approved boolean) RETURNS real AS $$
DECLARE
    s real := upvote::real / (upvote + downvote + 10 * report_count * (NOT approved)::integer + 1);
    a real := 1./2. - 1./60. * (CURRENT_DATE - link_date);
BEGIN
    IF a <= 0 THEN 
        a := 0;
    END IF;

    RETURN (1 - a) * s + a;
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE VIEW image_detail AS ( 
    SELECT image.*, COALESCE(upvotes::integer, 0) as upvotes, COALESCE(downvotes::integer, 0) as downvotes,
    COALESCE(report_count::integer, 0) as report_count,
    image_rank(link_date, COALESCE(upvotes, 0), COALESCE(downvotes, 0), COALESCE(report_count, 0), approved) as rank
    FROM (
        -- image
        SELECT * FROM image
    ) image LEFT JOIN (
        -- ratings
        SELECT image_id, 
        COUNT(*) FILTER (WHERE rating = 1) as upvotes, 
        COUNT(*) FILTER (WHERE rating = -1) as downvotes
        FROM image_rating
        GROUP BY image_id
    ) rating USING(image_id) LEFT JOIN (
        -- report
        SELECT image_id, COUNT(*) as report_count
        FROM image_report
        GROUP BY image_id
    ) reports USING(image_id)

);




-- tests
DO LANGUAGE plpgsql $$
DECLARE 
    res real;
BEGIN
    res := image_rank(CURRENT_DATE, 0, 0, 0, false);
    ASSERT res = 0.5, '1: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 30, 0, 0, 0, false);
    ASSERT res = 0, '2: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 29, 0, 0, 0, false);
    ASSERT res > 0, '3: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 400, 0, 0, 0, false);
    ASSERT res = 0, '4: returned ' || res;
    
    res := image_rank(CURRENT_DATE, 100, 0, 0, false);
    ASSERT res > 0.99, '5: returned ' || res;
    
    res := image_rank(CURRENT_DATE, 0, 100, 0, false);
    ASSERT res = 0.5, '6: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 30, 0, 100, 0, false);
    ASSERT res = 0, '7: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 30, 50, 100, 0, false);
    ASSERT res - 1./3. < 0.1, '8: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 30, 50, 0, 10, false);
    ASSERT res - 1./3. < 0.1, '9: returned ' || res;
    
    res := image_rank(CURRENT_DATE - 30, 100, 0, 10, true);
    ASSERT res > 0.99, '10: returned ' || res;
END;
$$;
