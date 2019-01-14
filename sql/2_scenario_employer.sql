-- Зарегистрироваться
WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('kukushkin@hepi.ru', 'id6AWf3g', 'Руслан', 'Кукушкин', 'kukushkin@hepi.ru', 71354572398)
        RETURNING account_id
   )
INSERT INTO employer (account_fk)
SELECT account_id FROM insert_account;



-- Создать компанию
WITH insert_company AS (
        INSERT INTO company (name)
        VALUES ('Институт физики высоких энергий')
        RETURNING company_id
    )
UPDATE employer SET
        company_fk = (SELECT company_id from insert_company)
WHERE account_fk = (SELECT account_id FROM account WHERE login = 'kukushkin@hepi.ru');



--Посмотреть компании
SELECT name, first_name, family_name, contact_email, contact_phone FROM company
JOIN employer e on company.company_id = e.company_fk
JOIN account u on e.account_fk = u.account_id;



--  Создать вакансию
WITH insert_job AS (
    INSERT INTO job (title, city, description, salary)
    VALUES ('Исследователь', 'Москва','Ищем исследователя для изучения явлений физики высоких энергий, имеющих применение в оборонной промышленности',
            '[240000, 260000]')
    RETURNING job_id
    )
INSERT INTO vacancy (company_fk, job_fk)
SELECT 4, job_id
FROM insert_job;


-- Посмотреть созданные вакансии
SELECT vacancy_id, name, title, city, description, salary FROM vacancy
JOIN company ON company_fk = company_id
JOIN employer ON company.company_id = employer.company_fk
JOIN account ON account_fk = account_id
JOIN job ON vacancy.job_fk = job.job_id
WHERE login='kukushkin@hepi.ru';



-- Посмотреть все резюме
SELECT first_name, family_name, contact_email, contact_phone, title, city, description FROM resumes
JOIN applicant ON applicant_fk = applicant_id
JOIN account ON account_fk = account_id
JOIN job ON job_fk = job_id;



-- Предложить вакансию соискателю
INSERT INTO suggestion (resume_fk, employer_fk, vacancy_fk, message)
VALUES (4, (SELECT employer_id FROM employer JOIN account ON account_fk = account_id WHERE login='kukushkin@hepi.ru'),
        6, 'Приглашаем Вас пройти собеседование! Контактный email: kukushkin@hepi.ru'
           );



-- Кто-то добавляет ответ на вакансию
INSERT INTO response (vacancy_fk, appliсant_fk, message)
VALUES (6, 4, 'Заинтересован вакансией исследователя в Вашем институте');



-- Посмотреть ответы на вакансию
SELECT message, title, name, first_name, family_name, contact_phone, contact_email FROM response
JOIN applicant ON appliсant_fk = applicant_id
JOIN account ON account_fk = account.account_id
JOIN vacancy ON vacancy_fk = vacancy_id
JOIN job ON job_fk = job_id
JOIN company ON company_fk = company_id
WHERE company_id = 4;
