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
    job_id serial PRIMARY KEY,
    title varchar(500),
    city varchar(500),
    description varchar(5000) NOT NULL,
    salary int8range
);

COMMENT ON TABLE job
    IS 'Таблица описания работы';



CREATE TABLE company
(
    company_id serial PRIMARY KEY,
    name varchar(500) NOT NULL
);

COMMENT ON TABLE company
    IS 'Таблица компаний, от лица которых работодатель размещает вакансию.';



CREATE TABLE vacancy
(
    vacancy_id serial PRIMARY KEY,
    company_id integer NOT NULL REFERENCES company (company_id),
    job_id integer REFERENCES job (job_id)
);

COMMENT ON TABLE vacancy
    IS 'Таблица вакансий, размещенных компаниями.';



CREATE TABLE account
(
    account_id serial PRIMARY KEY,
    login varchar(500) UNIQUE NOT NULL,
    password varchar(500) NOT NULL,
    first_name varchar(500) NOT NULL,
    family_name varchar(500) NOT NULL,
    contact_email varchar(500),
    contact_phone bigint
);

COMMENT ON TABLE account
    IS 'Таблица пользователей, которые могут залогиниться на сайт.';



CREATE TABLE applicant
(
    applicant_id serial PRIMARY KEY,
    account_id integer UNIQUE NOT NULL REFERENCES account (account_id)
);

COMMENT ON TABLE applicant
    IS 'Таблица соискателей, которые могут создавать резюме.';



CREATE TABLE resume
(
    resume_id serial PRIMARY KEY,
    applicant_id integer NOT NULL REFERENCES applicant (applicant_id),
    job_id integer REFERENCES job (job_id)
);

COMMENT ON TABLE resume
    IS 'Таблица резюме, которые создаются соискателями.';



CREATE TABLE hr_manager
(
    hr_manager_id serial PRIMARY KEY,
    account_id integer UNIQUE NOT NULL REFERENCES account (account_id),
    company_id integer REFERENCES company (company_id)
);

COMMENT ON TABLE hr_manager
    IS 'Таблица hr менеджеров компаний, которые могут размещать вакансии.';

CREATE TABLE message
(
    message_id serial PRIMARY KEY,
    account_id integer NOT NULL REFERENCES account (account_id),
    vacancy_id integer NOT NULL REFERENCES vacancy (vacancy_id),
    resume_id integer NOT NULL REFERENCES resume (resume_id),
    text varchar(5000) NOT NULL
);

COMMENT ON TABLE  message
    IS 'Таблица сообщений по паре {вакансия,резюме}';
