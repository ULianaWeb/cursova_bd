-- Створення бази даних
CREATE DATABASE projects_DW;

USE projects_DW;

-- Таблиця вимірів: Працівники
CREATE TABLE dim_employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(255),
    position_id INT,
    qualification_id INT
);

-- Таблиця вимірів: Посади
CREATE TABLE dim_position (
    position_id INT PRIMARY KEY,
    position_name VARCHAR(255),
    premium FLOAT
);

-- Таблиця вимірів: Кваліфікації
CREATE TABLE dim_qualification (
    qualification_id INT PRIMARY KEY,
    qualification_name VARCHAR(255),
    rate FLOAT
);

-- Таблиця вимірів: Проекти
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

-- Таблиця вимірів: Клієнти
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(255),
    balance FLOAT
);

CREATE TABLE dim_payment (
    payment_id INT PRIMARY KEY, -- Доданий первинний ключ
    project_id INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES project(id),
    amount_due FLOAT NOT NULL CHECK (amount_due >= 0),
    paid_for FLOAT NOT NULL CHECK (paid_for >= 0),
    date DATE NOT NULL
);

-- Таблиця вимірів: Дати
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    year INT,
    weekday_name VARCHAR(50)
);

-- Таблиця фактів: Години роботи
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

-- Таблиця фактів: Платежі
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
    fact_id INT IDENTITY(1,1) PRIMARY KEY, -- Унікальний ідентифікатор запису
    employee_id INT NOT NULL,              -- Ідентифікатор працівника
    project_id INT NOT NULL,               -- Ідентифікатор проекту
    position_id INT NOT NULL,              -- Ідентифікатор посади
    qualification_id INT NOT NULL,         -- Ідентифікатор кваліфікації
    date_id INT NOT NULL,                  -- Ідентифікатор дати
    hours_worked FLOAT NOT NULL,           -- Відпрацьовані години
    total_payment FLOAT NOT NULL,          -- Загальна оплата праці
    FOREIGN KEY (employee_id) REFERENCES dim_employee(employee_id), -- Зв’язок із виміром працівників
    FOREIGN KEY (project_id) REFERENCES dim_project(project_id),    -- Зв’язок із виміром проектів
    FOREIGN KEY (position_id) REFERENCES dim_position(position_id), -- Зв’язок із виміром посад
    FOREIGN KEY (qualification_id) REFERENCES dim_qualification(qualification_id), -- Зв’язок із виміром кваліфікацій
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)              -- Зв’язок із виміром дат
);
