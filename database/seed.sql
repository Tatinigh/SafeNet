INSERT INTO users (full_name, email, password_hash, phone)
VALUES
('Khushal Mittal', 'khushal@gmail.com', 'hashed_password', '9950764003');

INSERT INTO scans (user_id, scan_type, content)
VALUES
(1, 'QR Code', 'https://fake-paytm-payment.com');

INSERT INTO scan_results (scan_id, risk_score, risk_level, explanation, recommendation)
VALUES
(
1,
98,
'High',
'The URL resembles a phishing payment website.',
'Do not click the link. Verify through the official website.'
);

INSERT INTO known_scams (category, title, description, risk_level)
VALUES
(
'Job Scam',
'Fake Google Hiring',
'Fraudsters ask candidates to pay money for document verification.',
'High'
);