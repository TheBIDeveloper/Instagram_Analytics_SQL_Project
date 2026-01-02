-- Instagram Analytics Project
-- Table Creation Script (SQL Server)

CREATE DATABASE InstagramAnalytics;
GO

USE InstagramAnalytics;
GO

-- Users table
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    full_name VARCHAR(100),
    join_date DATE,
    followers_count INT,
    following_count INT
);

-- Posts table
CREATE TABLE posts (
    post_id INT PRIMARY KEY,
    user_id INT,
    post_date DATE,
    post_type VARCHAR(20), -- image, video, reel
    caption_length INT,
    CONSTRAINT fk_posts_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Likes table
CREATE TABLE likes (
    like_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    like_date DATE,
    CONSTRAINT fk_likes_posts FOREIGN KEY (post_id) REFERENCES posts(post_id),
    CONSTRAINT fk_likes_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Comments table
CREATE TABLE comments (
    comment_id INT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment_date DATE,
    comment_length INT,
    CONSTRAINT fk_comments_posts FOREIGN KEY (post_id) REFERENCES posts(post_id),
    CONSTRAINT fk_comments_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);
