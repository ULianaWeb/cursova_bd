-- ��������� ���� �����
CREATE DATABASE projects_DW;

USE projects_DW;

-- ������� �����: ����������
CREATE TABLE dim_employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(255),
    position_id INT,
    qualification_id INT
);

-- ������� �����: ������
CREATE TABLE dim_position (
    position_id INT PRIMARY KEY,
    position_name VARCHAR(255),
    premium FLOAT
);

-- ������� �����: �����������
CREATE TABLE dim_qualification (
    qualification_id INT PRIMARY KEY,
    qualification_name VARCHAR(255),
    rate FLOAT
);

-- ������� �����: �������
CREATE TABLE dim_project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(255),
    difficulty VARCHAR(255),
    difficulty_coefficient FLOAT,
    customer_id INT,
    manager VARCHAR(255),
    start_date DATE,
    planned_duration INT
);

-- ������� �����: �볺���
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    balance FLOAT
);

CREATE TABLE dim_payment (
    payment_id INT PRIMARY KEY, -- ������� ��������� ����
    project_id INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES project(id),
    amount_due FLOAT NOT NULL CHECK (amount_due >= 0),
    paid_for FLOAT NOT NULL CHECK (paid_for >= 0),
    date DATE NOT NULL
);

-- ������� �����: ����
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    weekday_name VARCHAR(50)
);

-- ������� �����: ������ ������
CREATE TABLE fact_reports (
    report_id INT PRIMARY KEY,
    project_id INT,
    employee_id INT,
    date_id INT,
    hours_worked FLOAT,
    FOREIGN KEY (project_id) REFERENCES dim_project(project_id),
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- ������� �����: ������
CREATE TABLE fact_payments (
    payment_id INT PRIMARY KEY,
    project_id INT,
    date_id INT,
    amount_due FLOAT,
    paid_for FLOAT,
    FOREIGN KEY (project_id) REFERENCES dim_project(project_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

CREATE TABLE fact_employee (
    fact_id INT IDENTITY(1,1) PRIMARY KEY, -- ��������� ������������� ������
    employee_id INT NOT NULL,              -- ������������� ����������
    project_id INT NOT NULL,               -- ������������� �������
    position_id INT NOT NULL,              -- ������������� ������
    qualification_id INT NOT NULL,         -- ������������� �����������
    date_id INT NOT NULL,                  -- ������������� ����
    hours_worked FLOAT NOT NULL,           -- ³���������� ������
    total_payment FLOAT NOT NULL,          -- �������� ������ �����
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id), -- ������ �� ������ ����������
    FOREIGN KEY (project_id) REFERENCES dim_project(project_id),    -- ������ �� ������ �������
    FOREIGN KEY (position_id) REFERENCES dim_position(position_id), -- ������ �� ������ �����
    FOREIGN KEY (qualification_id) REFERENCES dim_qualification(qualification_id), -- ������ �� ������ �����������
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)              -- ������ �� ������ ���
);
