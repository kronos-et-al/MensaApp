INSERT INTO image(image_id, user_id, food_id, link_date, last_verified_date, approved, currently_visible)
VALUES  ('76b904fe-d0f1-4122-8832-d0e21acab86d', 'c51d2d81-3547-4f07-af58-ed613c6ece67', 'f7337122-b018-48ad-b420-6202dc3cb4ff', CURRENT_DATE, CURRENT_DATE, false, true),
        ('1aa73d5d-1701-4975-aa3c-1422a8bc10e8', 'c51d2d81-3547-4f07-af58-ed613c6ece67', 'f7337122-b018-48ad-b420-6202dc3cb4ff', CURRENT_DATE, CURRENT_DATE, true, true),
        ('ea8cce48-a3c7-4f8e-a222-5f3891c13804', '00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf', 'f7337122-b018-48ad-b420-6202dc3cb4ff', CURRENT_DATE, CURRENT_DATE, false, true),
        ('68153ab6-ebbf-48f4-b8dd-a9b2a19a5221', 'c51d2d81-3547-4f07-af58-ed613c6ece67', 'f7337122-b018-48ad-b420-6202dc3cb4ff', CURRENT_DATE, CURRENT_DATE, false, false);

INSERT INTO image_report (image_id, user_id, report_date, reason) VALUES ('ea8cce48-a3c7-4f8e-a222-5f3891c13804', 'c51d2d81-3547-4f07-af58-ed613c6ece67', CURRENT_DATE + 1, 'ADVERT');