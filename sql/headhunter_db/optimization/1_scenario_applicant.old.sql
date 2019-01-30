-- Зарегистрироваться
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('elon@musk.com', 'hash(password+salt) to be here', 'Elon', 'Musk', null, null)
        RETURNING account_id
   )
INSERT INTO applicant (account_id)
SELECT account_id FROM insert_account;
-- Insert on applicant  (cost=0.01..0.04 rows=1 width=8) (actual time=0.236..0.237 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.142..0.143 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.026..0.026 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=8) (actual time=0.158..0.160 rows=1 loops=1)
-- Planning time: 0.149 ms
-- Trigger for constraint applicant_account_id_fkey on applicant: time=0.387 calls=1
-- Execution time: 0.934 ms


-- Залогиниться
EXPLAIN ANALYSE SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'elon@musk.com';
-- Nested Loop Left Join  (cost=0.86..24.91 rows=1 width=19) (actual time=0.054..0.058 rows=1 loops=1)
--   ->  Nested Loop Left Join  (cost=0.57..16.61 rows=1 width=15) (actual time=0.044..0.048 rows=1 loops=1)
--         ->  Index Scan using account_login_key on account  (cost=0.29..8.30 rows=1 width=11) (actual time=0.029..0.031 rows=1 loops=1)
--               Index Cond: ((login)::text = 'elon@musk.com'::text)
--         ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.009..0.009 rows=1 loops=1)
--               Index Cond: (account.account_id = account_id)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.28..8.30 rows=1 width=8) (actual time=0.007..0.007 rows=0 loops=1)
--         Index Cond: (account.account_id = account_id)
-- Planning time: 1.698 ms
-- Execution time: 0.270 ms


-- Отредактировать личные данные
EXPLAIN ANALYSE  UPDATE account SET
    first_name = 'Илон',
    family_name = 'Маск',
    contact_email = 'e.musk@spacex.com',
    contact_phone = 2342355678
WHERE account_id = 7;
-- Update on account  (cost=0.29..8.30 rows=1 width=1594) (actual time=0.240..0.240 rows=0 loops=1)
--   ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=1594) (actual time=0.035..0.039 rows=1 loops=1)
--         Index Cond: (account_id = 7)
-- Planning time: 0.221 ms
-- Execution time: 0.339 ms


-- Посмотреть личные данные
EXPLAIN ANALYSE  SELECT first_name, family_name, contact_email, contact_phone FROM account
WHERE account_id = 7;
-- Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=57) (actual time=0.029..0.079 rows=1 loops=1)
--   Index Cond: (account_id = 7)
-- Planning time: 0.289 ms
-- Execution time: 0.138 ms


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
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.223..0.223 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.116..0.117 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.021..0.021 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.130..0.132 rows=1 loops=1)
-- Planning time: 0.120 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.320 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.288 calls=1
-- Execution time: 0.975 ms


-- Посмотреть свои резюме
EXPLAIN ANALYSE SELECT active, resume_id, first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM job
    JOIN resume USING (job_id)
    JOIN applicant USING (applicant_id)
    JOIN account USING (account_id)
WHERE account_id = 7;
-- Nested Loop  (cost=8.89..378.62 rows=1 width=133) (actual time=7.350..9.826 rows=2 loops=1)
--   ->  Nested Loop  (cost=8.61..370.30 rows=1 width=80) (actual time=7.339..9.803 rows=2 loops=1)
--         ->  Hash Join  (cost=8.32..369.85 rows=1 width=13) (actual time=7.313..9.761 rows=2 loops=1)
--               Hash Cond: (resume.applicant_id = applicant.applicant_id)
--               ->  Seq Scan on resume  (cost=0.00..309.02 rows=20002 width=13) (actual time=0.017..4.256 rows=20003 loops=1)
--               ->  Hash  (cost=8.30..8.30 rows=1 width=8) (actual time=0.017..0.017 rows=1 loops=1)
--                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                     ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.011..0.013 rows=1 loops=1)
--                           Index Cond: (account_id = 7)
--         ->  Index Scan using job_pkey on job  (cost=0.29..0.45 rows=1 width=75) (actual time=0.014..0.014 rows=1 loops=2)
--               Index Cond: (job_id = resume.job_id)
--   ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=61) (actual time=0.008..0.009 rows=1 loops=2)
--         Index Cond: (account_id = 7)
-- Planning time: 1.126 ms
-- Execution time: 9.914 ms


-- Деактивировать резюме #3
EXPLAIN ANALYSE UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;
-- Update on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.145..0.145 rows=0 loops=1)
--   ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.035..0.039 rows=1 loops=1)
--         Index Cond: (resume_id = 3)
-- Planning time: 0.178 ms
-- Execution time: 0.230 ms


-- Редактировать резюме #3
EXPLAIN ANALYSE UPDATE job SET
    salary = '[430000, 520000]'
WHERE job_id = (SELECT job_id FROM resume WHERE resume_id = 3) ;
-- Update on job  (cost=8.59..16.61 rows=1 width=92) (actual time=0.309..0.309 rows=0 loops=1)
--   InitPlan 1 (returns $0)
--     ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=4) (actual time=0.042..0.126 rows=1 loops=1)
--           Index Cond: (resume_id = 3)
--   ->  Index Scan using job_pkey on job  (cost=0.29..8.31 rows=1 width=92) (actual time=0.163..0.167 rows=1 loops=1)
--         Index Cond: (job_id = $0)
-- Planning time: 0.402 ms
-- Execution time: 0.464 ms


-- Активировать обратно резюме #3
EXPLAIN ANALYSE UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;
-- Update on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.078..0.078 rows=0 loops=1)
--   ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=19) (actual time=0.036..0.039 rows=1 loops=1)
--         Index Cond: (resume_id = 3)
-- Planning time: 0.161 ms
-- Execution time: 0.141 ms


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
-- Delete on job  (cost=2242.33..2250.43 rows=1 width=82) (actual time=0.029..0.029 rows=0 loops=1)
--   CTE to_delete
--     ->  Nested Loop Left Join  (cost=0.87..2217.02 rows=1 width=16) (actual time=0.020..0.020 rows=0 loops=1)
--           ->  Nested Loop Left Join  (cost=0.58..2208.70 rows=1 width=12) (actual time=0.019..0.020 rows=0 loops=1)
--                 Join Filter: (resume.resume_id = message.resume_id)
--                 ->  Nested Loop  (cost=0.58..16.61 rows=1 width=8) (actual time=0.019..0.019 rows=0 loops=1)
--                       ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=8) (actual time=0.018..0.018 rows=0 loops=1)
--                             Index Cond: (resume_id = 20004)
--                       ->  Index Only Scan using job_pkey on job job_1  (cost=0.29..8.31 rows=1 width=4) (never executed)
--                             Index Cond: (job_id = resume.job_id)
--                             Heap Fetches: 0
--                 ->  Seq Scan on message  (cost=0.00..2192.03 rows=5 width=8) (never executed)
--                       Filter: (resume_id = 20004)
--           ->  Index Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..8.31 rows=1 width=8) (never executed)
--                 Index Cond: (message.message_id = message_id)
--   CTE delete_read_message
--     ->  Delete on read_message read_message_1  (cost=0.31..8.34 rows=1 width=34) (actual time=0.002..0.002 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.31..8.34 rows=1 width=34) (actual time=0.001..0.001 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.001..0.001 rows=0 loops=1)
--                       Group Key: to_delete.read_message_id
--                       ->  CTE Scan on to_delete  (cost=0.00..0.02 rows=1 width=32) (actual time=0.000..0.000 rows=0 loops=1)
--                 ->  Index Scan using read_message_pkey on read_message read_message_1  (cost=0.29..8.31 rows=1 width=10) (never executed)
--                       Index Cond: (read_message_id = to_delete.read_message_id)
--   CTE delete_message
--     ->  Delete on message message_1  (cost=0.32..8.34 rows=1 width=34) (actual time=0.002..0.002 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.32..8.34 rows=1 width=34) (actual time=0.002..0.002 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.001..0.001 rows=0 loops=1)
--                       Group Key: to_delete_1.message_id
--                       ->  CTE Scan on to_delete to_delete_1  (cost=0.00..0.02 rows=1 width=32) (actual time=0.001..0.001 rows=0 loops=1)
--                 ->  Index Scan using message_pkey on message message_1  (cost=0.29..8.31 rows=1 width=10) (never executed)
--                       Index Cond: (message_id = to_delete_1.message_id)
--   CTE delete_resume
--     ->  Delete on resume resume_1  (cost=0.31..8.34 rows=1 width=34) (actual time=0.024..0.025 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.31..8.34 rows=1 width=34) (actual time=0.023..0.023 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.023..0.023 rows=0 loops=1)
--                       Group Key: to_delete_2.resume_id
--                       ->  CTE Scan on to_delete to_delete_2  (cost=0.00..0.02 rows=1 width=32) (actual time=0.021..0.021 rows=0 loops=1)
--                 ->  Index Scan using resume_pkey on resume resume_1  (cost=0.29..8.30 rows=1 width=10) (never executed)
--                       Index Cond: (resume_id = to_delete_2.resume_id)
--   ->  Nested Loop  (cost=0.29..8.39 rows=1 width=82) (actual time=0.028..0.028 rows=0 loops=1)
--         ->  Nested Loop  (cost=0.29..8.36 rows=1 width=58) (actual time=0.027..0.027 rows=0 loops=1)
--               ->  Nested Loop  (cost=0.29..8.33 rows=1 width=34) (actual time=0.027..0.027 rows=0 loops=1)
--                     ->  CTE Scan on delete_resume  (cost=0.00..0.02 rows=1 width=32) (actual time=0.026..0.026 rows=0 loops=1)
--                     ->  Index Scan using job_pkey on job  (cost=0.29..8.31 rows=1 width=10) (never executed)
--                           Index Cond: (job_id = delete_resume.job_id)
--               ->  CTE Scan on delete_read_message  (cost=0.00..0.02 rows=1 width=24) (never executed)
--         ->  CTE Scan on delete_message  (cost=0.00..0.02 rows=1 width=24) (never executed)
-- Planning time: 1.826 ms
-- Execution time: 0.288 ms


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
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.211..0.215 rows=1 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.096..0.099 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.026..0.027 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.174..0.178 rows=1 loops=1)
-- Planning time: 0.285 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.484 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.331 calls=1
-- Execution time: 1.197 ms


-- Посмотреть все вакансии
EXPLAIN ANALYSE SELECT name, title, city, description,salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE active;
-- Hash Join  (cost=488.23..621.67 rows=4961 width=92) (actual time=7.520..15.239 rows=4961 loops=1)
--   Hash Cond: (vacancy.company_id = company.company_id)
--   ->  Merge Join  (cost=459.86..580.22 rows=4961 width=75) (actual time=6.470..10.992 rows=4961 loops=1)
--         Merge Cond: (job.job_id = vacancy.job_id)
--         ->  Index Scan using job_pkey on job  (cost=0.29..1791.42 rows=40008 width=75) (actual time=0.016..0.946 rows=956 loops=1)
--         ->  Sort  (cost=459.57..471.97 rows=4961 width=8) (actual time=6.445..7.214 rows=4961 loops=1)
--               Sort Key: vacancy.job_id
--               Sort Method: quicksort  Memory: 425kB
--               ->  Seq Scan on vacancy  (cost=0.00..155.05 rows=4961 width=8) (actual time=0.016..3.678 rows=4961 loops=1)
--                     Filter: active
--                     Rows Removed by Filter: 5044
--   ->  Hash  (cost=16.50..16.50 rows=950 width=25) (actual time=1.034..1.034 rows=950 loops=1)
--         Buckets: 1024  Batches: 1  Memory Usage: 63kB
--         ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=25) (actual time=0.020..0.486 rows=950 loops=1)
-- Planning time: 0.955 ms
-- Execution time: 15.850 ms


-- Поиск активных вакансий по городу и названию и чтоб платили много
EXPLAIN ANALYSE SELECT name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE '%Инженер%' AND salary && '[600000,]' AND active;
-- Nested Loop  (cost=1235.43..1403.53 rows=1 width=92) (actual time=19.894..22.355 rows=1 loops=1)
--   ->  Hash Join  (cost=1235.15..1403.23 rows=1 width=75) (actual time=19.876..22.336 rows=1 loops=1)
--         Hash Cond: (vacancy.job_id = job.job_id)
--         ->  Seq Scan on vacancy  (cost=0.00..155.05 rows=4961 width=8) (actual time=0.016..1.654 rows=4961 loops=1)
--               Filter: active
--               Rows Removed by Filter: 5044
--         ->  Hash  (cost=1235.14..1235.14 rows=1 width=75) (actual time=19.843..19.843 rows=1 loops=1)
--               Buckets: 1024  Batches: 1  Memory Usage: 9kB
--               ->  Seq Scan on job  (cost=0.00..1235.14 rows=1 width=75) (actual time=0.015..19.838 rows=1 loops=1)
--                     Filter: (((title)::text ~~ '%Инженер%'::text) AND (salary && '[600000,)'::int8range) AND ((city)::text = 'Москва'::text))
--                     Rows Removed by Filter: 40009
--   ->  Index Scan using company_pkey on company  (cost=0.28..0.30 rows=1 width=25) (actual time=0.014..0.014 rows=1 loops=1)
--         Index Cond: (company_id = vacancy.company_id)
-- Planning time: 0.690 ms
-- Execution time: 22.457 ms


-- Написать сообщение
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (7, 5, 4, 'Здравствуйте, меня заинтересовала вакансия инженера ЦПИР в Москве, я монго работал над созданием очень сложных систем управления для космической техники.', '2019-01-20 14:52:02');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.181..0.181 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.036..0.037 rows=1 loops=1)
-- Planning time: 0.075 ms
-- Trigger for constraint message_account_id_fkey: time=0.577 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.423 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.344 calls=1
-- Execution time: 1.599 ms


-- Пришел ответ от hr менеджера через 30 мин
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (6, 5, 4, 'Здравствуйте, приглашаем Вас на собеседование в четверг 15.05 в 16:30.', '2019-01-20 15:22:02');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.111..0.111 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.027..0.028 rows=1 loops=1)
-- Planning time: 0.095 ms
-- Trigger for constraint message_account_id_fkey: time=0.449 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.318 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.410 calls=1
-- Execution time: 1.386 ms


-- Посмотреть диалог по паре резюме 4 вакансия 5
EXPLAIN ANALYSE SELECT send, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
WHERE resume_id = 4 AND vacancy_id=5
ORDER BY send ASC ;
-- Sort  (cost=2466.98..2466.98 rows=1 width=57) (actual time=15.861..15.861 rows=2 loops=1)
--   Sort Key: message.send
--   Sort Method: quicksort  Memory: 25kB
--   ->  Nested Loop  (cost=0.86..2466.97 rows=1 width=57) (actual time=15.833..15.848 rows=2 loops=1)
--         ->  Nested Loop  (cost=0.57..2458.65 rows=1 width=57) (actual time=15.817..15.827 rows=2 loops=1)
--               ->  Nested Loop  (cost=0.29..2450.34 rows=1 width=61) (actual time=15.784..15.790 rows=2 loops=1)
--                     ->  Seq Scan on message  (cost=0.00..2442.03 rows=1 width=37) (actual time=15.760..15.762 rows=2 loops=1)
--                           Filter: ((vacancy_id = 5) AND (resume_id = 4))
--                           Rows Removed by Filter: 100002
--                     ->  Index Scan using account_pkey on account hr  (cost=0.29..8.30 rows=1 width=32) (actual time=0.010..0.010 rows=1 loops=2)
--                           Index Cond: (account_id = message.account_id)
--               ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.29..8.30 rows=1 width=4) (actual time=0.017..0.017 rows=1 loops=2)
--                     Index Cond: (vacancy_id = 5)
--                     Heap Fetches: 2
--         ->  Index Only Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=4) (actual time=0.006..0.007 rows=1 loops=2)
--               Index Cond: (resume_id = 4)
--               Heap Fetches: 2
-- Planning time: 0.704 ms
-- Execution time: 15.952 ms


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
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.133..0.133 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.080..0.082 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.033..0.034 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.099..0.102 rows=1 loops=1)
-- Planning time: 0.191 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.310 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.197 calls=1
-- Execution time: 0.749 ms


-- Пришло еще одно сообщение от hr менеджера
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (6, 5, 4, 'Извините, но в связи с непредвиденными обстоятельствами собеседование переносится на 20.05 в 16:30.', '2019-01-20 15:28:25');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.114..0.114 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.022..0.023 rows=1 loops=1)
-- Planning time: 0.102 ms
-- Trigger for constraint message_account_id_fkey: time=0.450 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.344 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.316 calls=1
-- Execution time: 1.349 ms


-- (а) список моих резюме с количеством всех сообщений и количеством новых сообщений
EXPLAIN ANALYSE SELECT total_messages, new_messages, active, resume_id, first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM resume
JOIN
(SELECT  COUNT(message.message_id) AS total_messages, COUNT(message.message_id) - COUNT(read_message.message_id) AS new_messages, resume_id FROM job
    JOIN resume USING (job_id)
    JOIN applicant USING (applicant_id)
    JOIN account USING (account_id)
    LEFT JOIN message  USING (resume_id)
    LEFT JOIN read_message  ON (read_message.account_id = account.account_id AND message.message_id = read_message.message_id)
WHERE account.account_id = 7 AND (message.account_id != 7 OR message.account_id IS NULL)
GROUP BY resume_id) AS messages USING (resume_id)
JOIN job USING (job_id)
JOIN applicant USING (applicant_id)
JOIN account USING (account_id);
-- Nested Loop  (cost=2698.67..2745.10 rows=5 width=149) (actual time=37.145..37.174 rows=4 loops=1)
--   ->  Nested Loop  (cost=2698.39..2743.13 rows=5 width=96) (actual time=37.137..37.160 rows=4 loops=1)
--         ->  Nested Loop  (cost=2698.10..2741.46 rows=5 width=96) (actual time=37.128..37.146 rows=4 loops=1)
--               ->  Nested Loop  (cost=2697.81..2739.22 rows=5 width=29) (actual time=37.120..37.130 rows=4 loops=1)
--                     ->  GroupAggregate  (cost=2697.52..2697.65 rows=5 width=20) (actual time=37.101..37.104 rows=4 loops=1)
--                           Group Key: resume_1.resume_id
--                           ->  Sort  (cost=2697.52..2697.53 rows=5 width=12) (actual time=37.094..37.095 rows=7 loops=1)
--                                 Sort Key: resume_1.resume_id
--                                 Sort Method: quicksort  Memory: 25kB
--                                 ->  Nested Loop Left Join  (cost=370.89..2697.46 rows=5 width=12) (actual time=16.785..37.074 rows=7 loops=1)
--                                       Join Filter: (read_message.account_id = account_1.account_id)
--                                       ->  Nested Loop  (cost=370.60..2695.76 rows=5 width=12) (actual time=16.762..37.012 rows=7 loops=1)
--                                             ->  Index Only Scan using account_pkey on account account_1  (cost=0.29..8.30 rows=1 width=4) (actual time=0.056..0.058 rows=1 loops=1)
--                                                   Index Cond: (account_id = 7)
--                                                   Heap Fetches: 1
--                                             ->  Hash Right Join  (cost=370.31..2687.40 rows=5 width=12) (actual time=16.702..36.947 rows=7 loops=1)
--                                                   Hash Cond: (message.resume_id = resume_1.resume_id)
--                                                   Filter: ((message.account_id <> 7) OR (message.account_id IS NULL))
--                                                   ->  Seq Scan on message  (cost=0.00..1942.02 rows=100002 width=12) (actual time=0.030..10.575 rows=100005 loops=1)
--                                                   ->  Hash  (cost=370.30..370.30 rows=1 width=8) (actual time=13.710..13.710 rows=4 loops=1)
--                                                         Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                         ->  Nested Loop  (cost=8.61..370.30 rows=1 width=8) (actual time=11.587..13.703 rows=4 loops=1)
--                                                               ->  Hash Join  (cost=8.32..369.85 rows=1 width=12) (actual time=11.537..13.633 rows=4 loops=1)
--                                                                     Hash Cond: (resume_1.applicant_id = applicant_1.applicant_id)
--                                                                     ->  Seq Scan on resume resume_1  (cost=0.00..309.02 rows=20002 width=12) (actual time=0.026..5.928 rows=20005 loops=1)
--                                                                     ->  Hash  (cost=8.30..8.30 rows=1 width=8) (actual time=0.028..0.028 rows=1 loops=1)
--                                                                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                                           ->  Index Scan using applicant_account_id_key on applicant applicant_1  (cost=0.29..8.30 rows=1 width=8) (actual time=0.019..0.022 rows=1 loops=1)
--                                                                                 Index Cond: (account_id = 7)
--                                                               ->  Index Only Scan using job_pkey on job job_1  (cost=0.29..0.45 rows=1 width=4) (actual time=0.014..0.014 rows=1 loops=4)
--                                                                     Index Cond: (job_id = resume_1.job_id)
--                                                                     Heap Fetches: 4
--                                       ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.33 rows=1 width=8) (actual time=0.007..0.007 rows=0 loops=7)
--                                             Index Cond: ((message_id = message.message_id) AND (account_id = 7))
--                                             Heap Fetches: 0
--                     ->  Index Scan using resume_pkey on resume  (cost=0.29..8.30 rows=1 width=13) (actual time=0.005..0.005 rows=1 loops=4)
--                           Index Cond: (resume_id = resume_1.resume_id)
--               ->  Index Scan using job_pkey on job  (cost=0.29..0.45 rows=1 width=75) (actual time=0.003..0.003 rows=1 loops=4)
--                     Index Cond: (job_id = resume.job_id)
--         ->  Index Scan using applicant_pkey on applicant  (cost=0.29..0.33 rows=1 width=8) (actual time=0.003..0.003 rows=1 loops=4)
--               Index Cond: (applicant_id = resume.applicant_id)
--   ->  Index Scan using account_pkey on account  (cost=0.29..0.39 rows=1 width=61) (actual time=0.003..0.003 rows=1 loops=4)
--         Index Cond: (account_id = applicant.account_id)
-- Planning time: 4.904 ms
-- Execution time: 37.441 ms


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
-- Unique  (cost=2697.69..2697.85 rows=5 width=149) (actual time=37.733..37.739 rows=4 loops=1)
--   ->  Sort  (cost=2697.69..2697.70 rows=5 width=149) (actual time=37.732..37.732 rows=7 loops=1)
--         Sort Key: (count(message.message_id) OVER (?)), ((count(message.message_id) OVER (?) - count(read_message.message_id) OVER (?))), resume.active, resume.resume_id, account.first_name, account.family_name, account.contact_phone, account.contact_email, job.title, job.city, job.description, job.salary
--         Sort Method: quicksort  Memory: 28kB
--         ->  WindowAgg  (cost=2697.52..2697.63 rows=5 width=149) (actual time=37.668..37.674 rows=7 loops=1)
--               ->  Sort  (cost=2697.52..2697.53 rows=5 width=141) (actual time=37.659..37.660 rows=7 loops=1)
--                     Sort Key: resume.resume_id
--                     Sort Method: quicksort  Memory: 28kB
--                     ->  Nested Loop Left Join  (cost=370.89..2697.46 rows=5 width=141) (actual time=11.376..37.632 rows=7 loops=1)
--                           Join Filter: (read_message.account_id = account.account_id)
--                           ->  Nested Loop  (cost=370.60..2695.76 rows=5 width=141) (actual time=11.272..37.489 rows=7 loops=1)
--                                 ->  Index Scan using account_pkey on account  (cost=0.29..8.30 rows=1 width=61) (actual time=0.006..0.008 rows=1 loops=1)
--                                       Index Cond: (account_id = 7)
--                                 ->  Hash Right Join  (cost=370.31..2687.40 rows=5 width=84) (actual time=11.258..37.470 rows=7 loops=1)
--                                       Hash Cond: (message.resume_id = resume.resume_id)
--                                       Filter: ((message.account_id <> 7) OR (message.account_id IS NULL))
--                                       ->  Seq Scan on message  (cost=0.00..1942.02 rows=100002 width=12) (actual time=0.032..13.381 rows=100005 loops=1)
--                                       ->  Hash  (cost=370.30..370.30 rows=1 width=80) (actual time=7.618..7.618 rows=4 loops=1)
--                                             Buckets: 1024  Batches: 1  Memory Usage: 10kB
--                                             ->  Nested Loop  (cost=8.61..370.30 rows=1 width=80) (actual time=4.452..7.606 rows=4 loops=1)
--                                                   ->  Hash Join  (cost=8.32..369.85 rows=1 width=13) (actual time=4.425..7.528 rows=4 loops=1)
--                                                         Hash Cond: (resume.applicant_id = applicant.applicant_id)
--                                                         ->  Seq Scan on resume  (cost=0.00..309.02 rows=20002 width=13) (actual time=0.009..3.287 rows=20005 loops=1)
--                                                         ->  Hash  (cost=8.30..8.30 rows=1 width=8) (actual time=0.007..0.007 rows=1 loops=1)
--                                                               Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                               ->  Index Scan using applicant_account_id_key on applicant  (cost=0.29..8.30 rows=1 width=8) (actual time=0.004..0.005 rows=1 loops=1)
--                                                                     Index Cond: (account_id = 7)
--                                                   ->  Index Scan using job_pkey on job  (cost=0.29..0.45 rows=1 width=75) (actual time=0.014..0.014 rows=1 loops=4)
--                                                         Index Cond: (job_id = resume.job_id)
--                           ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.33 rows=1 width=8) (actual time=0.015..0.015 rows=0 loops=7)
--                                 Index Cond: ((message_id = message.message_id) AND (account_id = 7))
--                                 Heap Fetches: 0
-- Planning time: 1.377 ms
-- Execution time: 37.895 ms


-- прочитать сообщение #4
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (4,7);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.379..0.379 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.197..0.198 rows=1 loops=1)
-- Planning time: 0.055 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.533 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.525 calls=1
-- Execution time: 1.522 ms


-- прочитать сообщение #5
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (5,7);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.072..0.072 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.015..0.016 rows=1 loops=1)
-- Planning time: 0.040 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.247 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.167 calls=1
-- Execution time: 0.543 ms