CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE scans (
    scan_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    scan_type VARCHAR(30),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE scan_results (
    result_id SERIAL PRIMARY KEY,
    scan_id INT REFERENCES scans(scan_id),
    risk_score INT,
    risk_level VARCHAR(20),
    explanation TEXT,
    recommendation TEXT
);

CREATE TABLE known_scams (
    scam_id SERIAL PRIMARY KEY,
    category VARCHAR(50),
    title VARCHAR(150),
    description TEXT,
    risk_level VARCHAR(20)
);

CREATE TABLE url_reputation (
    url_id SERIAL PRIMARY KEY,
    url TEXT NOT NULL,
    reputation VARCHAR(20),
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reports (
    report_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    scan_id INT REFERENCES scans(scan_id),
    report_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    title VARCHAR(100),
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE uploaded_files (
    file_id SERIAL PRIMARY KEY,
    scan_id INT REFERENCES scans(scan_id),
    file_name VARCHAR(255),
    file_type VARCHAR(50),
    file_path TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);