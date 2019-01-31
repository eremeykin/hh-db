-- Зарегистрироваться
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('elon3@musk.com', 'hash(password+salt) to be here', 'Elon', 'Musk', null, null)
        RETURNING account_id
   )
INSERT INTO applicant (account_id)
SELECT account_id FROM insert_account;
-- Insert on applicant  (cost=0.01..0.04 rows=1 width=8) (actual time=0.165..0.165 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.109..0.110 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.014..0.015 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=8) (actual time=0.122..0.124 rows=1 loops=1)
-- Planning time: 0.133 ms
-- Trigger for constraint applicant_account_id_fkey on applicant: time=0.323 calls=1
-- Execution time: 0.571 ms

-- Залогиниться
EXPLAIN ANALYSE SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'elon@musk.com';
-- Nested Loop Left Join  (cost=0.86..24.91 rows=1 width=19) (actual time=0.035..0.035 rows=0 loops=1)
--   ->  Nested Loop Left Join  (cost=0.57..16.61 rows=1 width=15) (actual time=0.034..0.034 rows=0 loops=1)
--         ->  Index Scan using account_login_key on account  (cost=0.29..8.30 rows=1 width=11) (actual time=0.033..0.034 rows=0 loops=1)
--               Index Cond: ((login)::text = 'elon@musk.com'::text)
--         ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (never executed)
--               Index Cond: (account.account_id = account_id)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (never executed)
--         Index Cond: (account.account_id = account_id)
-- Planning time: 1.234 ms
-- Execution time: 0.247 ms

-- Отредактировать личные данные
EXPLAIN ANALYSE  UPDATE account SET
    first_name = 'Илон',
    family_name = 'Маск',
    contact_email = 'e.musk@spacex.com',
    contact_phone = 2342355678
WHERE account_id = 7;
-- Update on account  (cost=0.29..8.30 rows=1 width=1594) (actual time=0.216..0.216 rows=0 loops=1)
--   ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=1594) (actual time=0.041..0.045 rows=1 loops=1)
--         Index Cond: (account_id = 7)
-- Planning time: 0.246 ms
-- Execution time: 0.304 ms

-- Посмотреть личные данные
EXPLAIN ANALYSE  SELECT first_name, family_name, contact_email, contact_phone FROM account
WHERE account_id = 7;
-- Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=57) (actual time=0.029..0.056 rows=1 loops=1)
--   Index Cond: (account_id = 7)
-- Planning time: 0.295 ms
-- Execution time: 0.101 ms

-- Создать резюме
EXPLAIN ANALYSE WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity.',
                '[300000, 400000]')
        RETURNING job_id
   )
INSERT INTO resume (job_id, applicant_id, active)
SELECT job_id, 4, TRUE
FROM insert_job;
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.218..0.218 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.113..0.115 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.029..0.029 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.132..0.135 rows=1 loops=1)
-- Planning time: 0.194 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.356 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.333 calls=1
-- Execution time: 1.016 ms

-- Посмотреть свои резюме
EXPLAIN ANALYSE SELECT active, resume_id, first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM job
    JOIN resume USING (job_id)
    JOIN applicant USING (applicant_id)
    JOIN account USING (account_id)
WHERE account_id = 7;
-- Nested Loop  (cost=1.15..25.40 rows=1 width=132) (actual time=0.047..0.074 rows=2 loops=1)
--   ->  Nested Loop  (cost=0.86..17.09 rows=1 width=79) (actual time=0.034..0.052 rows=2 loops=1)
--         ->  Nested Loop  (cost=0.57..16.62 rows=1 width=13) (actual time=0.026..0.032 rows=2 loops=1)
--               ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.015..0.016 rows=1 loops=1)
--                     Index Cond: (account_id = 7)
--               ->  Index Scan using resume_applicant_id_index on resume  (cost=0.29..8.30 rows=1 width=13) (actual time=0.007..0.011 rows=2 loops=1)
--                     Index Cond: (applicant_id = applicant.applicant_id)
--         ->  Index Scan using job_pkey on job  (cost=0.29..0.47 rows=1 width=74) (actual time=0.007..0.007 rows=1 loops=2)
--               Index Cond: (job_id = resume.job_id)
--   ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=61) (actual time=0.007..0.008 rows=1 loops=2)
--         Index Cond: (account_id = 7)
-- Planning time: 1.306 ms
-- Execution time: 0.167 ms

-- Деактивировать резюме #3
EXPLAIN ANALYSE UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;
-- Update on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.225..0.225 rows=0 loops=1)
--   ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.043..0.046 rows=1 loops=1)
--         Index Cond: (resume_id = 3)
-- Planning time: 0.237 ms
-- Execution time: 0.326 ms

-- Редактировать резюме #3
EXPLAIN ANALYSE UPDATE job SET
    salary = '[430000, 520000]'
WHERE job_id = (SELECT job_id FROM resume WHERE resume_id = 3) ;
-- Update on job  (cost=8.59..16.61 rows=1 width=91) (actual time=0.159..0.159 rows=0 loops=1)
--   InitPlan 1 (returns $0)
--     ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=4) (actual time=0.021..0.059 rows=1 loops=1)
--           Index Cond: (resume_id = 3)
--   ->  Index Scan using job_pkey on job  (cost=0.29..8.31 rows=1 width=91) (actual time=0.079..0.081 rows=1 loops=1)
--         Index Cond: (job_id = $0)
-- Planning time: 0.201 ms
-- Execution time: 0.230 ms

-- Активировать обратно резюме #3
EXPLAIN ANALYSE UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;
-- Update on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.066..0.067 rows=0 loops=1)
--   ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.031..0.033 rows=1 loops=1)
--         Index Cond: (resume_id = 3)
-- Planning time: 0.145 ms
-- Execution time: 0.137 ms

-- Удалить резюме
EXPLAIN ANALYSE WITH to_delete AS (
     SELECT read_message_id, message_id, job_id, resume_id
     FROM resume
     JOIN job USING (job_id)
     LEFT JOIN message USING (resume_id)
     LEFT JOIN read_message USING (message_id)
     WHERE resume_id = 20004
), delete_read_message AS (
    DELETE FROM read_message
    WHERE read_message_id IN (SELECT read_message_id FROM to_delete)
    RETURNING read_message_id
    ), delete_message AS (
     DELETE FROM message
     WHERE message_id IN (SELECT message_id FROM to_delete)
     RETURNING message_id
), delete_resume AS (
    DELETE FROM resume
    WHERE resume_id IN (SELECT resume_id FROM to_delete)
    RETURNING job_id
)
DELETE FROM job
USING delete_read_message, delete_message, delete_resume
WHERE job.job_id = delete_resume.job_id;
-- Delete on job  (cost=58.62..66.72 rows=1 width=82) (actual time=0.015..0.015 rows=0 loops=1)
--   CTE to_delete
--     ->  Nested Loop Left Join  (cost=1.16..33.31 rows=1 width=16) (actual time=0.010..0.010 rows=0 loops=1)
--           ->  Nested Loop Left Join  (cost=0.87..24.99 rows=1 width=12) (actual time=0.009..0.010 rows=0 loops=1)
--                 Join Filter: (resume.resume_id = message.resume_id)
--                 ->  Nested Loop  (cost=0.57..16.61 rows=1 width=8) (actual time=0.009..0.009 rows=0 loops=1)
--                       ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=8) (actual time=0.009..0.009 rows=0 loops=1)
--                             Index Cond: (resume_id = 20004)
--                       ->  Index Only Scan using job_pkey on job job_1  (cost=0.29..8.31 rows=1 width=4) (never executed)
--                             Index Cond: (job_id = resume.job_id)
--                             Heap Fetches: 0
--                 ->  Index Scan using message_resume_id_index on message  (cost=0.29..8.35 rows=3 width=8) (never executed)
--                       Index Cond: (resume_id = 20004)
--           ->  Index Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..8.31 rows=1 width=8) (never executed)
--                 Index Cond: (message.message_id = message_id)
--   CTE delete_read_message
--     ->  Delete on read_message read_message_1  (cost=0.31..8.34 rows=1 width=34) (actual time=0.001..0.001 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.31..8.34 rows=1 width=34) (actual time=0.001..0.001 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.000..0.000 rows=0 loops=1)
--                       Group Key: to_delete.read_message_id
--                       ->  CTE Scan on to_delete  (cost=0.00..0.02 rows=1 width=32) (actual time=0.000..0.000 rows=0 loops=1)
--                 ->  Index Scan using read_message_pkey on read_message read_message_1  (cost=0.29..8.31 rows=1 width=10) (never executed)
--                       Index Cond: (read_message_id = to_delete.read_message_id)
--   CTE delete_message
--     ->  Delete on message message_1  (cost=0.32..8.34 rows=1 width=34) (actual time=0.001..0.001 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.32..8.34 rows=1 width=34) (actual time=0.001..0.001 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.001..0.001 rows=0 loops=1)
--                       Group Key: to_delete_1.message_id
--                       ->  CTE Scan on to_delete to_delete_1  (cost=0.00..0.02 rows=1 width=32) (actual time=0.000..0.000 rows=0 loops=1)
--                 ->  Index Scan using message_pkey on message message_1  (cost=0.29..8.31 rows=1 width=10) (never executed)
--                       Index Cond: (message_id = to_delete_1.message_id)
--   CTE delete_resume
--     ->  Delete on resume resume_1  (cost=0.31..8.34 rows=1 width=34) (actual time=0.012..0.012 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.31..8.34 rows=1 width=34) (actual time=0.011..0.011 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.011..0.011 rows=0 loops=1)
--                       Group Key: to_delete_2.resume_id
--                       ->  CTE Scan on to_delete to_delete_2  (cost=0.00..0.02 rows=1 width=32) (actual time=0.010..0.010 rows=0 loops=1)
--                 ->  Index Scan using resume_pkey on resume resume_1  (cost=0.29..8.30 rows=1 width=10) (never executed)
--                       Index Cond: (resume_id = to_delete_2.resume_id)
--   ->  Nested Loop  (cost=0.29..8.39 rows=1 width=82) (actual time=0.014..0.014 rows=0 loops=1)
--         ->  Nested Loop  (cost=0.29..8.36 rows=1 width=58) (actual time=0.013..0.013 rows=0 loops=1)
--               ->  Nested Loop  (cost=0.29..8.33 rows=1 width=34) (actual time=0.013..0.013 rows=0 loops=1)
--                     ->  CTE Scan on delete_resume  (cost=0.00..0.02 rows=1 width=32) (actual time=0.013..0.013 rows=0 loops=1)
--                     ->  Index Scan using job_pkey on job  (cost=0.29..8.31 rows=1 width=10) (never executed)
--                           Index Cond: (job_id = delete_resume.job_id)
--               ->  CTE Scan on delete_read_message  (cost=0.00..0.02 rows=1 width=24) (never executed)
--         ->  CTE Scan on delete_message  (cost=0.00..0.02 rows=1 width=24) (never executed)
-- Planning time: 1.436 ms
-- Execution time: 0.178 ms

-- Вернем резюме обратно
EXPLAIN ANALYSE WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Инженер', 'Москва','Большой опыт работы. Сооснователь компании PayPal; основатель, совладелец, генеральный директор и главный инженер компании SpaceX; генеральный директор и Chief Product Architect компании Tesla; был членом совета директоров компании SolarCity до её слияния с Tesla.',
                '[400000, 500000]')
        RETURNING job_id
   )
INSERT INTO resume (job_id, applicant_id, active)
SELECT job_id, 4, TRUE
FROM insert_job
RETURNING job_id;
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.101..0.104 rows=1 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.049..0.050 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.014..0.014 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.060..0.062 rows=1 loops=1)
-- Planning time: 0.137 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.245 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.134 calls=1
-- Execution time: 0.572 ms

-- Посмотреть все вакансии
EXPLAIN ANALYSE SELECT name, title, city, description,salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE active
ORDER BY vacancy_id ASC OFFSET 20 LIMIT 10;
-- Limit  (cost=26.46..39.26 rows=10 width=95) (actual time=0.748..1.067 rows=10 loops=1)
--   ->  Nested Loop  (cost=0.85..5574.23 rows=4353 width=95) (actual time=0.076..1.049 rows=30 loops=1)
--         ->  Nested Loop  (cost=0.56..1647.68 rows=4353 width=29) (actual time=0.057..0.584 rows=30 loops=1)
--               ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..326.57 rows=4353 width=12) (actual time=0.032..0.213 rows=30 loops=1)
--                     Filter: active
--                     Rows Removed by Filter: 34
--               ->  Index Scan using company_pkey on company  (cost=0.28..0.30 rows=1 width=25) (actual time=0.009..0.009 rows=1 loops=30)
--                     Index Cond: (company_id = vacancy.company_id)
--         ->  Index Scan using job_pkey on job  (cost=0.29..0.90 rows=1 width=74) (actual time=0.013..0.013 rows=1 loops=30)
--               Index Cond: (job_id = vacancy.job_id)
-- Planning time: 1.807 ms
-- Execution time: 1.208 ms

-- Поиск активных вакансий по городу и названию и чтоб платили много
EXPLAIN ANALYSE SELECT name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE '%Инженер%' AND salary && '[600000,]' AND active;
-- Nested Loop  (cost=0.56..1243.75 rows=1 width=91) (actual time=0.112..22.484 rows=1 loops=1)
--   ->  Nested Loop  (cost=0.29..1243.45 rows=1 width=74) (actual time=0.092..22.464 rows=1 loops=1)
--         ->  Seq Scan on job  (cost=0.00..1235.14 rows=1 width=74) (actual time=0.058..22.428 rows=1 loops=1)
--               Filter: (((title)::text ~~ '%Инженер%'::text) AND (salary && '[600000,)'::int8range) AND ((city)::text = 'Москва'::text))
--               Rows Removed by Filter: 40009
--         ->  Index Scan using vacancy_job_id_index on vacancy  (cost=0.29..8.30 rows=1 width=8) (actual time=0.027..0.027 rows=1 loops=1)
--               Index Cond: (job_id = job.job_id)
--               Filter: active
--   ->  Index Scan using company_pkey on company  (cost=0.28..0.30 rows=1 width=25) (actual time=0.015..0.015 rows=1 loops=1)
--         Index Cond: (company_id = vacancy.company_id)
-- Planning time: 1.869 ms
-- Execution time: 22.611 ms

-- Написать сообщение
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (7, 5, 4, 'Здравствуйте, меня заинтересовала вакансия инженера ЦПИР в Москве, я монго работал над созданием очень сложных систем управления для космической техники.', '2019-01-20 14:52:02');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.256..0.256 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.023..0.024 rows=1 loops=1)
-- Planning time: 0.046 ms
-- Trigger for constraint message_account_id_fkey: time=0.235 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.191 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.155 calls=1
-- Execution time: 0.888 ms

-- Пришел ответ от hr менеджера через 30 мин
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (6, 5, 4, 'Здравствуйте, приглашаем Вас на собеседование в четверг 15.05 в 16:30.', '2019-01-20 15:22:02');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.104..0.104 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.019..0.020 rows=1 loops=1)
-- Planning time: 0.067 ms
-- Trigger for constraint message_account_id_fkey: time=0.296 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.211 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.191 calls=1
-- Execution time: 0.877 ms

-- Посмотреть диалог по паре резюме 4 вакансия 5
EXPLAIN ANALYSE SELECT send, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
WHERE resume_id = 4 AND vacancy_id=5
ORDER BY send ASC ;
-- Sort  (cost=33.30..33.30 rows=1 width=57) (actual time=0.170..0.171 rows=2 loops=1)
--   Sort Key: message.send
--   Sort Method: quicksort  Memory: 25kB
--   ->  Nested Loop  (cost=1.15..33.29 rows=1 width=57) (actual time=0.114..0.152 rows=2 loops=1)
--         ->  Nested Loop  (cost=0.86..24.97 rows=1 width=57) (actual time=0.087..0.113 rows=2 loops=1)
--               ->  Nested Loop  (cost=0.58..16.66 rows=1 width=61) (actual time=0.039..0.055 rows=2 loops=1)
--                     ->  Index Scan using message_vacancy_id_index on message  (cost=0.29..8.35 rows=1 width=37) (actual time=0.024..0.028 rows=2 loops=1)
--                           Index Cond: (vacancy_id = 5)
--                           Filter: (resume_id = 4)
--                     ->  Index Scan using account_pkey on account hr  (cost=0.29..8.30 rows=1 width=32) (actual time=0.009..0.009 rows=1 loops=2)
--                           Index Cond: (account_id = message.account_id)
--               ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=4) (actual time=0.026..0.027 rows=1 loops=2)
--                     Index Cond: (vacancy_id = 5)
--                     Heap Fetches: 2
--         ->  Index Only Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=4) (actual time=0.013..0.015 rows=1 loops=2)
--               Index Cond: (resume_id = 4)
--               Heap Fetches: 2
-- Planning time: 1.161 ms
-- Execution time: 0.284 ms

-- Добавить скрытое тестовое резюме, в котором не будет ни одного сообщения
EXPLAIN ANALYSE WITH insert_job AS (
        INSERT INTO job (title, city, description, salary)
        VALUES ('Разработчик', 'Москва','Умею разрабатывать разные сложные штуки. Потом подробнее напишу.',
                '[300000, 320000]')
        RETURNING job_id
   )
INSERT INTO resume (job_id, applicant_id, active)
SELECT job_id, 4, FALSE
FROM insert_job;
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.093..0.093 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.046..0.048 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.014..0.014 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.056..0.058 rows=1 loops=1)
-- Planning time: 0.183 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.186 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.119 calls=1
-- Execution time: 0.499 ms

-- Пришло еще одно сообщение от hr менеджера
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (6, 5, 4, 'Извините, но в связи с непредвиденными обстоятельствами собеседование переносится на 20.05 в 16:30.', '2019-01-20 15:28:25');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.329..0.329 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.026..0.028 rows=1 loops=1)
-- Planning time: 0.097 ms
-- Trigger for constraint message_account_id_fkey: time=0.420 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.298 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.299 calls=1
-- Execution time: 1.460 ms

-- Второй вариант для
-- (а) список моих резюме с количеством всех сообщений и количеством новых сообщений
EXPLAIN ANALYSE SELECT DISTINCT COUNT(message.message_id) OVER (PARTITION BY resume_id) AS total_messages, COUNT(message.message_id) OVER (PARTITION BY resume_id) - COUNT(read_message.message_id)  OVER (PARTITION BY resume_id) AS read_messages,
 active, resume_id, first_name, family_name, contact_phone, contact_email, title, city, description, salary
 FROM job
    JOIN resume USING (job_id)
    JOIN applicant USING (applicant_id)
    JOIN account USING (account_id)
    LEFT JOIN message  USING (resume_id)
    LEFT JOIN read_message  ON (read_message.account_id = account.account_id AND message.message_id = read_message.message_id)
WHERE account.account_id = 7 AND (message.account_id != 7 OR message.account_id IS NULL);
-- Unique  (cost=1529.98..1530.17 rows=6 width=148) (actual time=0.333..0.345 rows=4 loops=1)
--   ->  Sort  (cost=1529.98..1529.99 rows=6 width=148) (actual time=0.332..0.333 rows=4 loops=1)
--         Sort Key: (count(message.message_id) OVER (?)), ((count(message.message_id) OVER (?) - count(read_message.message_id) OVER (?))), resume.active, resume.resume_id, account.first_name, account.family_name, account.contact_phone, account.contact_email, job.title, job.city, job.description, job.salary
--         Sort Method: quicksort  Memory: 27kB
--         ->  WindowAgg  (cost=1529.77..1529.90 rows=6 width=148) (actual time=0.239..0.256 rows=4 loops=1)
--               ->  Sort  (cost=1529.77..1529.78 rows=6 width=140) (actual time=0.222..0.224 rows=4 loops=1)
--                     Sort Key: resume.resume_id
--                     Sort Method: quicksort  Memory: 27kB
--                     ->  Nested Loop Left Join  (cost=1.73..1529.69 rows=6 width=140) (actual time=0.095..0.201 rows=4 loops=1)
--                           Join Filter: (read_message.account_id = account.account_id)
--                           ->  Nested Loop Left Join  (cost=1.44..1527.64 rows=6 width=140) (actual time=0.088..0.186 rows=4 loops=1)
--                                 Filter: ((message.account_id <> 7) OR (message.account_id IS NULL))
--                                 ->  Nested Loop  (cost=1.15..25.40 rows=1 width=136) (actual time=0.074..0.150 rows=4 loops=1)
--                                       ->  Nested Loop  (cost=0.86..17.09 rows=1 width=79) (actual time=0.060..0.105 rows=4 loops=1)
--                                             ->  Nested Loop  (cost=0.57..16.62 rows=1 width=13) (actual time=0.044..0.056 rows=4 loops=1)
--                                                   ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.025..0.026 rows=1 loops=1)
--                                                         Index Cond: (account_id = 7)
--                                                   ->  Index Scan using resume_applicant_id_index on resume  (cost=0.29..8.30 rows=1 width=13) (actual time=0.013..0.020 rows=4 loops=1)
--                                                         Index Cond: (applicant_id = applicant.applicant_id)
--                                             ->  Index Scan using job_pkey on job  (cost=0.29..0.47 rows=1 width=74) (actual time=0.009..0.009 rows=1 loops=4)
--                                                   Index Cond: (job_id = resume.job_id)
--                                       ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=61) (actual time=0.008..0.009 rows=1 loops=4)
--                                             Index Cond: (account_id = 7)
--                                 ->  Index Scan using message_resume_id_index on message  (cost=0.29..876.57 rows=50054 width=12) (actual time=0.007..0.007 rows=0 loops=4)
--                                       Index Cond: (resume.resume_id = resume_id)
--                           ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.33 rows=1 width=8) (actual time=0.001..0.001 rows=0 loops=4)
--                                 Index Cond: ((message_id = message.message_id) AND (account_id = 7))
--                                 Heap Fetches: 0
-- Planning time: 4.107 ms
-- Execution time: 0.632 ms

-- прочитать сообщение #4
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (4,7);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.444..0.444 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.270..0.272 rows=1 loops=1)
-- Planning time: 0.074 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.794 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.673 calls=1
-- Execution time: 2.066 ms

-- прочитать сообщение #5
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (5,7);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.069..0.069 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.016..0.017 rows=1 loops=1)
-- Planning time: 0.040 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.319 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.185 calls=1
-- Execution time: 0.630 ms