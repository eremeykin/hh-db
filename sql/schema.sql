DROP TABLE IF EXISTS employers;
DROP TABLE IF EXISTS vacancies;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS resumes;
DROP TABLE IF EXISTS applicants;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS profiles;



CREATE TABLE locations(
    location_id serial PRIMARY KEY,
    country  varchar(500) NOT NULL,
    region   varchar(500) NOT NULL,
    city     varchar(500) NOT NULL,
    district varchar(500)
);

COMMENT ON TABLE locations
    IS 'Таблица локаций.';



CREATE TABLE jobs
(
    job_id serial PRIMARY KEY,
    location_fk integer,
    salary int8range,
    CONSTRAINT jobs_location_fk_fkey FOREIGN KEY (location_fk)
        REFERENCES locations (location_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE jobs
    IS 'Таблица описания работы';



CREATE TABLE companies
(
    company_id serial PRIMARY KEY,
    name varchar(500) NOT NULL
);

COMMENT ON TABLE companies
    IS 'Таблица компаний, от лица которых работодатель размещает вакансию.';



CREATE TABLE vacancies
(
    vacancy_id serial PRIMARY KEY,
    company_fk integer NOT NULL,
    job_fk integer,
    CONSTRAINT vacancies_company_fk_fkey FOREIGN KEY (company_fk)
        REFERENCES companies (company_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT vacancies_job_fk_fkey FOREIGN KEY (job_fk)
        REFERENCES jobs (job_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE vacancies
    IS 'Таблица вакансий, размещенных компаниями.';



CREATE TABLE users
(
    user_id serial PRIMARY KEY,
    login varchar(500) UNIQUE NOT NULL,
    password varchar(500) NOT NULL,
    first_name varchar(500) NOT NULL,
    family_name varchar(500) NOT NULL,
    patronymic varchar(500),
    contact_email varchar(500),
    contact_phone bigint
);

COMMENT ON TABLE users
    IS 'Таблица пользователей, которые могут залогиниться на сайт.';



CREATE TABLE applicants
(
    applicant_id serial PRIMARY KEY,
    user_fk integer UNIQUE NOT NULL,
    CONSTRAINT applicants_user_fk_fkey FOREIGN KEY (user_fk)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE applicants
    IS 'Таблица соискателей, которые могут создавать резюме.';



CREATE TABLE resumes
(
    resume_id serial PRIMARY KEY,
    applicant_fk integer UNIQUE NOT NULL,
    job_fk integer,
    CONSTRAINT resumes_resume_fk_fkey FOREIGN KEY (applicant_fk)
        REFERENCES applicants (applicant_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT resumes_job_fk_fkey FOREIGN KEY (job_fk)
        REFERENCES jobs (job_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE resumes
    IS 'Таблица резюме, которые создаются соискателями.';



CREATE TABLE employers
(
    employer_id serial PRIMARY KEY,
    user_fk integer UNIQUE NOT NULL,
    company_fk integer NOT NULL,
    CONSTRAINT employer_user_fk_fkey FOREIGN KEY (user_fk)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT employer_company_fk_fkey FOREIGN KEY (company_fk)
        REFERENCES companies (company_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE employers
    IS 'Таблица работодателей, которые могут размещать вакансии.';
