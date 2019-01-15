-- Зарегистрироваться
WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('elon@musk.com', 'hash(password+salt) to be here', 'Elon', 'Musk', null, null)
        RETURNING account_id
   )
INSERT INTO applicant (account_id)
SELECT account_id FROM insert_account;



-- Залогиниться
SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'elon@musk.com';



-- Отредактировать личные данные
UPDATE account SET
    first_name = 'Илон',
    family_name = 'Маск',
    contact_email = 'e.musk@spacex.com',
    contact_phone = 2342355678
WHERE account_id = 7;



-- Посмотреть личные данные
SELECT first_name, family_name, contact_email, contact_phone FROM account
WHERE account_id = 7;



-- Создать резюме
WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity.',
                '[300000, 400000]')
        RETURNING job_id
   )
INSERT INTO resume (job_id, applicant_id, active)
SELECT job_id, 4, TRUE
FROM insert_job;



-- Посмотреть свои резюме
SELECT active, resume_id, first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM job
    JOIN resume USING (job_id)
    JOIN applicant USING (applicant_id)
    JOIN account USING (account_id)
WHERE account_id = 7;



-- Деактивировать резюме #3
UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;



-- Редактировать резюме #3
UPDATE job SET
    salary = '[430000, 520000]'
WHERE job_id = (SELECT job_id FROM resume WHERE resume_id = 3) ;



-- Активировать обратно резюме #3
UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;



-- Удалить резюме
WITH delete_resume AS (
    DELETE FROM resume WHERE resume_id = 3
    RETURNING job_id
    )
DELETE FROM job
USING delete_resume
WHERE job.job_id = delete_resume.job_id;



-- Вернем резюме обратно
WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity до её слияния с Tesla.',
                '[400000, 500000]')
        RETURNING job_id
   )
INSERT INTO resume (job_id, applicant_id, active)
SELECT job_id, 4, TRUE
FROM insert_job;



-- Посмотреть все вакансии
SELECT name, title, city, description,salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE active;



-- Поиск активных вакансий по городу и названию и чтоб платили много
SELECT name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE '%Инженер%' AND salary && '[600000,]' AND active;



-- Написать сообщение
INSERT INTO message (account_id, vacancy_id, resume_id, text)
VALUES (7, 5, 4, 'Здравствуйте, меня заинтересовала вакансия инженера ЦПИР в Москве, я монго работал над созданием очень сложных систем управления для космической техники.');



-- Пришел ответ от hr менеджера
INSERT INTO message (account_id, vacancy_id, resume_id, text)
VALUES (6, 5, 4, 'Здравствуйте, приглашаем Вас на собеседование в четверг 15.05 в 16:30.');



-- Посмотреть диалог по резюме 4
SELECT job.title, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
JOIN job on resume.job_id = job.job_id
WHERE resume_id = 4;
