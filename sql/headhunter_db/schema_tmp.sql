DROP TABLE IF EXISTS tmp_read_message;
DROP TABLE IF EXISTS tmp_message;
DROP TABLE IF EXISTS tmp_hr_manager;
DROP TABLE IF EXISTS tmp_vacancy;
DROP TABLE IF EXISTS tmp_company;
DROP TABLE IF EXISTS tmp_resume;
DROP TABLE IF EXISTS tmp_applicant;
DROP TABLE IF EXISTS tmp_account;
DROP TABLE IF EXISTS tmp_job;


CREATE TABLE tmp_job
(
    job_id SERIAL,
    title VARCHAR(500),
    city VARCHAR(500),
    description VARCHAR(5000),
    salary INT8RANGE
);

CREATE TABLE tmp_company
(
    company_id SERIAL,
    name VARCHAR(500)
);

CREATE TABLE tmp_vacancy
(
    vacancy_id SERIAL,
    active BOOLEAN,
    company_id INTEGER,
    job_id INTEGER
);

CREATE TABLE tmp_account
(
    account_id SERIAL,
    login VARCHAR(500),
    password VARCHAR(500),
    first_name VARCHAR(500),
    family_name VARCHAR(500),
    contact_email VARCHAR(500),
    contact_phone BIGINT
);

CREATE TABLE tmp_applicant
(
    applicant_id SERIAL,
    account_id INTEGER
);

CREATE TABLE tmp_resume
(
    resume_id SERIAL,
    active BOOLEAN,
    applicant_id INTEGER,
    job_id INTEGER
);

CREATE TABLE tmp_hr_manager
(
    hr_manager_id SERIAL,
    account_id INTEGER,
    company_id INTEGER
);

CREATE TABLE tmp_message
(
    message_id SERIAL,
    send TIMESTAMP,
    account_id INTEGER,
    vacancy_id INTEGER,
    resume_id INTEGER,
    text VARCHAR(5000)
);

CREATE TABLE tmp_read_message
(
  read_message_id SERIAL,
  message_id INTEGER,
  account_id INTEGER
);

