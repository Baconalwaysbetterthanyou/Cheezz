-- ============================================================
-- Personal Health Tracker — schema.sql
-- W4 Unit 18-19 · Part 1: build the schema
-- ============================================================

-- Clean up existing tables if re-running script (in reverse dependency order)
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS food_log CASCADE;
DROP TABLE IF EXISTS exercise_sessions CASCADE;
DROP TABLE IF EXISTS daily_vitals CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL
);

CREATE TABLE daily_vitals (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recorded_on DATE NOT NULL,
    weight_kg DECIMAL(5, 2) CHECK (weight_kg > 0),
    sleep_hours DECIMAL(3, 1) CHECK (sleep_hours BETWEEN 0 AND 24),
    mood INTEGER CHECK (mood BETWEEN 1 AND 5),
    UNIQUE (user_id, recorded_on)
);

-- exercise_sessions
CREATE TABLE exercise_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL,
    duration_min INTEGER CHECK (duration_min > 0),
    activity TEXT NOT NULL,
    calories_burned INTEGER CHECK (calories_burned >= 0)
);

-- food_log
CREATE TABLE food_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    eaten_at TIMESTAMP NOT NULL,
    food_name TEXT NOT NULL,
    calories INTEGER CHECK (calories >= 0)
);

-- audit_log
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    db_user TEXT NOT NULL,
    table_name TEXT NOT NULL,
    action TEXT NOT NULL,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
