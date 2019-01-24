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
    tmp_job_id SERIAL PRIMARY KEY,
    title VARCHAR(500),
    city VARCHAR(500),
    description VARCHAR(5000) NOT NULL,
    salary INT8RANGE
);

COMMENT ON TABLE tmp_job
    IS 'Таблица описания работы';



CREATE TABLE tmp_company
(
    tmp_company_id SERIAL PRIMARY KEY,
    name VARCHAR(500) NOT NULL
);

COMMENT ON TABLE tmp_company
    IS 'Таблица компаний, от лица которых работодатель размещает вакансию.';



CREATE TABLE tmp_vacancy
(
    tmp_vacancy_id SERIAL PRIMARY KEY,
    active BOOLEAN NOT NULL, -- add active to tmp_vacancy/tmp_resume and not to tmp_job because it is not a tmp_job property according to domain
    tmp_company_id INTEGER NOT NULL REFERENCES tmp_company (tmp_company_id),
    tmp_job_id INTEGER REFERENCES tmp_job (tmp_job_id)
);

COMMENT ON TABLE tmp_vacancy
    IS 'Таблица вакансий, размещенных компаниями.';



CREATE TABLE tmp_account
(
    tmp_account_id SERIAL PRIMARY KEY,
    login VARCHAR(500) UNIQUE NOT NULL,
    password VARCHAR(500) NOT NULL,
    first_name VARCHAR(500) NOT NULL,
    family_name VARCHAR(500) NOT NULL,
    contact_email VARCHAR(500),
    contact_phone BIGINT
);

COMMENT ON TABLE tmp_account
    IS 'Таблица пользователей, которые могут залогиниться на сайт.';



CREATE TABLE tmp_applicant
(
    tmp_applicant_id SERIAL PRIMARY KEY,
    tmp_account_id INTEGER UNIQUE NOT NULL REFERENCES tmp_account (tmp_account_id)
);

COMMENT ON TABLE tmp_applicant
    IS 'Таблица соискателей, которые могут создавать резюме.';



CREATE TABLE tmp_resume
(
    tmp_resume_id SERIAL PRIMARY KEY,
    active BOOLEAN NOT NULL, -- add active to tmp_vacancy/tmp_resume and not to tmp_job because it is not a tmp_job property according to domain
    tmp_applicant_id INTEGER NOT NULL REFERENCES tmp_applicant (tmp_applicant_id),
    tmp_job_id INTEGER REFERENCES tmp_job (tmp_job_id)
);

COMMENT ON TABLE tmp_resume
    IS 'Таблица резюме, которые создаются соискателями.';



CREATE TABLE tmp_hr_manager
(
    tmp_hr_manager_id SERIAL PRIMARY KEY,
    tmp_account_id INTEGER UNIQUE NOT NULL REFERENCES tmp_account (tmp_account_id),
    tmp_company_id INTEGER REFERENCES tmp_company (tmp_company_id)
);

COMMENT ON TABLE tmp_hr_manager
    IS 'Таблица hr менеджеров компаний, которые могут размещать вакансии.';



CREATE TABLE tmp_message
(
    tmp_message_id SERIAL PRIMARY KEY,
    send TIMESTAMP NOT NULL,
    tmp_account_id INTEGER NOT NULL REFERENCES tmp_account (tmp_account_id),
    tmp_vacancy_id INTEGER NOT NULL REFERENCES tmp_vacancy (tmp_vacancy_id),
    tmp_resume_id INTEGER NOT NULL REFERENCES tmp_resume (tmp_resume_id),
    text VARCHAR(5000) NOT NULL
);

COMMENT ON TABLE  tmp_message
    IS 'Таблица сообщений по паре {вакансия,резюме}';



CREATE TABLE tmp_read_message
(
  tmp_read_message_id SERIAL PRIMARY KEY,
  tmp_message_id INTEGER NOT NULL REFERENCES tmp_message (tmp_message_id),
  tmp_account_id INTEGER NOT NULL REFERENCES tmp_account (tmp_account_id),
  UNIQUE (tmp_message_id, tmp_account_id)
);

COMMENT ON TABLE  tmp_read_message
    IS 'Таблица отношения прочитанности сообщения пользователем';

