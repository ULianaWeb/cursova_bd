-- ��������� ���� �����
CREATE DATABASE projects_curse;

USE projects_curse

-- ������� �������� ��������� �������
CREATE TABLE difficulty (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    coefficient FLOAT NOT NULL CHECK (coefficient > 0)
);

-- ������� �볺���
CREATE TABLE customer (
    id INT IDENTITY (1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    balance FLOAT NOT NULL CHECK (balance >= 0)
);

-- ������� �������
CREATE TABLE project (
    id INT IDENTITY(1,1) PRIMARY KEY,
    difficulty_id INT NOT NULL,
    FOREIGN KEY (difficulty_id) REFERENCES difficulty(id),
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(id),
    name VARCHAR(255) NOT NULL,
    manager VARCHAR(255) NOT NULL,
    planned_duration INT NOT NULL CHECK (planned_duration > 0),
    start_date DATE NOT NULL,
    overhead FLOAT NOT NULL DEFAULT 0.4 -- ������� ������� (40% �� �������� �������),
);

-- ������� ������� �� ��������
CREATE TABLE payment (
    id INT IDENTITY(1,1) PRIMARY KEY, -- ������� ��������� ����
    project_id INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES project(id),
    amount_due FLOAT NOT NULL CHECK (amount_due >= 0),
    paid_for FLOAT NOT NULL CHECK (paid_for >= 0),
    date DATE NOT NULL
);

-- ������� ����� ����������
CREATE TABLE position (
    id INT IDENTITY (1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    premium FLOAT NOT NULL CHECK (premium > 0)
);

-- ������� ����������� ����������
CREATE TABLE qualification (
    id INT IDENTITY (1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    rate FLOAT NOT NULL CHECK (rate > 0)
);

-- ������� ����������
CREATE TABLE employee (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    position_id INT NOT NULL,
    FOREIGN KEY (position_id) REFERENCES position(id),
    qualification_id INT NOT NULL,
    FOREIGN KEY (qualification_id) REFERENCES qualification(id)
);

-- ������� �������� �����
CREATE TABLE salary (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employee(id),
    salary_month DATE NOT NULL, -- ������ ������� ��� ����� �������
    amount FLOAT NOT NULL CHECK (amount >= 0)
);

-- ������� ���� ��� �������� ������
CREATE TABLE report (
    id INT IDENTITY(1,1) PRIMARY KEY, -- ������� ��������� ����
    employee_id INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employee(id),
    project_id INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES project(id),
    report_date DATE NOT NULL,
    hours_worked TINYINT NOT NULL CHECK (hours_worked >= 0 AND hours_worked <= 10), -- ��������� �� 10 �����
    description VARCHAR(1000) -- ������ ���� �������� ������
);

-- ������� ������� �������
CREATE TABLE project_status (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE -- ���������: "active", "completed", "on-hold"
);

-- ��������� ������� �� �������
ALTER TABLE project
ADD status_id INT DEFAULT 1, -- ������ �� �������������: "active"
FOREIGN KEY (status_id) REFERENCES project_status(id);



-- ����������� ������� �������
INSERT INTO project_status (name) VALUES ('active'), ('completed'), ('on-hold');

-- ��������� ��������� �� �������� ��������� ������� ��� ��������
CREATE TRIGGER trg_check_customer_balance
ON project
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @customer_id INT;
    SELECT @customer_id = customer_id FROM inserted;

    IF EXISTS (
        SELECT 1 FROM customer
        WHERE id = @customer_id AND balance < 0
    )
    BEGIN
        RAISERROR('Customer has outstanding balance and cannot start a new project.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO project (difficulty_id, customer_id, name, manager, planned_duration, start_date, status_id)
        SELECT difficulty_id, customer_id, name, manager, planned_duration, start_date, status_id FROM inserted;
    END
END;
