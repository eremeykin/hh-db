DROP TABLE IF EXISTS read_message CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS hr_manager CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;
DROP TABLE IF EXISTS company CASCADE;
DROP TABLE IF EXISTS resume CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS job CASCADE;



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
    active BOOLEAN NOT NULL, -- add active to vacancy/resume and not to job because it is not a job property according to domain
    company_id INTEGER NOT NULL REFERENCES company (company_id),
    job_id INTEGER UNIQUE REFERENCES job (job_id)
);

COMMENT ON TABLE vacancy
    IS 'Таблица вакансий, размещенных компаниями.';



CREATE TABLE account
(
    account_id SERIAL PRIMARY KEY,
    login VARCHAR(500) UNIQUE NOT NULL,
    password VARCHAR(500),
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
    active BOOLEAN NOT NULL, -- add active to vacancy/resume and not to job because it is not a job property according to domain
    applicant_id INTEGER NOT NULL REFERENCES applicant (applicant_id),
    job_id INTEGER UNIQUE REFERENCES job (job_id)
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
    send TIMESTAMP NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account (account_id),
    vacancy_id INTEGER NOT NULL REFERENCES vacancy (vacancy_id),
    resume_id INTEGER NOT NULL REFERENCES resume (resume_id),
    text VARCHAR(5000) NOT NULL
);

COMMENT ON TABLE  message
    IS 'Таблица сообщений по паре {вакансия,резюме}';



CREATE TABLE read_message
(
  read_message_id SERIAL PRIMARY KEY,
  message_id INTEGER NOT NULL REFERENCES message (message_id),
  account_id INTEGER NOT NULL REFERENCES account (account_id),
  UNIQUE (message_id, account_id)
);

COMMENT ON TABLE  read_message
    IS 'Таблица отношения прочитанности сообщения пользователем';


CREATE INDEX message_resume_id_index ON message (resume_id);
CREATE INDEX message_vacancy_id_index ON message (vacancy_id);

CREATE INDEX resume_applicant_id_index ON resume (applicant_id);
CREATE INDEX resume_job_id_index ON resume (job_id);

CREATE INDEX vacancy_company_id_index ON vacancy (company_id);
CREATE INDEX vacancy_job_id_index ON vacancy (job_id);

CREATE INDEX hr_manager_company_index ON hr_manager (company_id);

CREATE INDEX job_city_index  ON job USING gin(to_tsvector('russian', city));
CREATE INDEX job_title_index  ON job USING gin(to_tsvector('russian', title));