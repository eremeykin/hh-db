-- Зарегистрироваться
WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('kukushkin@hepi.ru', 'id6AWf3g', 'Руслан', 'Кукушкин', 'kukushkin@hepi.ru', 71354572398)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id)
SELECT account_id FROM insert_account;



-- Залогиниться
SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'kukushkin@hepi.ru';



-- Создать компанию
WITH insert_company AS (
        INSERT INTO company (name)
        VALUES ('Институт физики высоких энергий')
        RETURNING company_id
    )
UPDATE hr_manager SET
        company_id = (SELECT company_id from insert_company)
WHERE account_id = 8;



--Посмотреть компании
SELECT name, first_name, family_name, contact_email, contact_phone FROM company
JOIN hr_manager USING (company_id)
JOIN account USING (account_id);



-- Зарегистрируем ещё одного hr менеджера, так как в компании их может быть несколько
WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('ezhikov@mail.ru', 'EzhhIG', 'Артемий', 'Ежиков', 'a.ezhikov@hepi.ru', 71359847532)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id, company_id)
SELECT account_id,4 FROM insert_account;



-- Посмотреть менеджеров компании
SELECT login, first_name, family_name FROM hr_manager
JOIN account USING (account_id)
WHERE company_id = 4;



--  Создать вакансию
WITH insert_job AS (
    INSERT INTO job (title, city, description, salary)
    VALUES ('Исследователь', 'Москва','Ищем исследователя для изучения явлений физики высоких энергий, имеющих применение в оборонной промышленности',
            '[240000, 260000]')
    RETURNING job_id
    )
INSERT INTO vacancy (company_id, job_id, active)
SELECT 4, job_id, TRUE
FROM insert_job;



-- Посмотреть созданные вакансии
SELECT active, vacancy_id, name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN hr_manager USING (company_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE account_id = 8;



-- Деактивировать вакансию #6
UPDATE vacancy SET
    active = FALSE
WHERE vacancy_id = 6;



-- Активировать обратно вакансию #6
UPDATE vacancy SET
    active = TRUE
WHERE vacancy_id = 6;


-- Посмотреть все резюме
SELECT first_name, family_name, contact_email, contact_phone, title, city, description FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE active;



-- Поиск резюме по городу, названию и зарплате
SELECT first_name, family_name, contact_email, contact_phone, title, city, description, salary FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE 'Инженер' AND salary && '[,410000]' AND active;



-- Написать сообщение соискателю
INSERT INTO message (account_id, vacancy_id, resume_id, text)
VALUES (8, 6, 4, 'Здравствуйте, приглашаем Вас пройти собеседование на должность исследователя!');



-- Пришел ответ от соискателя
INSERT INTO message (account_id, vacancy_id, resume_id, text)
VALUES (7, 6, 4, 'Здравствуйте, меня устроит любое время в ближайший вторник или среду.');



-- Посмотреть диалог по вакансии 6
SELECT job.title, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
JOIN job on resume.job_id = job.job_id
WHERE vacancy_id = 6;

