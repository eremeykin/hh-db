DROP TABLE IF EXISTS map_read_message;
DROP TABLE IF EXISTS map_message;
DROP TABLE IF EXISTS map_hr_manager;
DROP TABLE IF EXISTS map_vacancy;
DROP TABLE IF EXISTS map_company;
DROP TABLE IF EXISTS map_resume;
DROP TABLE IF EXISTS map_applicant;
DROP TABLE IF EXISTS map_account;
DROP TABLE IF EXISTS map_job;


CREATE TABLE map_job
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('job_job_id_seq')
);

CREATE TABLE map_company
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('company_company_id_seq')
);

CREATE TABLE map_vacancy
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('vacancy_vacancy_id_seq')
);

CREATE TABLE map_account
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER DEFAULT NEXTVAL('account_account_id_seq')
);

CREATE TABLE map_applicant
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('applicant_applicant_id_seq')
);

CREATE TABLE map_resume
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('resume_resume_id_seq')
);

CREATE TABLE map_hr_manager
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('hr_manager_hr_manager_id_seq')
);

CREATE TABLE map_message
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('message_message_id_seq')
);

CREATE TABLE map_read_message
(
    map_id SERIAL PRIMARY KEY,
    old_id INTEGER,
    new_id INTEGER NOT NULL DEFAULT NEXTVAL('read_message_read_message_id_seq')
);
