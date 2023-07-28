INSERT INTO public.meal_rating (user_id, food_id, rating)
VALUES  ('c51d2d81-3547-4f07-af58-ed613c6ece67', 'f7337122-b018-48ad-b420-6202dc3cb4ff', 5),
        ('00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf', 'f7337122-b018-48ad-b420-6202dc3cb4ff', 4),
        ('c51d2d81-3547-4f07-af58-ed613c6ece67', '25cb8c50-75a4-48a2-b4cf-8ab2566d8bec', 3);

INSERT INTO public.image_rating (image_id, user_id, rating)
VALUES  ('76b904fe-d0f1-4122-8832-d0e21acab86d', 'c51d2d81-3547-4f07-af58-ed613c6ece67', 1),
        ('76b904fe-d0f1-4122-8832-d0e21acab86d', '00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf', -1),
        ('ea8cce48-a3c7-4f8e-a222-5f3891c13804', 'c51d2d81-3547-4f07-af58-ed613c6ece67', 1);