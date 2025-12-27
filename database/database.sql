-- ==========================================================
-- PROJECT: CIMS (Crypto Investment Management System)
-- STATUS:  Phone Numbers Masked (Privacy Mode)
-- SYSTEM:  MySQL
-- ==========================================================

-- 1. SETUP DATABASE
CREATE DATABASE IF NOT EXISTS cims_db;
USE cims_db;

-- Reset System
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS discuss, assign, engage, complain, purchase, control, package, owner, customer, agent, manager, operator;
DROP VIEW IF EXISTS v12, v21, join1, join2;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- 2. CREATE ENTITIES
-- ==========================================================

CREATE TABLE operator (
    op_id INT PRIMARY KEY,
    op_name VARCHAR(50) NOT NULL,
    op_address VARCHAR(100),
    op_contact VARCHAR(50) NOT NULL
);

CREATE TABLE manager (
    m_id INT PRIMARY KEY,
    m_name VARCHAR(50) NOT NULL,
    m_phone VARCHAR(20) NOT NULL,
    m_sal DECIMAL(15, 2) DEFAULT 0.00
);

CREATE TABLE agent (
    a_id INT PRIMARY KEY,
    a_name VARCHAR(50) NOT NULL,
    a_phone VARCHAR(20),
    a_sal DECIMAL(15, 2) DEFAULT 0.00
);

CREATE TABLE customer (
    c_nid BIGINT PRIMARY KEY,
    c_name VARCHAR(50) NOT NULL,
    c_phone VARCHAR(20) NOT NULL,
    c_dob DATE,
    c_age INT,
    c_address VARCHAR(100)
);

CREATE TABLE owner (
    o_id INT PRIMARY KEY,
    o_name VARCHAR(50) NOT NULL,
    o_phone VARCHAR(20),
    o_type VARCHAR(50)
);

CREATE TABLE package (
    p_id INT PRIMARY KEY,
    p_name VARCHAR(50) NOT NULL,
    p_duration VARCHAR(50),
    p_invest DECIMAL(15, 2) NOT NULL,
    p_return DECIMAL(15, 2) NOT NULL
);

-- ==========================================================
-- 3. DEFINE RELATIONSHIPS
-- ==========================================================

CREATE TABLE control (
    p_id INT PRIMARY KEY,
    p_name VARCHAR(50),
    p_duration VARCHAR(50),
    p_invest DECIMAL(15, 2),
    p_return DECIMAL(15, 2),
    op_id INT,
    CONSTRAINT fk_control_op FOREIGN KEY (op_id) REFERENCES operator(op_id)
);

CREATE TABLE purchase (
    p_id INT PRIMARY KEY,
    c_nid BIGINT,
    CONSTRAINT fk_purchase_cust FOREIGN KEY (c_nid) REFERENCES customer(c_nid) ON DELETE CASCADE
);

CREATE TABLE complain (
    c_nid BIGINT PRIMARY KEY,
    a_id INT,
    CONSTRAINT fk_complain_agent FOREIGN KEY (a_id) REFERENCES agent(a_id)
);

CREATE TABLE engage (
    a_id INT PRIMARY KEY,
    m_id INT,
    CONSTRAINT fk_engage_mgr FOREIGN KEY (m_id) REFERENCES manager(m_id)
);

CREATE TABLE assign (
    op_id INT PRIMARY KEY,
    m_id INT,
    CONSTRAINT fk_assign_mgr FOREIGN KEY (m_id) REFERENCES manager(m_id)
);

CREATE TABLE discuss (
    o_id INT PRIMARY KEY,
    o_name VARCHAR(50),
    o_phone VARCHAR(20),
    o_type VARCHAR(50),
    m_id INT,
    CONSTRAINT fk_discuss_mgr FOREIGN KEY (m_id) REFERENCES manager(m_id)
);

-- ==========================================================
-- 4. INSERT DATA (With Masked Numbers)
-- ==========================================================

INSERT INTO operator VALUES 
(10213, 'LOGAN', 'DHAKA, BANGLADESH', 'logan@cims.op'),
(10386, 'CALUX', 'KHULNA, BANGLADESH', 'calux@cims.op'),
(10292, 'TOBI', 'CUMILLA, BANGLADESH', 'tobi@cims.op');

-- Managers (Phone numbers hidden)
INSERT INTO manager VALUES 
(3056, 'OISHI', '018********', 42000),
(3042, 'SADATH', '017********', 42000),
(3067, 'SULTANA', '019********', 44500),
(3084, 'TANVIR', '013********', 41000);

-- Agents (Phone numbers hidden)
INSERT INTO agent VALUES 
(2035, 'NAHID', '018********', 15000),
(2041, 'MILA', '017********', 12000),
(2044, 'NISHAT', '019********', 13000);

-- Customers (Phone numbers hidden)
INSERT INTO customer VALUES 
(47539, 'RAHAT', '017********', '1987-04-19', 36, 'DHANMONDI, DHAKA'),
(46632, 'REZA', '017********', '1993-11-23', 30, 'BANGLAMOTOR, DHAKA'),
(46853, 'SAMIUL', '013********', '1987-02-13', 37, 'BANANI, DHAKA'),
(47542, 'TAAZ', '018********', '1990-12-17', 33, 'GULSHAN2, DHAKA'),
(47541, 'RAHAT', '019********', '1999-12-19', 24, 'NIKUNJA2, DHAKA');

-- Owners (Phone numbers hidden)
INSERT INTO owner VALUES 
(1001, 'ARNOB', '017********', 'FOUNDER'),
(1002, 'FAISAL', '018********', 'CO-FOUNDER'),
(1003, 'FARDIN', '019********', 'CEO'),
(1004, 'BADHAN', '013********', 'COO');

INSERT INTO package VALUES 
(1011, 'SILVER', '30 DAYS', 25, 50),
(1012, 'GOLD', '90 DAYS', 150, 500),
(1013, 'PLATINUM', '120 DAYS', 250, 1000);

INSERT INTO control VALUES 
(1011, 'SILVER', '30 DAYS', 25, 50, 10213),
(1013, 'PLATINUM', '120 DAYS', 250, 1000, 10292),
(1012, 'GOLD', '90 DAYS', 150, 500, 10213);

INSERT INTO purchase VALUES 
(1011, 47539),
(1013, 46853),
(1012, 46632);

INSERT INTO complain VALUES 
(47542, 2041),
(46853, 2035),
(46632, 2044);

INSERT INTO engage VALUES 
(2041, 3056),
(2035, 3042),
(2044, 3067);

INSERT INTO assign VALUES 
(10386, 3067),
(10213, 3084),
(10292, 3056);

INSERT INTO discuss VALUES 
(1001, 'ARNOB', '017********', 'FOUNDER', 3056),
(1002, 'FAISAL', '018********', 'CO-FOUNDER', 3042),
(1003, 'FARDIN', '019********', 'CEO', 3067),
(1004, 'BADHAN', '013********', 'COO', 3084);

-- ==========================================================
-- 5. ANALYTICS VIEWS
-- ==========================================================

CREATE VIEW v12 AS 
SELECT a_name, a_id, a_sal FROM agent WHERE a_id = 2044;

CREATE VIEW v21 AS 
SELECT SUM(m_sal) AS summation_of_sal FROM manager;

CREATE VIEW join1 AS
SELECT c.p_name, c.p_id, p.p_invest, p.p_return
FROM control c, package p
WHERE c.p_id = p.p_id;

CREATE VIEW join2 AS
SELECT x.m_id, y.m_sal
FROM manager x, manager y
WHERE x.m_id = y.m_id;

-- ==========================================================
-- 6. FINAL CHECK
-- ==========================================================
SELECT * FROM customer;