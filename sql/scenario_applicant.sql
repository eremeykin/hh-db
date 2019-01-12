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
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity до её слияния с Tesla.',
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

SELECT  * FROM jobs;

-- Посмотреть резюме
SELECT first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM jobs
    JOIN resumes ON (job_fk = job_id)
    JOIN applicants ON applicant_fk = applicant_id
    JOIN users ON user_fk = user_id
    WHERE login='elon@musk.com'



-- Редактировать резюме
UPDATE jobs SET
    salary = '[400000, 500000]'
WHERE job_id = (SELECT job_fk FROM resumes WHERE resume_id = 1);



-- Удалить резюме
WITH delete_resume AS (
    DELETE FROM resumes WHERE resume_id = 1
    RETURNING job_fk
    )
DELETE FROM jobs
USING delete_resume
WHERE jobs.job_id = delete_resume.job_fk;
