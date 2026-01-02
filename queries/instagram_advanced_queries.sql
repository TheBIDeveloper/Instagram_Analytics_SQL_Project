USE InstagramAnalytics;
GO

--------------------------------------------------
-- 11. Rank users by total followers (Window Function)
--------------------------------------------------
SELECT
    username,
    followers_count,
    RANK() OVER (ORDER BY followers_count DESC) AS follower_rank
FROM users;


--------------------------------------------------
-- 12. Rank users by total engagement
--------------------------------------------------
WITH engagement_cte AS (
    SELECT
        u.user_id,
        u.username,
        COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
    FROM users u
    LEFT JOIN posts p ON u.user_id = p.user_id
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY u.user_id, u.username
)
SELECT
    username,
    total_engagement,
    RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
FROM engagement_cte;


--------------------------------------------------
-- 13. Running total of posts per user
--------------------------------------------------
SELECT
    u.username,
    p.post_date,
    COUNT(p.post_id) OVER (
        PARTITION BY u.username
        ORDER BY p.post_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_posts
FROM posts p
JOIN users u ON p.user_id = u.user_id;


--------------------------------------------------
-- 14. Average engagement by post type
--------------------------------------------------
SELECT
    p.post_type,
    AVG(eng.total_engagement) AS avg_engagement
FROM posts p
JOIN (
    SELECT
        post_id,
        COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
    FROM posts p
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY post_id
) eng ON p.post_id = eng.post_id
GROUP BY p.post_type
ORDER BY avg_engagement DESC;


--------------------------------------------------
-- 15. Users with engagement above platform average
--------------------------------------------------
WITH user_engagement AS (
    SELECT
        u.user_id,
        u.username,
        COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
    FROM users u
    LEFT JOIN posts p ON u.user_id = p.user_id
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY u.user_id, u.username
)
SELECT
    username,
    total_engagement
FROM user_engagement
WHERE total_engagement >
      (SELECT AVG(total_engagement) FROM user_engagement);


--------------------------------------------------
-- 16. Engagement rate per post (Engagement / Followers)
--------------------------------------------------
SELECT
    p.post_id,
    u.username,
    CAST(
        (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) 
        AS FLOAT
    ) / NULLIF(u.followers_count, 0) AS engagement_rate
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, u.username, u.followers_count
ORDER BY engagement_rate DESC;


--------------------------------------------------
-- 17. Most consistent users (posting frequency)
--------------------------------------------------
SELECT
    u.username,
    COUNT(p.post_id) AS total_posts,
    DATEDIFF(DAY, MIN(p.post_date), MAX(p.post_date)) AS active_days
FROM users u
JOIN posts p ON u.user_id = p.user_id
GROUP BY u.username
ORDER BY total_posts DESC;


--------------------------------------------------
-- 18. Users with zero engagement
--------------------------------------------------
SELECT
    u.username
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY u.username
HAVING COUNT(l.like_id) + COUNT(c.comment_id) = 0;


--------------------------------------------------
-- 19. Top post per user based on engagement
--------------------------------------------------
WITH post_engagement AS (
    SELECT
        p.user_id,
        p.post_id,
        COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
    FROM posts p
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY p.user_id, p.post_id
)
SELECT *
FROM (
    SELECT
        u.username,
        pe.post_id,
        pe.total_engagement,
        RANK() OVER (PARTITION BY u.username ORDER BY pe.total_engagement DESC) AS post_rank
    FROM post_engagement pe
    JOIN users u ON pe.user_id = u.user_id
) ranked
WHERE post_rank = 1;


--------------------------------------------------
-- 20. Monthly post activity trend
--------------------------------------------------
SELECT
    FORMAT(post_date, 'yyyy-MM') AS month,
    COUNT(post_id) AS total_posts
FROM posts
GROUP BY FORMAT(post_date, 'yyyy-MM')
ORDER BY month;
