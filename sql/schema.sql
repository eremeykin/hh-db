DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS hr_manager;
DROP TABLE IF EXISTS vacancy;
DROP TABLE IF EXISTS company;
DROP TABLE IF EXISTS resume;
DROP TABLE IF EXISTS applicant;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS job;



CREATE TABLE job
(
    job_id SERIAL PRIMARY KEY,
    title VARCHAR(500),
    city VARCHAR(500),
    description VARCHAR(5000) NOT NULL,
    salary INT8RANGE
);

COMMENT ON TABLE job
    IS 'Таблица описания работы';



CREATE TABLE company
(
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(500) NOT NULL
);

COMMENT ON TABLE company
    IS 'Таблица компаний, от лица которых работодатель размещает вакансию.';



CREATE TABLE vacancy
(
    vacancy_id SERIAL PRIMARY KEY,
    company_id INTEGER NOT NULL REFERENCES company (company_id),
    job_id INTEGER REFERENCES job (job_id)
);

COMMENT ON TABLE vacancy
    IS 'Таблица вакансий, размещенных компаниями.';



CREATE TABLE account
(
    account_id SERIAL PRIMARY KEY,
    login VARCHAR(500) UNIQUE NOT NULL,
    password VARCHAR(500) NOT NULL,
    first_name VARCHAR(500) NOT NULL,
    family_name VARCHAR(500) NOT NULL,
    contact_email VARCHAR(500),
    contact_phone BIGINT
);

COMMENT ON TABLE account
    IS 'Таблица пользователей, которые могут залогиниться на сайт.';



CREATE TABLE applicant
(
    applicant_id SERIAL PRIMARY KEY,
    account_id INTEGER UNIQUE NOT NULL REFERENCES account (account_id)
);

COMMENT ON TABLE applicant
    IS 'Таблица соискателей, которые могут создавать резюме.';



CREATE TABLE resume
(
    resume_id SERIAL PRIMARY KEY,
    applicant_id INTEGER NOT NULL REFERENCES applicant (applicant_id),
    job_id INTEGER REFERENCES job (job_id)
);

COMMENT ON TABLE resume
    IS 'Таблица резюме, которые создаются соискателями.';



CREATE TABLE hr_manager
(
    hr_manager_id SERIAL PRIMARY KEY,
    account_id INTEGER UNIQUE NOT NULL REFERENCES account (account_id),
    company_id INTEGER REFERENCES company (company_id)
);

COMMENT ON TABLE hr_manager
    IS 'Таблица hr менеджеров компаний, которые могут размещать вакансии.';

CREATE TABLE message
(
    message_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account (account_id),
    vacancy_id INTEGER NOT NULL REFERENCES vacancy (vacancy_id),
    resume_id INTEGER NOT NULL REFERENCES resume (resume_id),
    text VARCHAR(5000) NOT NULL
);

COMMENT ON TABLE  message
    IS 'Таблица сообщений по паре {вакансия,резюме}';
