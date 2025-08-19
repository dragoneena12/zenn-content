CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL
);

INSERT INTO users (id, name, email)
SELECT 
    ('00000000-0000-0000-0000-' || lpad(i::text, 12, '0'))::UUID,
    'User' || i,
    'user' || i || '@example.com'
FROM generate_series(1, 100000) AS i;

CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    assignee TEXT NOT NULL,
    assignee_type TEXT NOT NULL CHECK (assignee_type IN ('user', 'name'))
);

INSERT INTO tickets (id, title, assignee, assignee_type)
WITH user_ids AS (
    SELECT id, row_number() OVER (ORDER BY id) AS rn 
    FROM users
)
SELECT 
    ('00000000-0000-0002-0000-' || lpad(i::text, 12, '0'))::UUID,
    'Task #' || i,
    CASE 
        WHEN i % 2 = 0 THEN 
            (SELECT id::TEXT FROM user_ids WHERE rn = ((i / 2) % 100000) + 1)
        ELSE 
            'DirectAssignee' || ((i / 2) % 100000 + 1)
    END AS assignee,
    CASE 
        WHEN i % 2 = 0 THEN 'user'
        ELSE 'name'
    END AS assignee_type
FROM generate_series(1, 300000) AS i;
