-- Netflix Movies & TV Shows Analysis Project
-- Commencement of the project
-- Create and use the database
CREATE DATABASE IF NOT EXISTS Netflix_DB;
USE Netflix_DB;
-- DROP DATABaSE IF EXISTS Netflix_DB;
-- SCHEMA of Netflix_DB
-- Drop table if it exists
DROP TABLE IF EXISTS netflix;

-- Create table
CREATE TABLE netflix (
    show_id  VARCHAR(10) PRIMARY KEY,
    show_type  VARCHAR(20),
    title  VARCHAR(255),
    director TEXT,
    casts  TEXT,
    country TEXT,
    date_added  VARCHAR(100),
    release_year INT,
    rating  VARCHAR(20),
    duration  VARCHAR(20),
    genre TEXT,
    show_description  TEXT
);

-- Check table
SELECT * FROM netflix;
