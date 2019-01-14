-- Зарегистрироваться
WITH insert_user AS (
        INSERT INTO users (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('elon@musk.com', 'hash(password+salt) to be here', 'Elon', 'Musk', null, null)
        RETURNING user_id
   )
INSERT INTO applicants (user_fk)
SELECT user_id FROM insert_user;



-- Залогиниться
SELECT password FROM users
WHERE login = 'elon@musk.com';



-- Отредактировать личные данные
UPDATE users SET
    first_name = 'Илон',
    family_name = 'Маск',
    contact_email = 'e.musk@spacex.com',
    contact_phone = 2342355678
WHERE login = 'elon@musk.com';



-- Посмотреть личные данные
SELECT first_name, family_name, contact_email, contact_phone from users
WHERE login = 'elon@musk.com';



-- Создать резюме
WITH insert_job AS (
        INSERT INTO jobs (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity.',
                '[300000, 400000]')
        RETURNING job_id
   )
INSERT INTO resumes (job_fk, applicant_fk)
SELECT job_id, (
                SELECT applicant_id
                    FROM applicants
                    JOIN users ON (user_fk=user_id)
                WHERE login='elon@musk.com'
                )
FROM insert_job;



-- Посмотреть резюме
SELECT first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM jobs
    JOIN resumes ON (job_fk = job_id)
    JOIN applicants ON applicant_fk = applicant_id
    JOIN users ON user_fk = user_id
    WHERE login='elon@musk.com';



-- Редактировать резюме #3
UPDATE jobs SET
    salary = '[430000, 520000]'
WHERE job_id = (SELECT job_fk FROM resumes WHERE resume_id = 3) ;



-- Удалить резюме
WITH delete_resume AS (
    DELETE FROM resumes WHERE resume_id = 3
    RETURNING job_fk
    )
DELETE FROM jobs
USING delete_resume
WHERE jobs.job_id = delete_resume.job_fk;



-- Вернем резюме обратно
WITH insert_job AS (
        INSERT INTO jobs (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity до её слияния с Tesla.',
                '[400000, 500000]')
        RETURNING job_id
   )
INSERT INTO resumes (job_fk, applicant_fk)
SELECT job_id, (
                SELECT applicant_id
                    FROM applicants
                    JOIN users ON (user_fk=user_id)
                WHERE login='elon@musk.com'
                )
FROM insert_job;



-- Посмотреть все вакансии
SELECT name, title, city, description,salary FROM vacancies
JOIN companies ON company_fk = company_id
JOIN jobs ON job_fk = job_id;



-- Откликнуться на вакансию
INSERT INTO responses(vacancy_fk, appliсant_fk, message)
VALUES (5, (SELECT applicant_id FROM applicants JOIN users ON user_fk = user_id WHERE login='elon@musk.com'),
'Здравствуйте, меня заинтересовала вакансия инженера ЦПИР в Москве, я монго работал над созданием очень сложных систем управления для космической техники.');



-- Пришло предложение
INSERT INTO suggestions (resume_fk, employer_fk, vacancy_fk, message)
VALUES (4, 3, 5,
'Предлагаем вам пройти собеседование на должность технолга в Центр перспективных инженерных разработок.');



-- Посмотреть список предложений
SELECT companies.name, title, euser.first_name, euser.family_name, euser.contact_phone, euser.contact_email, message FROM suggestions
         JOIN resumes ON resume_fk = resume_id
         JOIN applicants ON applicant_fk = applicant_id
         JOIN users auser ON user_fk = user_id
         JOIN vacancies ON vacancy_fk = vacancy_id
         JOIN companies ON company_fk = company_id
         JOIN employers ON employer_fk = employer_id
         JOIN users euser on employers.user_fk = euser.user_id
         JOIN jobs on vacancies.job_fk = jobs.job_id
WHERE auser.login='elon@musk.com';
