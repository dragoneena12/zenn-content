CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL
);

INSERT INTO users (id, name, email) VALUES
    ('a0eebc3d-8f1b-4c2b-9f5e-6d7f8e9a0b1c', 'Alice', 'test@example.com');
