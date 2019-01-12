DROP TABLE IF EXISTS suggestions;
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS employers;
DROP TABLE IF EXISTS vacancies;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS resumes;
DROP TABLE IF EXISTS applicants;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS profiles;



CREATE TABLE jobs
(
    job_id serial PRIMARY KEY,
    title varchar(500),
    city varchar(500),
    description varchar(5000) NOT NULL,
    salary int8range
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
    applicant_fk integer NOT NULL,
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



CREATE TABLE suggestions
(
    suggestion_id serial PRIMARY KEY,
    resume_fk integer NOT NULL,
    employer_fk integer NOT NULL,
    vacancy_fk integer NOT NULL,
    message varchar(2000),
    CONSTRAINT suggestion_resume_fk_fkey FOREIGN KEY (resume_fk)
        REFERENCES resumes (resume_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT suggestion_employer_fk_fkey FOREIGN KEY (employer_fk)
        REFERENCES employers (employer_id)  MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT suggestion_vacancy_fk_fkey  FOREIGN KEY (vacancy_fk)
        REFERENCES vacancies (vacancy_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE responses
(
    response_id serial PRIMARY KEY,
    vacancy_fk integer NOT NULL,
    appliсant_fk integer NOT NULL,
    message varchar(2000),
    CONSTRAINT responses_vacancy_fk_fkey  FOREIGN KEY (vacancy_fk)
        REFERENCES vacancies (vacancy_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT responses_appliсant_fk_fkey  FOREIGN KEY (appliсant_fk)
        REFERENCES applicants (applicant_id)  MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)