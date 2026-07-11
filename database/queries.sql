SELECT * FROM users;

SELECT * FROM scans;

SELECT * FROM scan_results;

SELECT * FROM known_scams;

SELECT * FROM reports;

SELECT * FROM notifications;

SELECT *
FROM scan_results
WHERE risk_level = 'High';

SELECT
u.full_name,
s.scan_type,
s.content
FROM users u
JOIN scans s
ON u.user_id = s.user_id;