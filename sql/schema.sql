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

DROP TABLE IF EXISTS users;
DROP SEQUENCE IF EXISTS users_user_id_seq;
CREATE SEQUENCE users_user_id_seq;
CREATE TABLE users
(
    user_id integer NOT NULL DEFAULT nextval('users_user_id_seq'),
    email character varying(500)[] NOT NULL,
    password character varying(500)[] NOT NULL,
    CONSTRAINT users_user_id_pkey PRIMARY KEY (user_id)
);

COMMENT ON TABLE users
    IS 'Таблица пользователей, которые могут залогиниться на сайт.';


DROP TABLE IF EXISTS applicants;
DROP SEQUENCE IF EXISTS applicants_applicant_id_seq;
CREATE SEQUENCE applicants_applicant_id_seq;
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


DROP TABLE IF EXISTS companies;
DROP SEQUENCE IF EXISTS companies_company_id_seq;
CREATE SEQUENCE companies_company_id_seq;
CREATE TABLE companies
(
    company_id integer NOT NULL DEFAULT nextval('companies_company_id_seq'),
    CONSTRAINT companies_company_id_pkey PRIMARY KEY (company_id)
);

COMMENT ON TABLE companies
    IS 'Таблица компаний, от лица которых работодатель размещает вакансию.';


DROP TABLE IF EXISTS employers;
DROP SEQUENCE IF EXISTS employers_employer_id_seq;
CREATE SEQUENCE employers_employer_id_seq;
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

COMMENT ON TABLE companies
    IS 'Таблица работодателей, которые могут размещать вакансии.';

