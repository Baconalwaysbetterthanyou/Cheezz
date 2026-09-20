-- Query 1: Average sleep per week for the last 12 weeks
SELECT 
    DATE_TRUNC('week', recorded_on) AS week_start,
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours
FROM daily_vitals
WHERE recorded_on >= CURRENT_DATE - INTERVAL '12 weeks'
GROUP BY week_start
ORDER BY week_start DESC;

-- Query 2: 7-day rolling average weight
SELECT 
    recorded_on,
    weight_kg,
    ROUND(AVG(weight_kg) OVER (
        ORDER BY recorded_on 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_7day_avg_weight
FROM daily_vitals
ORDER BY recorded_on DESC;

-- Query 3: Calorie balance per day (calories eaten - calories burned) for last 30 days
WITH daily_eaten AS (
    SELECT DATE(eaten_at) AS log_date, SUM(calories) AS total_eaten
    FROM food_log
    WHERE eaten_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY DATE(eaten_at)
),
daily_burned AS (
    SELECT DATE(started_at) AS log_date, SUM(calories_burned) AS total_burned
    FROM exercise_sessions
    WHERE started_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY DATE(started_at)
)
SELECT 
    COALESCE(e.log_date, b.log_date) AS log_date,
    COALESCE(e.total_eaten, 0) AS total_eaten,
    COALESCE(b.total_burned, 0) AS total_burned,
    (COALESCE(e.total_eaten, 0) - COALESCE(b.total_burned, 0)) AS calorie_balance
FROM daily_eaten e
FULL OUTER JOIN daily_burned b ON e.log_date = b.log_date
ORDER BY log_date DESC;

-- Query 4: Days with mood <= 2 with conditional reason comment
SELECT 
    recorded_on,
    sleep_hours,
    mood,
    CASE 
        WHEN sleep_hours < 6 THEN 'check sleep'
        ELSE 'other reason'
    END AS reason
FROM daily_vitals
WHERE mood <= 2
ORDER BY recorded_on DESC;

-- Query 5: Most-frequent exercise activity in the last 30 days
SELECT 
    activity,
    COUNT(*) AS session_count
FROM exercise_sessions
WHERE started_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY activity
ORDER BY session_count DESC
LIMIT 1;
