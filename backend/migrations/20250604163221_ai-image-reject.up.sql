-- Add up migration script here
ALTER TABLE image ADD COLUMN approval_message text;
-- recreate the exact same view, but now the new column is included.
DROP VIEW image_detail;
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