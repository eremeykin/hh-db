-- index naming convention: {tablename}_{columnname(s)}_{suffix}
-- (https://stackoverflow.com/questions/4107915/postgresql-default-constraint-names)
-- suffix:
-- pkey for a Primary Key constraint
-- key for a Unique constraint
-- excl for an Exclusion constraint
-- idx for any other kind of index
-- fkey for a Foreign key
-- check for a Check constraint
-- seq for all sequences

-- my own conventions:
-- colname_id => PRIMARY KEY
-- colname_fk => FOREIGN KEY

DROP TABLE IF EXISTS employers;
DROP TABLE IF EXISTS vacancies;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS resumes;
DROP TABLE IF EXISTS applicants;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS job_properties;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS job_types;
DROP TABLE IF EXISTS salary_ranges;

DROP SEQUENCE IF EXISTS employers_employer_id_seq;
DROP SEQUENCE IF EXISTS vacancies_vacancy_id_seq;
DROP SEQUENCE IF EXISTS companies_company_id_seq;
DROP SEQUENCE IF EXISTS resumes_resume_id_seq;
DROP SEQUENCE IF EXISTS applicants_applicant_id_seq;
DROP SEQUENCE IF EXISTS users_user_id_seq;
DROP SEQUENCE IF EXISTS job_properties_property_id_seq;
DROP SEQUENCE IF EXISTS locations_location_id_seq;
DROP SEQUENCE IF EXISTS job_types_type_id_seq;
DROP SEQUENCE IF EXISTS salary_ranges_range_id_seq;

CREATE SEQUENCE employers_employer_id_seq;
CREATE SEQUENCE vacancies_vacancy_id_seq;
CREATE SEQUENCE companies_company_id_seq;
CREATE SEQUENCE resumes_resume_id_seq;
CREATE SEQUENCE applicants_applicant_id_seq;
CREATE SEQUENCE users_user_id_seq;
CREATE SEQUENCE job_properties_property_id_seq;
CREATE SEQUENCE locations_location_id_seq;
CREATE SEQUENCE job_types_type_id_seq;
CREATE SEQUENCE salary_ranges_range_id_seq;


CREATE TABLE salary_ranges(
      range_id integer NOT NULL DEFAULT nextval('salary_ranges_range_id_seq'),
      value int8range NOT NULL,
      CONSTRAINT salary_ranges_range_id_pkey PRIMARY KEY (range_id)
);

COMMENT ON TABLE salary_ranges
    IS 'Таблица типов работы (полная,частичная занятость)';



CREATE TABLE job_types(
      type_id integer NOT NULL DEFAULT nextval('job_types_type_id_seq'),
      name character varying(500)[] NOT NULL,
      CONSTRAINT job_types_type_id_pkey PRIMARY KEY (type_id)
);

COMMENT ON TABLE job_types
    IS 'Таблица типов работы (полная,частичная занятость)';



CREATE TABLE locations(
    location_id integer NOT NULL DEFAULT nextval('locations_location_id_seq'),
    country  character varying(500)[] NOT NULL,
    region   character varying(500)[] NOT NULL,
    city     character varying(500)[] NOT NULL,
    district character varying(500)[],
    CONSTRAINT locations_location_id_pkey PRIMARY KEY (location_id)
);

COMMENT ON TABLE locations
    IS 'Таблица локаций, вкакнсий и резюме.';

CREATE TABLE job_properties
(
    property_id integer NOT NULL DEFAULT nextval('job_properties_property_id_seq'),
    location_fk integer,
    job_type_fk integer,
    salary_range_fk integer,
    CONSTRAINT job_properties_property_id_pkey PRIMARY KEY (property_id),
    CONSTRAINT job_properties_location_fk_fkey FOREIGN KEY (location_fk)
        REFERENCES locations (location_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT job_properties_job_type_fk_fkey FOREIGN KEY (job_type_fk)
        REFERENCES job_types (type_id)  MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT job_properties_salary_range_fk_fkey FOREIGN KEY (salary_range_fk)
        REFERENCES salary_ranges (range_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE companies
(
    company_id integer NOT NULL DEFAULT nextval('companies_company_id_seq'),
    CONSTRAINT companies_company_id_pkey PRIMARY KEY (company_id)
);

COMMENT ON TABLE companies
    IS 'Таблица компаний, от лица которых работодатель размещает вакансию.';



CREATE TABLE vacancies
(
    vacancy_id integer NOT NULL DEFAULT nextval('vacancies_vacancy_id_seq'),
    company_fk integer NOT NULL,
    job_property_fk integer,
    CONSTRAINT vacancies_vacancy_id_pkey PRIMARY KEY (vacancy_id),
    CONSTRAINT vacancies_company_fk_fkey FOREIGN KEY (company_fk)
        REFERENCES companies (company_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT vacancies_job_property_fk_fkey FOREIGN KEY (job_property_fk)
        REFERENCES job_properties (property_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE vacancies
    IS 'Таблица вакансий, размещенных компаниями.';



CREATE TABLE users
(
    user_id integer NOT NULL DEFAULT nextval('users_user_id_seq'),
    email character varying(500)[] NOT NULL,
    password character varying(500)[] NOT NULL,
    CONSTRAINT users_user_id_pkey PRIMARY KEY (user_id)
);

COMMENT ON TABLE users
    IS 'Таблица пользователей, которые могут залогиниться на сайт.';



CREATE TABLE applicants
(
    applicant_id integer NOT NULL DEFAULT nextval('applicants_applicant_id_seq'),
    user_fk integer UNIQUE NOT NULL,
    CONSTRAINT applicants_applicant_id_pkey PRIMARY KEY (applicant_id),
    CONSTRAINT applicants_user_fk_fkey FOREIGN KEY (user_fk)
        REFERENCES users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE applicants
    IS 'Таблица соискателей, которые могут создавать резюме.';



CREATE TABLE resumes
(
    resume_id integer NOT NULL DEFAULT nextval('resumes_resume_id_seq'),
    applicant_fk integer UNIQUE NOT NULL,
    job_property_fk integer,
    CONSTRAINT resumes_resume_id_pkey PRIMARY KEY (resume_id),
    CONSTRAINT resumes_resume_fk_fkey FOREIGN KEY (applicant_fk)
        REFERENCES applicants (applicant_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT resumes_job_property_fk_fkey FOREIGN KEY (job_property_fk)
        REFERENCES job_properties (property_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

COMMENT ON TABLE resumes
    IS 'Таблица резюме, которые создаются соискателями.';



CREATE TABLE employers
(
    employer_id integer NOT NULL DEFAULT nextval('employers_employer_id_seq'),
    user_fk integer UNIQUE NOT NULL,
    company_fk integer NOT NULL,
    CONSTRAINT employers_employer_id_pkey PRIMARY KEY (employer_id),
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
