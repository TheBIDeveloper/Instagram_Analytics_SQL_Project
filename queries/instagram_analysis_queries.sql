USE InstagramAnalytics;
GO

--------------------------------------------------
-- 1. Total users on platform
--------------------------------------------------
SELECT COUNT(*) AS total_users
FROM users;


--------------------------------------------------
-- 2. User-wise follower to following ratio
--------------------------------------------------
SELECT
    username,
    followers_count,
    following_count,
    CAST(followers_count AS FLOAT) / NULLIF(following_count, 0) AS follower_following_ratio
FROM users;


--------------------------------------------------
-- 3. Total posts per user
--------------------------------------------------
SELECT
    u.username,
    COUNT(p.post_id) AS total_posts
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.username
ORDER BY total_posts DESC;


--------------------------------------------------
-- 4. Likes per post
--------------------------------------------------
SELECT
    p.post_id,
    COUNT(l.like_id) AS total_likes
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id
ORDER BY total_likes DESC;


--------------------------------------------------
-- 5. Comments per post
--------------------------------------------------
SELECT
    p.post_id,
    COUNT(c.comment_id) AS total_comments
FROM posts p
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id
ORDER BY total_comments DESC;


--------------------------------------------------
-- 6. Engagement per post (likes + comments)
--------------------------------------------------
SELECT
    p.post_id,
    COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id
ORDER BY total_engagement DESC;


--------------------------------------------------
-- 7. Average engagement per user
--------------------------------------------------
SELECT
    u.username,
    AVG(ISNULL(eng.total_engagement, 0)) AS avg_engagement
FROM users u
LEFT JOIN (
    SELECT
        p.user_id,
        p.post_id,
        COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
    FROM posts p
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY p.user_id, p.post_id
) eng ON u.user_id = eng.user_id
GROUP BY u.username
ORDER BY avg_engagement DESC;


--------------------------------------------------
-- 8. Most liked post
--------------------------------------------------
SELECT TOP 1
    p.post_id,
    COUNT(l.like_id) AS total_likes
FROM posts p
JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id
ORDER BY total_likes DESC;


--------------------------------------------------
-- 9. Most commented post
--------------------------------------------------
SELECT TOP 1
    p.post_id,
    COUNT(c.comment_id) AS total_comments
FROM posts p
JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id
ORDER BY total_comments DESC;


--------------------------------------------------
-- 10. Post type performance
--------------------------------------------------
SELECT
    post_type,
    COUNT(*) AS total_posts
FROM posts
GROUP BY post_type
ORDER BY total_posts DESC;
