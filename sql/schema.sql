DROP TABLE IF EXISTS suggestion;
DROP TABLE IF EXISTS response;
DROP TABLE IF EXISTS employer;
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
    company_fk integer NOT NULL,
    job_fk integer,
    CONSTRAINT vacancy_company_fk_fkey FOREIGN KEY (company_fk)
        REFERENCES company (company_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT vacancy_job_fk_fkey FOREIGN KEY (job_fk)
        REFERENCES job (job_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
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
    account_fk integer UNIQUE NOT NULL,
    CONSTRAINT applicant_account_fk_fkey FOREIGN KEY (account_fk)
        REFERENCES account (account_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE applicant
    IS 'Таблица соискателей, которые могут создавать резюме.';



CREATE TABLE resume
(
    resume_id serial PRIMARY KEY,
    applicant_fk integer NOT NULL,
    job_fk integer,
    CONSTRAINT resume_resume_fk_fkey FOREIGN KEY (applicant_fk)
        REFERENCES applicant (applicant_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT resume_job_fk_fkey FOREIGN KEY (job_fk)
        REFERENCES job (job_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE resume
    IS 'Таблица резюме, которые создаются соискателями.';



CREATE TABLE employer
(
    employer_id serial PRIMARY KEY,
    account_fk integer UNIQUE NOT NULL,
    company_fk integer,
    CONSTRAINT employer_account_fk_fkey FOREIGN KEY (account_fk)
        REFERENCES account (account_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT employer_company_fk_fkey FOREIGN KEY (company_fk)
        REFERENCES company (company_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE employer
    IS 'Таблица работодателей, которые могут размещать вакансии.';



CREATE TABLE suggestion
(
    suggestion_id serial PRIMARY KEY,
    resume_fk integer NOT NULL,
    employer_fk integer NOT NULL,
    vacancy_fk integer NOT NULL,
    message varchar(2000),
    CONSTRAINT suggestion_resume_fk_fkey FOREIGN KEY (resume_fk)
        REFERENCES resume (resume_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT suggestion_employer_fk_fkey FOREIGN KEY (employer_fk)
        REFERENCES employer (employer_id)  MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT suggestion_vacancy_fk_fkey  FOREIGN KEY (vacancy_fk)
        REFERENCES vacancy (vacancy_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE response
(
    response_id serial PRIMARY KEY,
    vacancy_fk integer NOT NULL,
    appliсant_fk integer NOT NULL,
    message varchar(2000),
    CONSTRAINT response_vacancy_fk_fkey  FOREIGN KEY (vacancy_fk)
        REFERENCES vacancy (vacancy_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT response_appliсant_fk_fkey  FOREIGN KEY (appliсant_fk)
        REFERENCES applicant (applicant_id)  MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)