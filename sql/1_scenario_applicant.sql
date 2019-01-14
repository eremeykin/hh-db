-- Зарегистрироваться
WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('elon@musk.com', 'hash(password+salt) to be here', 'Elon', 'Musk', null, null)
        RETURNING account_id
   )
INSERT INTO applicant (account_fk)
SELECT account_id FROM insert_account;



-- Залогиниться
SELECT password FROM account
WHERE login = 'elon@musk.com';



-- Отредактировать личные данные
UPDATE account SET
    first_name = 'Илон',
    family_name = 'Маск',
    contact_email = 'e.musk@spacex.com',
    contact_phone = 2342355678
WHERE login = 'elon@musk.com';



-- Посмотреть личные данные
SELECT first_name, family_name, contact_email, contact_phone FROM account
WHERE login = 'elon@musk.com';



-- Создать резюме
WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity.',
                '[300000, 400000]')
        RETURNING job_id
   )
INSERT INTO resume (job_fk, applicant_fk)
SELECT job_id, (
                SELECT applicant_id
                    FROM applicant
                    JOIN account ON (account_fk=account_id)
                WHERE login='elon@musk.com'
                )
FROM insert_job;



-- Посмотреть резюме
SELECT first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM job
    JOIN resume ON (job_fk = job_id)
    JOIN applicant ON applicant_fk = applicant_id
    JOIN account ON account_fk = account_id
    WHERE login='elon@musk.com';



-- Редактировать резюме #3
UPDATE job SET
    salary = '[430000, 520000]'
WHERE job_id = (SELECT job_fk FROM resume WHERE resume_id = 3) ;



-- Удалить резюме
WITH delete_resume AS (
    DELETE FROM resume WHERE resume_id = 3
    RETURNING job_fk
    )
DELETE FROM job
USING delete_resume
WHERE job.job_id = delete_resume.job_fk;



-- Вернем резюме обратно
WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity до её слияния с Tesla.',
                '[400000, 500000]')
        RETURNING job_id
   )
INSERT INTO resume (job_fk, applicant_fk)
SELECT job_id, (
                SELECT applicant_id
                    FROM applicant
                    JOIN account ON (account_fk=account_id)
                WHERE login='elon@musk.com'
                )
FROM insert_job;



-- Посмотреть все вакансии
SELECT name, title, city, description,salary FROM vacancy
JOIN company ON company_fk = company_id
JOIN job ON job_fk = job_id;



-- Откликнуться на вакансию
INSERT INTO responses(vacancy_fk, appliсant_fk, message)
VALUES (5, (SELECT applicant_id FROM applicant JOIN account ON account_fk = account_id WHERE login='elon@musk.com'),
'Здравствуйте, меня заинтересовала вакансия инженера ЦПИР в Москве, я монго работал над созданием очень сложных систем управления для космической техники.');



-- Пришло предложение
INSERT INTO suggestion (resume_fk, employer_fk, vacancy_fk, message)
VALUES (4, 3, 5,
'Предлагаем вам пройти собеседование на должность технолга в Центр перспективных инженерных разработок.');



-- Посмотреть список предложений
SELECT company.name, title, eaccount.first_name, eaccount.family_name, eaccount.contact_phone, eaccount.contact_email, message FROM suggestion
         JOIN resume ON resume_fk = resume_id
         JOIN applicant ON applicant_fk = applicant_id
         JOIN account aaccount ON account_fk = account_id
         JOIN vacancy ON vacancy_fk = vacancy_id
         JOIN company ON company_fk = company_id
         JOIN employer ON employer_fk = employer_id
         JOIN account eaccount ON employer.account_fk = eaccount.account_id
         JOIN job on vacancy.job_fk = job.job_id
WHERE aaccount.login='elon@musk.com';
