create database saas_project;
use saas_project;
-- 1. Users Management Table - Store user profiles and information
CREATE TABLE users(
	user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    
    -- Indexes for user table
    INDEX idx_email(email),
    INDEX idx_status(status)
);

-- 2. Subscription Plans table - defines available plans
CREATE TABLE subscription_plans(
	plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(20) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle ENUM('monthly', 'yearly') NOT NULL,
    
    -- features
    api_calls_limit INT DEFAULT 1000,
    storage_limit_gb INT DEFAULT 5,
    users_limit INT DEFAULT 1,
    
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- index for plan table
    INDEX idx_status (status),
    INDEX idx_price (price)
);

-- 3. User Subscriptions table - tracks user's current and past subscriptions
CREATE TABLE user_subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'cancelled', 'expired', 'pending') DEFAULT 'pending',
	
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	-- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id),
    
    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_dates (start_date, end_date)
);

-- 4. Payments table - records all payment transactions
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_id INT,
    
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('credit_card', 'paypal', 'bank_transfer', 'stripe') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES user_subscriptions(subscription_id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_user_payment (user_id),
    INDEX idx_status (payment_status),
    INDEX idx_transaction (transaction_id)
);

-- 5. Usage Tracking table - monitors user resource consumption
CREATE TABLE usage_tracking (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    
    -- Usage metrics
    api_calls_used INT DEFAULT 0,
    storage_used_gb DECIMAL(8,2) DEFAULT 0,
    
    usage_date DATE NOT NULL,
    
    -- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES user_subscriptions(subscription_id) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicate daily records
    UNIQUE KEY unique_user_date (user_id, usage_date),
    
    -- Indexes
    INDEX idx_user_usage (user_id),
    INDEX idx_date (usage_date)
);

-- 6. Invoices table - stores billing invoices
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    billing_period_start DATE NOT NULL,
    billing_period_end DATE NOT NULL,
    
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    
    status ENUM('pending', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    
    -- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES user_subscriptions(subscription_id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_invoice (user_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);

-- 7. Subscription History table - tracks plan upgrades/downgrades
CREATE TABLE subscription_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    old_subscription_id INT,
    new_subscription_id INT,
    
    change_type ENUM('upgrade', 'downgrade', 'renewal', 'cancellation') NOT NULL,
    change_reason TEXT,
    
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (old_subscription_id) REFERENCES user_subscriptions(subscription_id) ON DELETE SET NULL,
    FOREIGN KEY (new_subscription_id) REFERENCES user_subscriptions(subscription_id) ON DELETE SET NULL,
    
    -- Indexes
    INDEX idx_user_history (user_id),
    INDEX idx_change_type (change_type)
);

-- 8. Failed Payments table - tracks payment failures
CREATE TABLE failed_payments (
    failed_payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_id INT NOT NULL,
    user_id INT NOT NULL,
    
    failure_reason TEXT,
    failure_code VARCHAR(50),
    retry_count INT DEFAULT 0,
    
    failed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    next_retry_date TIMESTAMP NULL,
    
    -- Foreign keys
    FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_user_failed (user_id),
    INDEX idx_retry_date (next_retry_date)
);

-- bonus features (9)
-- discount on subscription plans
CREATE TABLE coupons (
    coupon_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,

    discount_value DECIMAL(10,2) NOT NULL,
    
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    usage_limit INT DEFAULT 1,
    used_count INT DEFAULT 0,
    
    status ENUM('active', 'inactive', 'expired') DEFAULT 'active',
    
    INDEX idx_code (coupon_code),
    INDEX idx_validity (valid_from, valid_until)
);

-- Insert users info
INSERT INTO users (name, email, status) VALUES
('Ravi Kumar', 'ravi.kumar@example.com', 'active'),
('Anjali Singh', 'anjali.singh@example.com', 'inactive'),
('Mohit Verma', 'mohit.v@example.com', 'suspended'),
('Pooja Sharma', 'pooja.sharma@example.com', 'active'),
('Aman Joshi', 'aman.j@example.com', 'active'),
('Neha Yadav', 'neha.yadav@example.com', 'inactive'),
('Vikram Rana', 'vikram.rana@example.com', 'suspended'),
('Kriti Mehra', 'kriti.mehra@example.com', 'active');

-- Insert plan info
INSERT INTO subscription_plans (
    plan_name, description, price, billing_cycle,
    api_calls_limit, storage_limit_gb, users_limit,
    status
) VALUES
-- Basic Monthly Plan
('Starter', 'Best for individuals starting out.', 9.99, 'monthly', 1000, 5, 1, 'active'),
-- Standard Monthly Plan
('Pro', 'Designed for small teams with more features.', 29.99, 'monthly', 10000, 50, 5, 'active'),
-- Business Monthly Plan
('Business', 'For growing businesses needing scalability.', 59.99, 'monthly', 50000, 200, 25, 'active'),
-- Yearly Basic Plan
('Starter Annual', 'Annual version of Starter with discount.', 99.99, 'yearly', 12000, 5, 1, 'active'),
-- Yearly Pro Plan
('Pro Annual', 'Annual plan with extra features.', 299.99, 'yearly', 120000, 50, 5, 'active'),
-- Yearly Business Plan
('Business Annual', 'Yearly plan for large teams.', 599.99, 'yearly', 600000, 200, 25, 'active'),
-- Legacy Plan (Inactive)
('Legacy', 'Deprecated plan, no longer available.', 19.99, 'monthly', 5000, 10, 3, 'inactive');

-- insert user plan info
INSERT INTO user_subscriptions (
    user_id, plan_id, start_date, end_date, status
) VALUES
(1, 1, '2025-06-01', '2025-07-01', 'active'),
(2, 4, '2024-08-01', '2025-08-01', 'expired'),
(3, 2, '2025-06-15', '2025-07-15', 'cancelled'),
(4, 5, '2025-01-01', '2026-01-01', 'active'),
(5, 3, '2025-05-10', '2025-06-10', 'expired'),
(6, 6, '2025-06-01', '2026-06-01', 'active'),
(7, 7, '2024-05-01', '2024-06-01', 'cancelled'),
(8, 2, '2025-06-20', '2025-07-20', 'pending');

-- insert payment info
INSERT INTO payments (
    user_id, subscription_id, amount, payment_method, payment_status, transaction_id
) VALUES
(1, 1, 9.99, 'credit_card', 'completed', 'TXN1001CC'),
(2, 2, 99.99, 'paypal', 'completed', 'TXN1002PP'),
(3, 3, 29.99, 'stripe', 'failed', 'TXN1003ST'),
(4, 4, 299.99, 'credit_card', 'completed', 'TXN1004CC'),
(5, 5, 59.99, 'bank_transfer', 'refunded', 'TXN1005BT'),
(6, 6, 599.99, 'paypal', 'completed', 'TXN1006PP'),
(7, 7, 19.99, 'stripe', 'completed', 'TXN1007ST'),
(8, 8, 29.99, 'credit_card', 'pending', 'TXN1008CC');

-- insert usage info
INSERT INTO usage_tracking (
    user_id, subscription_id, api_calls_used, storage_used_gb, usage_date
) VALUES
(1, 1, 150, 1.25, '2025-06-20'),
(2, 2, 980, 4.90, '2025-06-20'),
(3, 3, 300, 2.30, '2025-06-20'),
(4, 4, 1200, 15.75, '2025-06-20'),
(5, 5, 870, 9.10, '2025-06-20'),
(6, 6, 5200, 55.50, '2025-06-20'),
(7, 7, 400, 3.80, '2025-06-20'),
(8, 8, 50, 0.20, '2025-06-20');

-- insert invoice info
INSERT INTO invoices (
    user_id, subscription_id, invoice_number, amount, tax_amount, total_amount,
    billing_period_start, billing_period_end, invoice_date, due_date, status
) VALUES
(1, 1, 'INV-20250601-001', 9.99, 0.90, 10.89, '2025-06-01', '2025-07-01', '2025-06-01', '2025-06-10', 'paid'),
(2, 2, 'INV-20240801-002', 99.99, 9.00, 108.99, '2024-08-01', '2025-08-01', '2024-08-01', '2024-08-10', 'paid'),
(3, 3, 'INV-20250615-003', 29.99, 2.70, 32.69, '2025-06-15', '2025-07-15', '2025-06-15', '2025-06-25', 'overdue'),
(4, 4, 'INV-20250101-004', 299.99, 27.00, 326.99, '2025-01-01', '2026-01-01', '2025-01-01', '2025-01-10', 'paid'),
(5, 5, 'INV-20250510-005', 59.99, 5.40, 65.39, '2025-05-10', '2025-06-10', '2025-05-10', '2025-05-20', 'cancelled'),
(6, 6, 'INV-20250601-006', 599.99, 54.00, 653.99, '2025-06-01', '2026-06-01', '2025-06-01', '2025-06-10', 'paid'),
(7, 7, 'INV-20240501-007', 19.99, 1.80, 21.79, '2024-05-01', '2024-06-01', '2024-05-01', '2024-05-10', 'cancelled'),
(8, 8, 'INV-20250620-008', 29.99, 2.70, 32.69, '2025-06-20', '2025-07-20', '2025-06-20', '2025-06-30', 'pending');

-- insert plan history info
INSERT INTO subscription_history (
    user_id, old_subscription_id, new_subscription_id, change_type, change_reason
) VALUES
(1, 1, 2, 'upgrade', 'User upgraded to Pro plan for more features'),
(2, 2, NULL, 'cancellation', 'User cancelled subscription due to inactivity'),
(3, 3, 4, 'upgrade', 'Upgraded to annual plan for cost savings'),
(4, 4, 4, 'renewal', 'Renewed Business Annual plan for one more year'),
(5, 5, 1, 'downgrade', 'Downgraded to Starter plan to reduce costs'),
(6, 6, 6, 'renewal', 'Renewed yearly subscription after expiry'),
(7, 7, NULL, 'cancellation', 'Switched to another service'),
(8, NULL, 8, 'renewal', 'First-time activation considered as renewal due to promo logic');

-- insert failed payment info
INSERT INTO failed_payments (
    payment_id, user_id, failure_reason, failure_code, retry_count, next_retry_date
) VALUES
(3, 3, 'Insufficient funds on card', 'ERR001', 1, '2025-06-22 10:00:00'),
(5, 5, 'Payment gateway timeout', 'ERR002', 2, '2025-06-21 15:30:00'),
(8, 8, 'Card declined by issuer', 'ERR003', 0, '2025-06-22 09:00:00');

-- insert discount info
INSERT INTO coupons (
    coupon_code, description, discount_value,
    valid_from, valid_until, usage_limit, used_count, status
) VALUES
('WELCOME10', '10% off on your first subscription', 10.00, '2025-06-01', '2025-12-31', 1, 0, 'active'),
('SUMMER25', 'Flat ₹25 off for summer plans', 25.00, '2025-06-01', '2025-06-30', 100, 45, 'active'),
('FREEMONTH', 'Free first month on yearly subscription', 59.99, '2025-01-01', '2025-12-31', 500, 400, 'active'),
('BLACKFRIDAY', 'Special discount on Black Friday', 50.00, '2024-11-25', '2024-11-30', 1000, 1000, 'expired'),
('LIMITED50', '₹50 off - limited usage', 50.00, '2025-05-01', '2025-05-10', 10, 10, 'expired'),
('INACTIVEDEAL', 'This coupon is currently not active', 30.00, '2025-06-01', '2025-07-01', 100, 0, 'inactive');

-- queries
-- QUERY 1 to Get all active users with their current subscription details
SELECT 
    u.user_id,
    u.name,
    u.email,
    us.subscription_id,
    us.start_date,
    us.end_date,
    sp.plan_name,
    sp.price,
    sp.billing_cycle
FROM users u
JOIN user_subscriptions us ON u.user_id = us.user_id
JOIN subscription_plans sp ON us.plan_id = sp.plan_id
WHERE u.status = 'active' AND us.status = 'active';

-- QUERY 2 Find users who have exceeded their usage limits
SELECT
    u.user_id,
    u.name,
    ut.usage_date,
    ut.api_calls_used,
    sp.api_calls_limit,
    ut.storage_used_gb,
    sp.storage_limit_gb
FROM usage_tracking ut
JOIN user_subscriptions us ON ut.subscription_id = us.subscription_id
JOIN subscription_plans sp ON us.plan_id = sp.plan_id
JOIN users u ON ut.user_id = u.user_id
WHERE 
    (ut.api_calls_used > sp.api_calls_limit)
    OR
    (ut.storage_used_gb > sp.storage_limit_gb);

-- Query 3: Get unpaid invoices with user details
SELECT 
    i.invoice_id,
    i.invoice_number,
    i.total_amount,
    i.due_date,
    u.name,
    i.status
FROM invoices i
JOIN users u ON i.user_id = u.user_id
WHERE i.status IN ('pending', 'overdue')
ORDER BY i.due_date ASC;

-- QUERY 4: Show subscription plan change history 
SELECT
    sh.history_id,
    u.user_id,
    u.name AS user_name,
    
    old_sp.plan_name AS old_plan,
    new_sp.plan_name AS new_plan,
    
    sh.change_type,
    sh.change_reason,
    sh.change_date
FROM subscription_history sh
JOIN users u ON sh.user_id = u.user_id
LEFT JOIN user_subscriptions old_us ON sh.old_subscription_id = old_us.subscription_id
LEFT JOIN user_subscriptions new_us ON sh.new_subscription_id = new_us.subscription_id
LEFT JOIN subscription_plans old_sp ON old_us.plan_id = old_sp.plan_id
LEFT JOIN subscription_plans new_sp ON new_us.plan_id = new_sp.plan_id
ORDER BY sh.change_date DESC; 

-- QUERY 5 FIND USERS WITH FAILED PAYMENTS
SELECT 
    u.user_id,
    u.name,
    u.email,
    fp.payment_id,
    fp.failure_reason,
    fp.failure_code,
    fp.retry_count,
    fp.failed_at
FROM failed_payments fp
JOIN users u ON fp.user_id = u.user_id
ORDER BY fp.failed_at DESC;



