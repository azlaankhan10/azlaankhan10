-- Personal Expense Tracker Management System
-- Schema and Sample Data Script

-- -----------------------------------------------------
-- Setup and Cleanup
-- -----------------------------------------------------
DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- -----------------------------------------------------
-- 1. USERS TABLE
-- Stores registered user profile and authentication data
-- -----------------------------------------------------
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 2. CATEGORIES TABLE
-- Stores custom income and expense categories per user
-- -----------------------------------------------------
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    category_name VARCHAR(50) NOT NULL,
    category_type VARCHAR(10) CHECK (category_type IN ('Income', 'Expense')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 3. TRANSACTIONS TABLE
-- Stores financial transactions linked to users and categories
-- -----------------------------------------------------
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    transaction_type VARCHAR(10) CHECK (transaction_type IN ('Income', 'Expense')) NOT NULL,
    transaction_date DATE DEFAULT CURRENT_DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 4. BUDGETS TABLE
-- Tracks monthly spending limits per category per user
-- -----------------------------------------------------
CREATE TABLE budgets (
    budget_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
    monthly_limit NUMERIC(12, 2) NOT NULL CHECK (monthly_limit > 0),
    month_year VARCHAR(7) NOT NULL, -- Format: 'YYYY-MM'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_category_month UNIQUE (user_id, category_id, month_year)
);

-- -----------------------------------------------------
-- SAMPLE SEED DATA
-- -----------------------------------------------------
INSERT INTO users (full_name, email, password_hash) 
VALUES ('Alex Morgan', 'alex@example.com', 'hashed_password_123');

INSERT INTO categories (user_id, category_name, category_type) VALUES 
(1, 'Salary', 'Income'),
(1, 'Groceries', 'Expense'),
(1, 'Rent', 'Expense'),
(1, 'Entertainment', 'Expense');

INSERT INTO transactions (user_id, category_id, amount, transaction_type, transaction_date, notes) VALUES 
(1, 1, 5000.00, 'Income', '2026-11-01', 'Monthly Salary'),
(1, 2, 150.50, 'Expense', '2026-11-02', 'Supermarket run'),
(1, 3, 1200.00, 'Expense', '2026-11-03', 'Apartment rent');

INSERT INTO budgets (user_id, category_id, monthly_limit, month_year) VALUES 
(1, 2, 600.00, '2026-11'),
(1, 4, 200.00, '2026-11');
