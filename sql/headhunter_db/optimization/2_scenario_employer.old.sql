-- Зарегистрироваться
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('kukushkin@hepi.ru', 'id6AWf3g', 'Руслан', 'Кукушкин', 'kukushkin@hepi.ru', 71354572398)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id)
SELECT account_id FROM insert_account;
-- Insert on hr_manager  (cost=0.01..0.04 rows=1 width=12) (actual time=0.172..0.172 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.064..0.065 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.021..0.022 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=12) (actual time=0.078..0.080 rows=1 loops=1)
-- Planning time: 0.102 ms
-- Trigger for constraint hr_manager_account_id_fkey on hr_manager: time=0.819 calls=1
-- Trigger for constraint hr_manager_company_id_fkey on hr_manager: time=0.036 calls=1
-- Execution time: 1.129 ms


-- Залогиниться
EXPLAIN ANALYSE SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'kukushkin@hepi.ru';
-- Nested Loop Left Join  (cost=0.86..24.91 rows=1 width=19) (actual time=0.070..0.074 rows=1 loops=1)
--   ->  Nested Loop Left Join  (cost=0.57..16.61 rows=1 width=15) (actual time=0.055..0.059 rows=1 loops=1)
--         ->  Index Scan using account_login_key on account  (cost=0.29..8.30 rows=1 width=11) (actual time=0.036..0.039 rows=1 loops=1)
--               Index Cond: ((login)::text = 'kukushkin@hepi.ru'::text)
--         ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.012..0.012 rows=0 loops=1)
--               Index Cond: (account.account_id = account_id)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.011..0.011 rows=1 loops=1)
--         Index Cond: (account.account_id = account_id)
-- Planning time: 1.323 ms
-- Execution time: 0.188 ms


-- Создать компанию
EXPLAIN ANALYSE WITH insert_company AS (
        INSERT INTO company (name)
        VALUES ('Институт физики высоких энергий')
        RETURNING company_id
    )
UPDATE hr_manager SET
        company_id = (SELECT company_id from insert_company)
WHERE account_id = 8;
-- Update on hr_manager  (cost=0.32..8.34 rows=1 width=18) (actual time=0.023..0.023 rows=0 loops=1)
--   CTE insert_company
--     ->  Insert on company  (cost=0.00..0.01 rows=1 width=520) (actual time=0.138..0.139 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=520) (actual time=0.031..0.032 rows=1 loops=1)
--   InitPlan 2 (returns $2)
--     ->  CTE Scan on insert_company  (cost=0.00..0.02 rows=1 width=4) (never executed)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=18) (actual time=0.020..0.021 rows=0 loops=1)
--         Index Cond: (account_id = 8)
-- Planning time: 0.289 ms
-- Execution time: 0.289 ms


--Посмотреть компании
EXPLAIN ANALYSE SELECT name, first_name, family_name, contact_email, contact_phone FROM company
JOIN hr_manager USING (company_id)
JOIN account USING (account_id);
-- Hash Join  (cost=28.99..804.48 rows=5000 width=78) (actual time=1.210..28.487 rows=5000 loops=1)
--   Hash Cond: (hr_manager.company_id = company.company_id)
--   ->  Merge Join  (cost=0.61..762.93 rows=5000 width=61) (actual time=0.046..23.352 rows=5001 loops=1)
--         Merge Cond: (hr_manager.account_id = account.account_id)
--         ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..170.28 rows=5000 width=8) (actual time=0.019..2.745 rows=5001 loops=1)
--         ->  Index Scan using account_pkey on account  (cost=0.29..1041.39 rows=25007 width=61) (actual time=0.016..10.787 rows=25009 loops=1)
--   ->  Hash  (cost=16.50..16.50 rows=950 width=25) (actual time=1.148..1.148 rows=951 loops=1)
--         Buckets: 1024  Batches: 1  Memory Usage: 63kB
--         ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=25) (actual time=0.022..0.490 rows=951 loops=1)
-- Planning time: 1.044 ms
-- Execution time: 29.212 ms


-- Зарегистрируем ещё одного hr менеджера, так как в компании их может быть несколько
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('ezhikov@mail.ru', 'EzhhIG', 'Артемий', 'Ежиков', 'a.ezhikov@hepi.ru', 71359847532)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id, company_id)
SELECT account_id,4 FROM insert_account;
-- Insert on hr_manager  (cost=0.01..0.04 rows=1 width=12) (actual time=0.075..0.075 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.050..0.050 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.011..0.011 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=12) (actual time=0.058..0.059 rows=1 loops=1)
-- Planning time: 0.090 ms
-- Trigger for constraint hr_manager_account_id_fkey on hr_manager: time=0.130 calls=1
-- Trigger for constraint hr_manager_company_id_fkey on hr_manager: time=0.172 calls=1
-- Execution time: 0.431 ms


-- Посмотреть менеджеров компании
EXPLAIN ANALYSE SELECT login, first_name, family_name FROM hr_manager
JOIN account USING (account_id)
WHERE company_id = 4;
-- Nested Loop  (cost=0.29..132.03 rows=5 width=49) (actual time=0.256..2.690 rows=8 loops=1)
--   ->  Seq Scan on hr_manager  (cost=0.00..90.50 rows=5 width=4) (actual time=0.235..2.554 rows=8 loops=1)
--         Filter: (company_id = 4)
--         Rows Removed by Filter: 4994
--   ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=53) (actual time=0.013..0.013 rows=1 loops=8)
--         Index Cond: (account_id = hr_manager.account_id)
-- Planning time: 0.556 ms
-- Execution time: 2.764 ms


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
-- Insert on vacancy  (cost=0.01..0.04 rows=1 width=13) (actual time=0.144..0.144 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.067..0.069 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.029..0.030 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.080..0.082 rows=1 loops=1)
-- Planning time: 0.118 ms
-- Trigger for constraint vacancy_company_id_fkey on vacancy: time=0.333 calls=1
-- Trigger for constraint vacancy_job_id_fkey on vacancy: time=0.212 calls=1
-- Execution time: 0.766 ms


-- Посмотреть созданные вакансии
EXPLAIN ANALYSE SELECT active, vacancy_id, name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN hr_manager USING (company_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE account_id = 8;
-- Nested Loop  (cost=9.16..206.98 rows=11 width=97) (actual time=0.150..0.150 rows=0 loops=1)
--   ->  Nested Loop  (cost=8.89..204.01 rows=10 width=84) (actual time=0.148..0.149 rows=0 loops=1)
--         ->  Nested Loop  (cost=8.60..198.14 rows=10 width=17) (actual time=0.148..0.148 rows=0 loops=1)
--               ->  Index Only Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=4) (actual time=0.028..0.030 rows=1 loops=1)
--                     Index Cond: (account_id = 8)
--                     Heap Fetches: 1
--               ->  Hash Join  (cost=8.31..189.74 rows=10 width=21) (actual time=0.113..0.113 rows=0 loops=1)
--                     Hash Cond: (vacancy.company_id = hr_manager.company_id)
--                     ->  Seq Scan on vacancy  (cost=0.00..155.05 rows=10005 width=13) (actual time=0.054..0.054 rows=1 loops=1)
--                     ->  Hash  (cost=8.30..8.30 rows=1 width=8) (actual time=0.037..0.037 rows=0 loops=1)
--                           Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                           ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.036..0.036 rows=0 loops=1)
--                                 Index Cond: (account_id = 8)
--         ->  Index Scan using job_pkey on job  (cost=0.29..0.59 rows=1 width=75) (never executed)
--               Index Cond: (job_id = vacancy.job_id)
--   ->  Index Scan using company_pkey on company  (cost=0.28..0.30 rows=1 width=25) (never executed)
--         Index Cond: (company_id = vacancy.company_id)
-- Planning time: 5.706 ms
-- Execution time: 0.338 ms


-- Деактивировать вакансию #6
EXPLAIN ANALYSE UPDATE vacancy SET
    active = FALSE
WHERE vacancy_id = 6;
-- Update on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.141..0.141 rows=0 loops=1)
--   ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.041..0.044 rows=1 loops=1)
--         Index Cond: (vacancy_id = 6)
-- Planning time: 0.187 ms
-- Execution time: 0.227 ms


-- Активировать обратно вакансию #6
EXPLAIN ANALYSE UPDATE vacancy SET
    active = TRUE
WHERE vacancy_id = 6;
-- Update on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.144..0.144 rows=0 loops=1)
--   ->  Index Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=19) (actual time=0.040..0.092 rows=1 loops=1)
--         Index Cond: (vacancy_id = 6)
-- Planning time: 0.208 ms
-- Execution time: 0.230 ms

-- Посмотреть все резюме
EXPLAIN ANALYSE SELECT first_name, family_name, contact_email, contact_phone, title, city, description FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE active;
-- Hash Join  (cost=2435.56..3285.51 rows=10068 width=107) (actual time=40.345..54.544 rows=10070 loops=1)
--   Hash Cond: (resume.job_id = job.job_id)
--   ->  Hash Join  (cost=1000.38..1823.90 rows=10068 width=61) (actual time=17.092..26.497 rows=10070 loops=1)
--         Hash Cond: (account.account_id = applicant.account_id)
--         ->  Seq Scan on account  (cost=0.00..629.07 rows=25007 width=61) (actual time=0.007..2.773 rows=25010 loops=1)
--         ->  Hash  (cost=874.53..874.53 rows=10068 width=8) (actual time=17.019..17.019 rows=10070 loops=1)
--               Buckets: 16384  Batches: 1  Memory Usage: 522kB
--               ->  Hash Join  (cost=539.07..874.53 rows=10068 width=8) (actual time=4.591..13.789 rows=10070 loops=1)
--                     Hash Cond: (resume.applicant_id = applicant.applicant_id)
--                     ->  Seq Scan on resume  (cost=0.00..309.02 rows=10068 width=8) (actual time=0.006..3.419 rows=10070 loops=1)
--                           Filter: active
--                           Rows Removed by Filter: 9935
--                     ->  Hash  (cost=289.03..289.03 rows=20003 width=8) (actual time=4.471..4.471 rows=20004 loops=1)
--                           Buckets: 32768  Batches: 1  Memory Usage: 1038kB
--                           ->  Seq Scan on applicant  (cost=0.00..289.03 rows=20003 width=8) (actual time=0.006..1.721 rows=20004 loops=1)
--   ->  Hash  (cost=935.08..935.08 rows=40008 width=54) (actual time=23.176..23.176 rows=40012 loops=1)
--         Buckets: 65536  Batches: 1  Memory Usage: 3975kB
--         ->  Seq Scan on job  (cost=0.00..935.08 rows=40008 width=54) (actual time=0.014..8.544 rows=40012 loops=1)
-- Planning time: 0.978 ms
-- Execution time: 55.282 ms


-- Поиск резюме по городу, названию и зарплате
EXPLAIN ANALYSE SELECT first_name, family_name, contact_email, contact_phone, title, city, description, salary FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE 'Инженер' AND salary && '[,410000]' AND active;
-- Nested Loop  (cost=1235.73..1571.36 rows=1 width=128) (actual time=26.760..26.768 rows=2 loops=1)
--   ->  Nested Loop  (cost=1235.44..1570.96 rows=1 width=75) (actual time=26.752..26.757 rows=2 loops=1)
--         ->  Hash Join  (cost=1235.15..1570.60 rows=1 width=75) (actual time=26.736..26.738 rows=2 loops=1)
--               Hash Cond: (resume.job_id = job.job_id)
--               ->  Seq Scan on resume  (cost=0.00..309.02 rows=10068 width=8) (actual time=0.034..4.589 rows=10070 loops=1)
--                     Filter: active
--                     Rows Removed by Filter: 9935
--               ->  Hash  (cost=1235.14..1235.14 rows=1 width=75) (actual time=20.006..20.007 rows=2 loops=1)
--                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                     ->  Seq Scan on job  (cost=0.00..1235.14 rows=1 width=75) (actual time=19.992..19.996 rows=2 loops=1)
--                           Filter: (((title)::text ~~ 'Инженер'::text) AND (salary && '(,410001)'::int8range) AND ((city)::text = 'Москва'::text))
--                           Rows Removed by Filter: 40010
--         ->  Index Scan using applicant_pkey on applicant  (cost=0.29..0.36 rows=1 width=8) (actual time=0.007..0.007 rows=1 loops=2)
--               Index Cond: (applicant_id = resume.applicant_id)
--   ->  Index Scan using account_pkey on account  (cost=0.29..0.39 rows=1 width=61) (actual time=0.003..0.003 rows=1 loops=2)
--         Index Cond: (account_id = applicant.account_id)
-- Planning time: 2.044 ms
-- Execution time: 26.909 ms


-- Написать сообщение соискателю
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (8, 6, 4, 'Здравствуйте, приглашаем Вас пройти собеседование на должность исследователя!', '2019-01-25 17:01:58');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.100..0.100 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.028..0.029 rows=1 loops=1)
-- Planning time: 0.077 ms
-- Trigger for constraint message_account_id_fkey: time=0.342 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.249 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.290 calls=1
-- Execution time: 1.080 ms


-- Пришел ответ от соискателя через 1 час
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text , send)
VALUES (7, 6, 4, 'Здравствуйте, меня устроит любое время в ближайший вторник или среду.', '2019-01-25 18:01:58');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.064..0.065 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.016..0.016 rows=1 loops=1)
-- Planning time: 0.100 ms
-- Trigger for constraint message_account_id_fkey: time=0.265 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.190 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.168 calls=1
-- Execution time: 0.749 ms


-- Посмотреть диалог по вакансии 6
EXPLAIN ANALYSE SELECT send, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
WHERE vacancy_id = 6 AND resume_id =4
ORDER BY send ASC;
-- Sort  (cost=2466.98..2466.98 rows=1 width=57) (actual time=30.042..30.043 rows=2 loops=1)
--   Sort Key: message.send
--   Sort Method: quicksort  Memory: 25kB
--   ->  Nested Loop  (cost=0.86..2466.97 rows=1 width=57) (actual time=29.970..29.993 rows=2 loops=1)
--         ->  Nested Loop  (cost=0.57..2458.65 rows=1 width=57) (actual time=29.959..29.974 rows=2 loops=1)
--               ->  Nested Loop  (cost=0.29..2450.34 rows=1 width=61) (actual time=29.947..29.956 rows=2 loops=1)
--                     ->  Seq Scan on message  (cost=0.00..2442.03 rows=1 width=37) (actual time=29.920..29.922 rows=2 loops=1)
--                           Filter: ((vacancy_id = 6) AND (resume_id = 4))
--                           Rows Removed by Filter: 100005
--                     ->  Index Scan using account_pkey on account hr  (cost=0.29..8.30 rows=1 width=32) (actual time=0.012..0.012 rows=1 loops=2)
--                           Index Cond: (account_id = message.account_id)
--               ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=4) (actual time=0.007..0.007 rows=1 loops=2)
--                     Index Cond: (vacancy_id = 6)
--                     Heap Fetches: 2
--         ->  Index Only Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=4) (actual time=0.005..0.006 rows=1 loops=2)
--               Index Cond: (resume_id = 4)
--               Heap Fetches: 2
-- Planning time: 0.871 ms
-- Execution time: 30.213 ms


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
-- Insert on vacancy  (cost=0.01..0.04 rows=1 width=13) (actual time=0.070..0.071 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.045..0.046 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.013..0.013 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.054..0.056 rows=1 loops=1)
-- Planning time: 0.104 ms
-- Trigger for constraint vacancy_company_id_fkey on vacancy: time=0.185 calls=1
-- Trigger for constraint vacancy_job_id_fkey on vacancy: time=0.111 calls=1
-- Execution time: 0.425 ms


-- Пришло ещё сообщение
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (7, 6, 4, 'Проверка связи', '2019-01-20 18:23:14');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.126..0.126 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.045..0.045 rows=1 loops=1)
-- Planning time: 0.070 ms
-- Trigger for constraint message_account_id_fkey: time=0.312 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.215 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.199 calls=1
-- Execution time: 0.921 ms


-- (б) список вакансий моей компании с количествами всех и новых сообщений
EXPLAIN ANALYSE SELECT total_messages, new_messages, active, vacancy_id, title, city, description, salary FROM vacancy
JOIN
(SELECT  COUNT(message.message_id) AS total_messages, COUNT(message.message_id) - COUNT(read_message.message_id) AS new_messages, vacancy_id FROM job
    JOIN vacancy USING (job_id)
    JOIN company USING (company_id)
    JOIN hr_manager USING (company_id)
    JOIN account USING (account_id)
    LEFT JOIN message  USING (vacancy_id)
    LEFT JOIN read_message  ON (read_message.account_id = account.account_id AND message.message_id = read_message.message_id)
WHERE account.account_id = 8 AND (message.account_id != 8 OR message.account_id IS NULL)
GROUP BY vacancy_id) AS message USING (vacancy_id)
JOIN job USING (job_id);
-- Nested Loop  (cost=2596.36..2841.91 rows=110 width=92) (actual time=0.123..0.123 rows=0 loops=1)
--   ->  Hash Join  (cost=2596.07..2777.39 rows=110 width=25) (actual time=0.123..0.123 rows=0 loops=1)
--         Hash Cond: (vacancy.vacancy_id = vacancy_1.vacancy_id)
--         ->  Seq Scan on vacancy  (cost=0.00..155.05 rows=10005 width=9) (actual time=0.012..0.012 rows=1 loops=1)
--         ->  Hash  (cost=2594.69..2594.69 rows=110 width=20) (actual time=0.094..0.094 rows=0 loops=1)
--               Buckets: 1024  Batches: 1  Memory Usage: 8kB
--               ->  GroupAggregate  (cost=2590.84..2593.59 rows=110 width=20) (actual time=0.094..0.094 rows=0 loops=1)
--                     Group Key: vacancy_1.vacancy_id
--                     ->  Sort  (cost=2590.84..2591.12 rows=110 width=12) (actual time=0.093..0.093 rows=0 loops=1)
--                           Sort Key: vacancy_1.vacancy_id
--                           Sort Method: quicksort  Memory: 25kB
--                           ->  Nested Loop  (cost=196.58..2587.11 rows=110 width=12) (actual time=0.081..0.081 rows=0 loops=1)
--                                 ->  Nested Loop Left Join  (cost=196.30..2557.38 rows=100 width=20) (actual time=0.080..0.081 rows=0 loops=1)
--                                       Join Filter: (read_message.account_id = account.account_id)
--                                       ->  Nested Loop  (cost=196.01..2523.31 rows=100 width=20) (actual time=0.080..0.080 rows=0 loops=1)
--                                             ->  Index Only Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=4) (actual time=0.019..0.020 rows=1 loops=1)
--                                                   Index Cond: (account_id = 8)
--                                                   Heap Fetches: 1
--                                             ->  Hash Right Join  (cost=195.73..2514.00 rows=100 width=20) (actual time=0.059..0.059 rows=0 loops=1)
--                                                   Hash Cond: (message.vacancy_id = vacancy_1.vacancy_id)
--                                                   Filter: ((message.account_id <> 8) OR (message.account_id IS NULL))
--                                                   ->  Seq Scan on message  (cost=0.00..1942.02 rows=100002 width=12) (never executed)
--                                                   ->  Hash  (cost=195.60..195.60 rows=10 width=16) (actual time=0.046..0.046 rows=0 loops=1)
--                                                         Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                                         ->  Nested Loop  (cost=8.60..195.60 rows=10 width=16) (actual time=0.046..0.046 rows=0 loops=1)
--                                                               ->  Hash Join  (cost=8.31..189.74 rows=10 width=20) (actual time=0.045..0.045 rows=0 loops=1)
--                                                                     Hash Cond: (vacancy_1.company_id = hr_manager.company_id)
--                                                                     ->  Seq Scan on vacancy vacancy_1  (cost=0.00..155.05 rows=10005 width=12) (actual time=0.007..0.007 rows=1 loops=1)
--                                                                     ->  Hash  (cost=8.30..8.30 rows=1 width=8) (actual time=0.011..0.011 rows=0 loops=1)
--                                                                           Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                                                           ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.010..0.010 rows=0 loops=1)
--                                                                                 Index Cond: (account_id = 8)
--                                                               ->  Index Only Scan using job_pkey on job job_1  (cost=0.29..0.59 rows=1 width=4) (never executed)
--                                                                     Index Cond: (job_id = vacancy_1.job_id)
--                                                                     Heap Fetches: 0
--                                       ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.33 rows=1 width=8) (never executed)
--                                             Index Cond: ((message_id = message.message_id) AND (account_id = 8))
--                                             Heap Fetches: 0
--                                 ->  Index Only Scan using company_pkey on company  (cost=0.28..0.30 rows=1 width=4) (never executed)
--                                       Index Cond: (company_id = vacancy_1.company_id)
--                                       Heap Fetches: 0
--   ->  Index Scan using job_pkey on job  (cost=0.29..0.59 rows=1 width=75) (never executed)
--         Index Cond: (job_id = vacancy.job_id)
-- Planning time: 5.643 ms
-- Execution time: 0.348 ms


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
-- Unique  (cost=2597.05..2599.52 rows=110 width=96) (actual time=0.092..0.092 rows=0 loops=1)
--   ->  Sort  (cost=2597.05..2597.32 rows=110 width=96) (actual time=0.092..0.092 rows=0 loops=1)
--         Sort Key: (count(message.message_id) OVER (?)), ((count(message.message_id) OVER (?) - count(read_message.message_id) OVER (?))), vacancy.active, vacancy.vacancy_id, job.title, job.city, job.description, job.salary
--         Sort Method: quicksort  Memory: 25kB
--         ->  WindowAgg  (cost=2590.84..2593.32 rows=110 width=96) (actual time=0.078..0.078 rows=0 loops=1)
--               ->  Sort  (cost=2590.84..2591.12 rows=110 width=88) (actual time=0.076..0.076 rows=0 loops=1)
--                     Sort Key: message.resume_id
--                     Sort Method: quicksort  Memory: 25kB
--                     ->  Nested Loop  (cost=196.58..2587.11 rows=110 width=88) (actual time=0.073..0.073 rows=0 loops=1)
--                           ->  Nested Loop Left Join  (cost=196.30..2557.38 rows=100 width=96) (actual time=0.073..0.073 rows=0 loops=1)
--                                 Join Filter: (read_message.account_id = account.account_id)
--                                 ->  Nested Loop  (cost=196.01..2523.31 rows=100 width=96) (actual time=0.072..0.072 rows=0 loops=1)
--                                       ->  Index Only Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=4) (actual time=0.013..0.014 rows=1 loops=1)
--                                             Index Cond: (account_id = 8)
--                                             Heap Fetches: 1
--                                       ->  Hash Right Join  (cost=195.73..2514.00 rows=100 width=96) (actual time=0.056..0.056 rows=0 loops=1)
--                                             Hash Cond: (message.vacancy_id = vacancy.vacancy_id)
--                                             Filter: ((message.account_id <> 8) OR (message.account_id IS NULL))
--                                             ->  Seq Scan on message  (cost=0.00..1942.02 rows=100002 width=16) (never executed)
--                                             ->  Hash  (cost=195.60..195.60 rows=10 width=88) (actual time=0.036..0.036 rows=0 loops=1)
--                                                   Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                                   ->  Nested Loop  (cost=8.60..195.60 rows=10 width=88) (actual time=0.035..0.035 rows=0 loops=1)
--                                                         ->  Hash Join  (cost=8.31..189.74 rows=10 width=21) (actual time=0.035..0.035 rows=0 loops=1)
--                                                               Hash Cond: (vacancy.company_id = hr_manager.company_id)
--                                                               ->  Seq Scan on vacancy  (cost=0.00..155.05 rows=10005 width=13) (actual time=0.012..0.012 rows=1 loops=1)
--                                                               ->  Hash  (cost=8.30..8.30 rows=1 width=8) (actual time=0.012..0.012 rows=0 loops=1)
--                                                                     Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                                                     ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.011..0.011 rows=0 loops=1)
--                                                                           Index Cond: (account_id = 8)
--                                                         ->  Index Scan using job_pkey on job  (cost=0.29..0.59 rows=1 width=75) (never executed)
--                                                               Index Cond: (job_id = vacancy.job_id)
--                                 ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.33 rows=1 width=8) (never executed)
--                                       Index Cond: ((message_id = message.message_id) AND (account_id = 8))
--                                       Heap Fetches: 0
--                           ->  Index Only Scan using company_pkey on company  (cost=0.28..0.30 rows=1 width=4) (never executed)
--                                 Index Cond: (company_id = vacancy.company_id)
--                                 Heap Fetches: 0
-- Planning time: 4.288 ms
-- Execution time: 0.239 ms


-- прочитать сообщение #7
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (7,8);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.156..0.157 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.067..0.068 rows=1 loops=1)
-- Planning time: 0.054 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.388 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.278 calls=1
-- Execution time: 0.916 ms


-- прочитать сообщение #8
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (8,8);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.091..0.091 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.019..0.020 rows=1 loops=1)
-- Planning time: 0.052 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.326 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.233 calls=1
-- Execution time: 0.725 ms