CREATE DATABASE bestjobs
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;


COMMENT ON DATABASE bestjobs
    IS 'Как HeadHunter, только немного лучше (ДЗ по базам данных)';

