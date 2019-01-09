CREATE DATABASE bestjobs
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;


COMMENT ON DATABASE bestjobs
    IS 'База данных для моего стартапа. Как HeadHunter, только лучше. В рамках домашнего задания в школе HeadHunter по базам данных.';

