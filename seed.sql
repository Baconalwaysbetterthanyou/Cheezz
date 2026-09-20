-- Seed User
INSERT INTO users (username, full_name) 
VALUES ('johndoe', 'John Doe');

-- Generate 90 days of daily_vitals (skips roughly 1 in 5 days for realism)
INSERT INTO daily_vitals (user_id, recorded_on, weight_kg, sleep_hours, mood)
SELECT 
    1,
    d::date,
    75.0 + (random() * 2.0 - 1.0)::decimal(5,2),
    4.0 + (random() * 5.5)::decimal(3,1),
    FLOOR(1 + random() * 5)::int
FROM generate_series(CURRENT_DATE - INTERVAL '89 days', CURRENT_DATE, '1 day'::interval) d
WHERE random() > 0.2;

-- Generate 60 exercise sessions over the last 90 days
INSERT INTO exercise_sessions (user_id, started_at, duration_min, activity, calories_burned)
SELECT 
    1,
    (CURRENT_DATE - (random() * 90 || ' days')::interval + (random() * 12 + 8 || ' hours')::interval),
    FLOOR(20 + random() * 40)::int,
    (ARRAY['running', 'cycling', 'gym', 'swimming'])[FLOOR(1 + random() * 4)],
    FLOOR(150 + random() * 350)::int
FROM generate_series(1, 60);

-- Generate 270 food log entries (3 per day average over 90 days)
INSERT INTO food_log (user_id, eaten_at, food_name, calories)
SELECT 
    1,
    (CURRENT_DATE - (random() * 90 || ' days')::interval + (random() * 14 + 7 || ' hours')::interval),
    (ARRAY['Oatmeal', 'Chicken Salad', 'Grilled Salmon', 'Protein Shake', 'Fruit Bowl', 'Pasta'])[FLOOR(1 + random() * 6)],
    FLOOR(250 + random() * 500)::int
FROM generate_series(1, 270);
