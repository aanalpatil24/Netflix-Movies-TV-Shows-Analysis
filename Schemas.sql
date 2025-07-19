-- Create and use the database
CREATE DATABASE IF NOT EXISTS netflix_db;
USE netflix_db;

-- SCHEMAS of Netflix
-- Drop table if it exists
DROP TABLE IF EXISTS netflix;

-- Create table
CREATE TABLE netflix (
    show_id        VARCHAR(10),
    type           VARCHAR(20),
    title          VARCHAR(255),
    director       TEXT,
    casts          TEXT,
    country        TEXT,
    date_added     VARCHAR(100),
    release_year   INT,
    rating         VARCHAR(20),
    duration       VARCHAR(20),
    listed_in      TEXT,
    description    TEXT
);

-- Check table
SELECT * FROM netflix;
