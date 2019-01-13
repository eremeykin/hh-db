-- Зарегистрироваться
WITH insert_user AS (
        INSERT INTO users (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('kukushkin@hepi.ru', 'id6AWf3g', 'Руслан', 'Кукушкин', 'kukushkin@hepi.ru', 71354572398)
        RETURNING user_id
   )
INSERT INTO employers (user_fk)
SELECT user_id FROM insert_user;



-- Создать компанию
WITH insert_company AS (
        INSERT INTO companies (name)
        VALUES ('Институт физики высоких энергий')
        RETURNING company_id
    )
UPDATE employers SET
        company_fk = (SELECT company_id from insert_company)
WHERE user_fk = (SELECT user_id FROM users WHERE login = 'ruskuk@yandex.ru');



--Посмотреть компании
SELECT name, first_name, family_name, contact_email, contact_phone FROM companies
JOIN employers e on companies.company_id = e.company_fk
JOIN users u on e.user_fk = u.user_id;


--  Создать вакансию
WITH insert_job AS (
    INSERT INTO jobs (title, city, description, salary)
    VALUES ('Исследователь', 'Москва','Ищем исследователя для изучения явлений физики высоких энергий, имеющих применение в оборонной промышленности',
            '[240000, 260000]')
    RETURNING job_id
    )
INSERT INTO vacancies (company_fk, job_fk)
SELECT 4, job_id
FROM insert_job;


-- Посмотреть созданные вакансии
SELECT name, title, city, description, salary FROM vacancies
JOIN companies ON company_fk = company_id
JOIN employers ON companies.company_id = employers.company_fk
JOIN users ON user_fk = user_id
JOIN jobs ON vacancies.job_fk = jobs.job_id
WHERE login='ruskuk@yandex.ru';


