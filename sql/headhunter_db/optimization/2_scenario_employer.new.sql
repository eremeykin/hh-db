-- Зарегистрироваться
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('kukushkin@hepi.ru', 'id6AWf3g', 'Руслан', 'Кукушкин', 'kukushkin@hepi.ru', 71354572398)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id)
SELECT account_id FROM insert_account;
-- Insert on hr_manager  (cost=0.01..0.04 rows=1 width=12) (actual time=0.365..0.365 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.197..0.200 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.094..0.096 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=12) (actual time=0.225..0.229 rows=1 loops=1)
-- Planning time: 0.271 ms
-- Trigger for constraint hr_manager_account_id_fkey on hr_manager: time=0.650 calls=1
-- Trigger for constraint hr_manager_company_id_fkey on hr_manager: time=0.020 calls=1
-- Execution time: 1.200 ms

-- Залогиниться
EXPLAIN ANALYSE SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'kukushkin@hepi.ru';
-- Nested Loop Left Join  (cost=0.86..24.91 rows=1 width=19) (actual time=0.069..0.073 rows=1 loops=1)
--   ->  Nested Loop Left Join  (cost=0.57..16.61 rows=1 width=15) (actual time=0.054..0.057 rows=1 loops=1)
--         ->  Index Scan using account_login_key on account  (cost=0.29..8.30 rows=1 width=11) (actual time=0.036..0.038 rows=1 loops=1)
--               Index Cond: ((login)::text = 'kukushkin@hepi.ru'::text)
--         ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.011..0.012 rows=0 loops=1)
--               Index Cond: (account.account_id = account_id)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.011..0.011 rows=1 loops=1)
--         Index Cond: (account.account_id = account_id)
-- Planning time: 1.240 ms
-- Execution time: 0.186 ms

-- Создать компанию
EXPLAIN ANALYSE WITH insert_company AS (
        INSERT INTO company (name)
        VALUES ('Институт физики высоких энергий')
        RETURNING company_id
    )
UPDATE hr_manager SET
        company_id = (SELECT company_id from insert_company)
WHERE account_id = 8;
-- Update on hr_manager  (cost=0.32..8.34 rows=1 width=18) (actual time=0.016..0.016 rows=0 loops=1)
--   CTE insert_company
--     ->  Insert on company  (cost=0.00..0.01 rows=1 width=520) (actual time=0.096..0.097 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=520) (actual time=0.023..0.023 rows=1 loops=1)
--   InitPlan 2 (returns $2)
--     ->  CTE Scan on insert_company  (cost=0.00..0.02 rows=1 width=4) (never executed)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=18) (actual time=0.015..0.015 rows=0 loops=1)
--         Index Cond: (account_id = 8)
-- Planning time: 0.190 ms
-- Execution time: 0.192 ms

--Посмотреть компании
EXPLAIN ANALYSE SELECT name, first_name, family_name, contact_email, contact_phone FROM company
JOIN hr_manager USING (company_id)
JOIN account USING (account_id)
ORDER BY company_id OFFSET 20 LIMIT 10;
-- Limit  (cost=15.65..23.05 rows=10 width=82) (actual time=0.233..0.333 rows=10 loops=1)
--   ->  Nested Loop  (cost=0.84..3700.96 rows=4998 width=82) (actual time=0.044..0.326 rows=30 loops=1)
--         ->  Merge Join  (cost=0.56..376.57 rows=4998 width=29) (actual time=0.032..0.110 rows=30 loops=1)
--               Merge Cond: (company.company_id = hr_manager.company_id)
--               ->  Index Scan using company_pkey on company  (cost=0.28..44.52 rows=950 width=25) (actual time=0.014..0.017 rows=7 loops=1)
--               ->  Index Scan using hr_manager_company_index on hr_manager  (cost=0.28..267.24 rows=4998 width=8) (actual time=0.012..0.067 rows=30 loops=1)
--         ->  Index Scan using account_pkey on account  (cost=0.29..0.67 rows=1 width=61) (actual time=0.005..0.005 rows=1 loops=30)
--               Index Cond: (account_id = hr_manager.account_id)
-- Planning time: 1.368 ms
-- Execution time: 0.403 ms

-- Зарегистрируем ещё одного hr менеджера, так как в компании их может быть несколько
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('ezhikov@mail.ru', 'EzhhIG', 'Артемий', 'Ежиков', 'a.ezhikov@hepi.ru', 71359847532)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id, company_id)
SELECT account_id,4 FROM insert_account;
-- Insert on hr_manager  (cost=0.01..0.04 rows=1 width=12) (actual time=0.210..0.210 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.137..0.140 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.026..0.027 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=12) (actual time=0.160..0.164 rows=1 loops=1)
-- Planning time: 0.272 ms
-- Trigger for constraint hr_manager_account_id_fkey on hr_manager: time=0.406 calls=1
-- Trigger for constraint hr_manager_company_id_fkey on hr_manager: time=0.598 calls=1
-- Execution time: 1.381 ms

-- Посмотреть менеджеров компании
EXPLAIN ANALYSE SELECT login, first_name, family_name FROM hr_manager
JOIN account USING (account_id)
WHERE company_id = 4
ORDER BY hr_manager_id OFFSET 10 LIMIT 10;
-- Limit  (cost=59.64..59.64 rows=1 width=53) (actual time=0.260..0.260 rows=0 loops=1)
--   ->  Sort  (cost=59.63..59.64 rows=5 width=53) (actual time=0.254..0.256 rows=7 loops=1)
--         Sort Key: hr_manager.hr_manager_id
--         Sort Method: quicksort  Memory: 25kB
--         ->  Nested Loop  (cost=4.61..59.57 rows=5 width=53) (actual time=0.068..0.215 rows=7 loops=1)
--               ->  Bitmap Heap Scan on hr_manager  (cost=4.32..18.05 rows=5 width=8) (actual time=0.040..0.076 rows=7 loops=1)
--                     Recheck Cond: (company_id = 4)
--                     Heap Blocks: exact=5
--                     ->  Bitmap Index Scan on hr_manager_company_index  (cost=0.00..4.32 rows=5 width=0) (actual time=0.025..0.026 rows=7 loops=1)
--                           Index Cond: (company_id = 4)
--               ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=53) (actual time=0.016..0.016 rows=1 loops=7)
--                     Index Cond: (account_id = hr_manager.account_id)
-- Planning time: 0.885 ms
-- Execution time: 0.428 ms

--  Создать вакансию
EXPLAIN ANALYSE WITH insert_job AS (
    INSERT INTO job (title, city, description, salary)
    VALUES ('Исследователь', 'Москва','Ищем исследователя для изучения явлений физики высоких энергий, имеющих применение в оборонной промышленности',
            '[240000, 260000]')
    RETURNING job_id
    )
INSERT INTO vacancy (company_id, job_id, active)
SELECT 4, job_id, TRUE
FROM insert_job;
-- Insert on vacancy  (cost=0.01..0.04 rows=1 width=13) (actual time=0.188..0.188 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.065..0.066 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.028..0.028 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.080..0.082 rows=1 loops=1)
-- Planning time: 0.150 ms
-- Trigger for constraint vacancy_company_id_fkey on vacancy: time=0.354 calls=1
-- Trigger for constraint vacancy_job_id_fkey on vacancy: time=0.287 calls=1
-- Execution time: 0.927 ms

-- Посмотреть созданные вакансии
EXPLAIN ANALYSE SELECT active, vacancy_id, name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN hr_manager USING (company_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE account_id = 8;
-- Nested Loop  (cost=1.42..31.23 rows=9 width=96) (actual time=0.012..0.012 rows=0 loops=1)
--   ->  Nested Loop  (cost=1.13..25.81 rows=9 width=30) (actual time=0.012..0.012 rows=0 loops=1)
--         ->  Nested Loop  (cost=0.84..24.92 rows=1 width=29) (actual time=0.011..0.011 rows=0 loops=1)
--               ->  Nested Loop  (cost=0.56..16.61 rows=1 width=33) (actual time=0.011..0.011 rows=0 loops=1)
--                     ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.010..0.011 rows=0 loops=1)
--                           Index Cond: (account_id = 8)
--                     ->  Index Scan using company_pkey on company  (cost=0.28..8.29 rows=1 width=25) (never executed)
--                           Index Cond: (company_id = hr_manager.company_id)
--               ->  Index Only Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=4) (never executed)
--                     Index Cond: (account_id = 8)
--                     Heap Fetches: 0
--         ->  Index Scan using vacancy_company_id_index on vacancy  (cost=0.29..0.80 rows=9 width=13) (never executed)
--               Index Cond: (company_id = company.company_id)
--   ->  Index Scan using job_pkey on job  (cost=0.29..0.60 rows=1 width=74) (never executed)
--         Index Cond: (job_id = vacancy.job_id)
-- Planning time: 2.254 ms
-- Execution time: 0.093 ms

-- Деактивировать вакансию #6
EXPLAIN ANALYSE UPDATE vacancy SET
    active = FALSE
WHERE vacancy_id = 6;
-- Update on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.625..0.626 rows=0 loops=1)
--   ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.060..0.066 rows=1 loops=1)
--         Index Cond: (vacancy_id = 6)
-- Planning time: 0.216 ms
-- Execution time: 0.781 ms

-- Активировать обратно вакансию #6
EXPLAIN ANALYSE UPDATE vacancy SET
    active = TRUE
WHERE vacancy_id = 6;
-- Update on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.243..0.244 rows=0 loops=1)
--   ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.055..0.166 rows=1 loops=1)
--         Index Cond: (vacancy_id = 6)
-- Planning time: 0.302 ms
-- Execution time: 0.351 ms

-- Посмотреть все резюме
EXPLAIN ANALYSE SELECT first_name, family_name, contact_email, contact_phone, title, city, description FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE active
ORDER BY resume_id OFFSET 10 LIMIT 10;
-- Limit  (cost=15.94..30.72 rows=10 width=110) (actual time=0.413..0.647 rows=10 loops=1)
--   ->  Nested Loop  (cost=1.15..11711.12 rows=7920 width=110) (actual time=0.060..0.639 rows=20 loops=1)
--         ->  Nested Loop  (cost=0.86..6687.72 rows=7920 width=65) (actual time=0.048..0.441 rows=20 loops=1)
--               ->  Nested Loop  (cost=0.57..3559.42 rows=7920 width=12) (actual time=0.035..0.269 rows=20 loops=1)
--                     ->  Index Scan using resume_pkey on resume  (cost=0.29..559.82 rows=7920 width=12) (actual time=0.019..0.076 rows=20 loops=1)
--                           Filter: active
--                           Rows Removed by Filter: 15
--                     ->  Index Scan using applicant_pkey on applicant  (cost=0.29..0.38 rows=1 width=8) (actual time=0.008..0.008 rows=1 loops=20)
--                           Index Cond: (applicant_id = resume.applicant_id)
--               ->  Index Scan using account_pkey on account  (cost=0.29..0.39 rows=1 width=61) (actual time=0.007..0.007 rows=1 loops=20)
--                     Index Cond: (account_id = applicant.account_id)
--         ->  Index Scan using job_pkey on job  (cost=0.29..0.63 rows=1 width=53) (actual time=0.008..0.008 rows=1 loops=20)
--               Index Cond: (job_id = resume.job_id)
-- Planning time: 3.399 ms
-- Execution time: 0.760 ms

-- Поиск резюме по городу, названию и зарплате
EXPLAIN ANALYSE SELECT first_name, family_name, contact_email, contact_phone, title, city, description, salary FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE to_tsvector('russian', city) @@ to_tsquery('russian','Иркутск')
AND to_tsvector('russian', title) @@ to_tsquery('russian','Биолог')
AND salary && '[,410000]' AND active;
--  Nested Loop  (cost=16.87..29.61 rows=1 width=128) (actual time=0.107..0.111 rows=1 loops=1)
--   ->  Nested Loop  (cost=16.58..29.21 rows=1 width=75) (actual time=0.096..0.099 rows=1 loops=1)
--         ->  Nested Loop  (cost=16.30..28.83 rows=1 width=75) (actual time=0.084..0.087 rows=1 loops=1)
--               ->  Bitmap Heap Scan on job  (cost=16.01..20.53 rows=1 width=75) (actual time=0.065..0.067 rows=1 loops=1)
--                     Recheck Cond: (to_tsvector('russian'::regconfig, (title)::text) @@ '''биолог'''::tsquery)
--                     Filter: ((salary && '(,410001)'::int8range) AND (to_tsvector('russian'::regconfig, (city)::text) @@ '''иркутск'''::tsquery))
--                     Heap Blocks: exact=1
--                     ->  Bitmap Index Scan on job_title_index  (cost=0.00..16.01 rows=1 width=0) (actual time=0.026..0.026 rows=1 loops=1)
--                           Index Cond: (to_tsvector('russian'::regconfig, (title)::text) @@ '''биолог'''::tsquery)
--               ->  Index Scan using resume_job_id_key on resume  (cost=0.29..8.30 rows=1 width=8) (actual time=0.015..0.015 rows=1 loops=1)
--                     Index Cond: (job_id = job.job_id)
--                     Filter: active
--         ->  Index Scan using applicant_pkey on applicant  (cost=0.29..0.38 rows=1 width=8) (actual time=0.009..0.009 rows=1 loops=1)
--               Index Cond: (applicant_id = resume.applicant_id)
--   ->  Index Scan using account_pkey on account  (cost=0.29..0.39 rows=1 width=61) (actual time=0.009..0.009 rows=1 loops=1)
--         Index Cond: (account_id = applicant.account_id)
-- Planning time: 1.894 ms
-- Execution time: 0.254 ms
-- Execution time: 0.254 ms

-- Написать сообщение соискателю
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (1, 324, 4, 'Здравствуйте, приглашаем Вас пройти собеседование на должность исследователя!', '2019-01-25 17:01:58');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.164..0.164 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.048..0.049 rows=1 loops=1)
-- Planning time: 0.076 ms
-- Trigger for constraint message_account_id_fkey: time=0.339 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.314 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.238 calls=1
-- Execution time: 1.143 ms

-- Пришел ответ от соискателя через 1 час
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text , send)
VALUES (7, 6, 4, 'Здравствуйте, меня устроит любое время в ближайший вторник или среду.', '2019-01-25 18:01:58');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.171..0.171 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.029..0.031 rows=1 loops=1)
-- Planning time: 0.112 ms
-- Trigger for constraint message_account_id_fkey: time=0.480 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.356 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.325 calls=1
-- Execution time: 1.457 ms

-- Посмотреть диалог по вакансии 6
EXPLAIN ANALYSE SELECT send, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
WHERE vacancy_id = 6 AND resume_id =4
ORDER BY send ASC;
-- Sort  (cost=33.30..33.30 rows=1 width=57) (actual time=0.086..0.087 rows=1 loops=1)
--   Sort Key: message.send
--   Sort Method: quicksort  Memory: 25kB
--   ->  Nested Loop  (cost=1.15..33.29 rows=1 width=57) (actual time=0.064..0.071 rows=1 loops=1)
--         ->  Nested Loop  (cost=0.86..24.97 rows=1 width=57) (actual time=0.050..0.053 rows=1 loops=1)
--               ->  Nested Loop  (cost=0.58..16.66 rows=1 width=61) (actual time=0.035..0.037 rows=1 loops=1)
--                     ->  Index Scan using message_vacancy_id_index on message  (cost=0.29..8.35 rows=1 width=37) (actual time=0.021..0.023 rows=1 loops=1)
--                           Index Cond: (vacancy_id = 6)
--                           Filter: (resume_id = 4)
--                     ->  Index Scan using account_pkey on account hr  (cost=0.29..8.30 rows=1 width=32) (actual time=0.010..0.010 rows=1 loops=1)
--                           Index Cond: (account_id = message.account_id)
--               ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=4) (actual time=0.013..0.014 rows=1 loops=1)
--                     Index Cond: (vacancy_id = 6)
--                     Heap Fetches: 1
--         ->  Index Only Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=4) (actual time=0.010..0.012 rows=1 loops=1)
--               Index Cond: (resume_id = 4)
--               Heap Fetches: 1
-- Planning time: 0.942 ms
-- Execution time: 0.187 ms

-- Добавить скрытую тестовую вакансию, в которой не будет ни одного сообщения
EXPLAIN ANALYSE WITH insert_job AS (
    INSERT INTO job (title, city, description, salary)
    VALUES ('Наладчик', 'Москва','Потом заполню',
            '[130000, 140000]')
    RETURNING job_id
    )
INSERT INTO vacancy (company_id, job_id, active)
SELECT 4, job_id, FALSE
FROM insert_job;
-- Insert on vacancy  (cost=0.01..0.04 rows=1 width=13) (actual time=0.185..0.185 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.085..0.087 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.036..0.037 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.107..0.110 rows=1 loops=1)
-- Planning time: 0.203 ms
-- Trigger for constraint vacancy_company_id_fkey on vacancy: time=0.324 calls=1
-- Trigger for constraint vacancy_job_id_fkey on vacancy: time=0.271 calls=1
-- Execution time: 0.918 ms

-- Пришло ещё сообщение
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (7, 6, 4, 'Проверка связи', '2019-01-20 18:23:14');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.114..0.114 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.019..0.020 rows=1 loops=1)
-- Planning time: 0.098 ms
-- Trigger for constraint message_account_id_fkey: time=0.375 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.325 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.319 calls=1
-- Execution time: 1.240 ms

-- Второй вариант для
-- (б) список вакансий моей компании с количествами всех и новых сообщений
EXPLAIN ANALYSE SELECT DISTINCT COUNT(message.message_id) OVER (PARTITION BY resume_id) AS total_messages, COUNT(message.message_id) OVER (PARTITION BY resume_id) - COUNT(read_message.message_id)  OVER (PARTITION BY resume_id) AS read_messages,
  active, vacancy_id, title, city, description, salary
  FROM job
    JOIN vacancy USING (job_id)
    JOIN company USING (company_id)
    JOIN hr_manager USING (company_id)
    JOIN account USING (account_id)
    LEFT JOIN message  USING (vacancy_id)
    LEFT JOIN read_message  ON (read_message.account_id = account.account_id AND message.message_id = read_message.message_id)
WHERE account.account_id = 8 AND (message.account_id != 8 OR message.account_id IS NULL);
-- Unique  (cost=2397.41..2399.73 rows=103 width=95) (actual time=0.077..0.077 rows=0 loops=1)
--   ->  Sort  (cost=2397.41..2397.67 rows=103 width=95) (actual time=0.076..0.076 rows=0 loops=1)
--         Sort Key: (count(message.message_id) OVER (?)), ((count(message.message_id) OVER (?) - count(read_message.message_id) OVER (?))), vacancy.active, vacancy.vacancy_id, job.title, job.city, job.description, job.salary
--         Sort Method: quicksort  Memory: 25kB
--         ->  WindowAgg  (cost=2391.65..2393.97 rows=103 width=95) (actual time=0.055..0.055 rows=0 loops=1)
--               ->  Sort  (cost=2391.65..2391.91 rows=103 width=87) (actual time=0.053..0.053 rows=0 loops=1)
--                     Sort Key: message.resume_id
--                     Sort Method: quicksort  Memory: 25kB
--                     ->  Nested Loop Left Join  (cost=23.60..2388.21 rows=103 width=87) (actual time=0.048..0.048 rows=0 loops=1)
--                           Join Filter: (read_message.account_id = account.account_id)
--                           ->  Nested Loop  (cost=23.31..2353.13 rows=103 width=87) (actual time=0.047..0.047 rows=0 loops=1)
--                                 ->  Index Only Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=4) (actual time=0.022..0.024 rows=1 loops=1)
--                                       Index Cond: (account_id = 8)
--                                       Heap Fetches: 1
--                                 ->  Hash Right Join  (cost=23.03..2343.80 rows=103 width=87) (actual time=0.021..0.021 rows=0 loops=1)
--                                       Hash Cond: (message.vacancy_id = vacancy.vacancy_id)
--                                       Filter: ((message.account_id <> 8) OR (message.account_id IS NULL))
--                                       ->  Seq Scan on message  (cost=0.00..1944.08 rows=100108 width=16) (never executed)
--                                       ->  Hash  (cost=22.91..22.91 rows=9 width=79) (actual time=0.013..0.013 rows=0 loops=1)
--                                             Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                             ->  Nested Loop  (cost=1.13..22.91 rows=9 width=79) (actual time=0.012..0.012 rows=0 loops=1)
--                                                   ->  Nested Loop  (cost=0.84..17.50 rows=9 width=13) (actual time=0.012..0.012 rows=0 loops=1)
--                                                         ->  Nested Loop  (cost=0.56..16.61 rows=1 width=12) (actual time=0.012..0.012 rows=0 loops=1)
--                                                               ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.011..0.011 rows=0 loops=1)
--                                                                     Index Cond: (account_id = 8)
--                                                               ->  Index Only Scan using company_pkey on company  (cost=0.28..8.29 rows=1 width=4) (never executed)
--                                                                     Index Cond: (company_id = hr_manager.company_id)
--                                                                     Heap Fetches: 0
--                                                         ->  Index Scan using vacancy_company_id_index on vacancy  (cost=0.29..0.80 rows=9 width=13) (never executed)
--                                                               Index Cond: (company_id = company.company_id)
--                                                   ->  Index Scan using job_pkey on job  (cost=0.29..0.60 rows=1 width=74) (never executed)
--                                                         Index Cond: (job_id = vacancy.job_id)
--                           ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.33 rows=1 width=8) (never executed)
--                                 Index Cond: ((message_id = message.message_id) AND (account_id = 8))
--                                 Heap Fetches: 0
-- Planning time: 6.773 ms
-- Execution time: 0.302 ms

-- прочитать сообщение #7
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (7,8);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.113..0.113 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.037..0.037 rows=1 loops=1)
-- Planning time: 0.057 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.366 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.261 calls=1
-- Execution time: 0.824 ms

-- прочитать сообщение #8
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (8,8);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.105..0.105 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.022..0.023 rows=1 loops=1)
-- Planning time: 0.059 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.444 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.638 calls=1
-- Execution time: 1.285 ms