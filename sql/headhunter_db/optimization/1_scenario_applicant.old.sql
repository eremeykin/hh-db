-- Зарегистрироваться
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('elon@musk.com', 'hash(password+salt) to be here', 'Elon', 'Musk', null, null)
        RETURNING account_id
   )
INSERT INTO applicant (account_id)
SELECT account_id FROM insert_account;
--  Insert on applicant  (cost=0.01..0.04 rows=1 width=8) (actual time=10867.440..10867.440 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=10022.850..10022.854 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=7216.200..7216.201 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=8) (actual time=10420.573..10420.580 rows=1 loops=1)
-- Planning time: 0.084 ms
-- Trigger for constraint applicant_account_id_fkey on applicant: time=1.071 calls=1
-- Execution time: 10868.654 ms

-- Залогиниться
EXPLAIN ANALYSE SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'elon@musk.com';
-- Nested Loop Left Join  (cost=1.28..25.33 rows=1 width=19) (actual time=0.072..0.075 rows=1 loops=1)
--   ->  Nested Loop Left Join  (cost=0.86..16.89 rows=1 width=15) (actual time=0.060..0.063 rows=1 loops=1)
--         ->  Index Scan using account_login_key on account  (cost=0.43..8.45 rows=1 width=11) (actual time=0.041..0.043 rows=1 loops=1)
--               Index Cond: ((login)::text = 'elon@musk.com'::text)
--         ->  Index Scan using applicant_account_id_key on applicant  (cost=0.43..8.45 rows=1 width=8) (actual time=0.012..0.012 rows=1 loops=1)
--               Index Cond: (account.account_id = account_id)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..8.44 rows=1 width=8) (actual time=0.009..0.010 rows=0 loops=1)
--         Index Cond: (account.account_id = account_id)
-- Planning time: 1009.670 ms
-- Execution time: 0.181 ms

-- Отредактировать личные данные
EXPLAIN ANALYSE  UPDATE account SET
    first_name = 'Илон',
    family_name = 'Маск',
    contact_email = 'e.musk@spacex.com',
    contact_phone = 2342355678
WHERE account_id = 7;
-- Update on account  (cost=0.43..8.45 rows=1 width=1596) (actual time=207.235..207.235 rows=0 loops=1)
--   ->  Index Scan using account_pkey on account  (cost=0.43..8.45 rows=1 width=1596) (actual time=0.044..0.046 rows=1 loops=1)
--         Index Cond: (account_id = 7)
-- Planning time: 0.115 ms
-- Execution time: 207.280 ms

-- Посмотреть личные данные
EXPLAIN ANALYSE  SELECT first_name, family_name, contact_email, contact_phone FROM account
WHERE account_id = 7;
-- Index Scan using account_pkey on account  (cost=0.43..8.45 rows=1 width=59) (actual time=0.025..0.058 rows=1 loops=1)
--   Index Cond: (account_id = 7)
-- Planning time: 0.308 ms
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
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=1769.139..1769.140 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=1766.795..1766.800 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=249.156..249.159 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=1768.590..1768.601 rows=1 loops=1)
-- Planning time: 0.221 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.988 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.591 calls=1
-- Execution time: 1770.962 ms

-- Посмотреть свои резюме
EXPLAIN ANALYSE SELECT active, resume_id, first_name, family_name, contact_phone, contact_email, title, city, description, salary FROM job
    JOIN resume USING (job_id)
    JOIN applicant USING (applicant_id)
    JOIN account USING (account_id)
WHERE account_id = 7;
-- Nested Loop  (cost=1009.32..22349.44 rows=1 width=134) (actual time=285.159..285.202 rows=2 loops=1)
--   ->  Nested Loop  (cost=1008.89..22340.98 rows=1 width=79) (actual time=285.143..285.182 rows=2 loops=1)
--         ->  Gather  (cost=1008.46..22340.40 rows=1 width=13) (actual time=75.616..75.712 rows=2 loops=1)
--               Workers Planned: 2
--               Workers Launched: 2
--               ->  Hash Join  (cost=8.46..21340.30 rows=1 width=13) (actual time=138.297..138.306 rows=1 loops=3)
--                     Hash Cond: (resume.applicant_id = applicant.applicant_id)
--                     ->  Parallel Seq Scan on resume  (cost=0.00..19144.34 rows=833334 width=13) (actual time=0.039..63.132 rows=666668 loops=3)
--                     ->  Hash  (cost=8.45..8.45 rows=1 width=8) (actual time=0.036..0.036 rows=1 loops=3)
--                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                           ->  Index Scan using applicant_account_id_key on applicant  (cost=0.43..8.45 rows=1 width=8) (actual time=0.029..0.030 rows=1 loops=3)
--                                 Index Cond: (account_id = 7)
--         ->  Index Scan using job_pkey on job  (cost=0.43..0.58 rows=1 width=74) (actual time=104.764..104.764 rows=1 loops=2)
--               Index Cond: (job_id = resume.job_id)
--   ->  Index Scan using account_pkey on account  (cost=0.43..8.45 rows=1 width=63) (actual time=0.008..0.008 rows=1 loops=2)
--         Index Cond: (account_id = 7)
-- Planning time: 393.953 ms
-- Execution time: 285.315 ms

-- Деактивировать резюме #3
EXPLAIN ANALYSE UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;
-- Update on resume  (cost=0.43..8.45 rows=1 width=19) (actual time=0.199..0.199 rows=0 loops=1)
--   ->  Index Scan using resume_pkey on resume  (cost=0.43..8.45 rows=1 width=19) (actual time=0.088..0.090 rows=1 loops=1)
--         Index Cond: (resume_id = 3)
-- Planning time: 0.119 ms
-- Execution time: 0.257 ms

-- Редактировать резюме #3
EXPLAIN ANALYSE UPDATE job SET
    salary = '[430000, 520000]'
WHERE job_id = (SELECT job_id FROM resume WHERE resume_id = 3) ;
-- Update on job  (cost=8.88..16.89 rows=1 width=90) (actual time=1474.433..1474.433 rows=0 loops=1)
--   InitPlan 1 (returns $0)
--     ->  Index Scan using resume_pkey on resume  (cost=0.43..8.45 rows=1 width=4) (actual time=0.024..0.049 rows=1 loops=1)
--           Index Cond: (resume_id = 3)
--   ->  Index Scan using job_pkey on job  (cost=0.43..8.45 rows=1 width=90) (actual time=1046.014..1046.019 rows=1 loops=1)
--         Index Cond: (job_id = $0)
-- Planning time: 0.130 ms
-- Execution time: 1474.507 ms

-- Активировать обратно резюме #3
EXPLAIN ANALYSE UPDATE resume SET
    active = FALSE
WHERE resume_id = 3;
-- Update on resume  (cost=0.43..8.45 rows=1 width=19) (actual time=0.137..0.137 rows=0 loops=1)
--   ->  Index Scan using resume_pkey on resume  (cost=0.43..8.45 rows=1 width=19) (actual time=0.060..0.065 rows=1 loops=1)
--         Index Cond: (resume_id = 3)
-- Planning time: 0.242 ms
-- Execution time: 0.255 ms

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
-- Delete on job  (cost=12626.95..12635.05 rows=1 width=82) (actual time=142.873..142.873 rows=0 loops=1)
--   CTE to_delete
--     ->  Nested Loop Left Join  (cost=1.15..12601.23 rows=1 width=16) (actual time=111.130..111.132 rows=1 loops=1)
--           ->  Nested Loop Left Join  (cost=0.86..12592.92 rows=1 width=12) (actual time=111.120..111.122 rows=1 loops=1)
--                 Join Filter: (resume.resume_id = message.resume_id)
--                 ->  Nested Loop  (cost=0.86..12.89 rows=1 width=8) (actual time=38.994..38.996 rows=1 loops=1)
--                       ->  Index Scan using resume_pkey on resume  (cost=0.43..8.45 rows=1 width=8) (actual time=0.025..0.026 rows=1 loops=1)
--                             Index Cond: (resume_id = 20004)
--                       ->  Index Only Scan using job_pkey on job job_1  (cost=0.43..4.45 rows=1 width=4) (actual time=38.966..38.966 rows=1 loops=1)
--                             Index Cond: (job_id = resume.job_id)
--                             Heap Fetches: 0
--                 ->  Seq Scan on message  (cost=0.00..12580.01 rows=1 width=8) (actual time=72.123..72.123 rows=0 loops=1)
--                       Filter: (resume_id = 20004)
--                       Rows Removed by Filter: 570002
--           ->  Index Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..8.30 rows=1 width=8) (actual time=0.006..0.006 rows=0 loops=1)
--                 Index Cond: (message.message_id = message_id)
--   CTE delete_read_message
--     ->  Delete on read_message read_message_1  (cost=0.31..8.34 rows=1 width=34) (actual time=0.026..0.026 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.31..8.34 rows=1 width=34) (actual time=0.025..0.025 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.020..0.020 rows=1 loops=1)
--                       Group Key: to_delete.read_message_id
--                       ->  CTE Scan on to_delete  (cost=0.00..0.02 rows=1 width=32) (actual time=0.013..0.014 rows=1 loops=1)
--                 ->  Index Scan using read_message_pkey on read_message read_message_1  (cost=0.29..8.30 rows=1 width=10) (actual time=0.003..0.003 rows=0 loops=1)
--                       Index Cond: (read_message_id = to_delete.read_message_id)
--   CTE delete_message
--     ->  Delete on message message_1  (cost=0.45..8.48 rows=1 width=34) (actual time=0.006..0.006 rows=0 loops=1)
--           ->  Nested Loop  (cost=0.45..8.48 rows=1 width=34) (actual time=0.005..0.005 rows=0 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=0.004..0.004 rows=1 loops=1)
--                       Group Key: to_delete_1.message_id
--                       ->  CTE Scan on to_delete to_delete_1  (cost=0.00..0.02 rows=1 width=32) (actual time=0.002..0.002 rows=1 loops=1)
--                 ->  Index Scan using message_pkey on message message_1  (cost=0.42..8.44 rows=1 width=10) (actual time=0.001..0.001 rows=0 loops=1)
--                       Index Cond: (message_id = to_delete_1.message_id)
--   CTE delete_resume
--     ->  Delete on resume resume_1  (cost=0.45..8.48 rows=1 width=34) (actual time=111.176..111.178 rows=1 loops=1)
--           ->  Nested Loop  (cost=0.45..8.48 rows=1 width=34) (actual time=111.159..111.159 rows=1 loops=1)
--                 ->  HashAggregate  (cost=0.02..0.03 rows=1 width=32) (actual time=111.148..111.149 rows=1 loops=1)
--                       Group Key: to_delete_2.resume_id
--                       ->  CTE Scan on to_delete to_delete_2  (cost=0.00..0.02 rows=1 width=32) (actual time=111.141..111.144 rows=1 loops=1)
--                 ->  Index Scan using resume_pkey on resume resume_1  (cost=0.43..8.45 rows=1 width=10) (actual time=0.009..0.009 rows=1 loops=1)
--                       Index Cond: (resume_id = to_delete_2.resume_id)
--   ->  Nested Loop  (cost=0.43..8.53 rows=1 width=82) (actual time=142.872..142.872 rows=0 loops=1)
--         ->  Nested Loop  (cost=0.43..8.50 rows=1 width=58) (actual time=142.871..142.871 rows=0 loops=1)
--               ->  Nested Loop  (cost=0.43..8.47 rows=1 width=34) (actual time=142.840..142.843 rows=1 loops=1)
--                     ->  CTE Scan on delete_resume  (cost=0.00..0.02 rows=1 width=32) (actual time=111.180..111.181 rows=1 loops=1)
--                     ->  Index Scan using job_pkey on job  (cost=0.43..8.45 rows=1 width=10) (actual time=31.658..31.659 rows=1 loops=1)
--                           Index Cond: (job_id = delete_resume.job_id)
--               ->  CTE Scan on delete_read_message  (cost=0.00..0.02 rows=1 width=24) (actual time=0.026..0.026 rows=0 loops=1)
--         ->  CTE Scan on delete_message  (cost=0.00..0.02 rows=1 width=24) (never executed)
-- Planning time: 3.883 ms
-- Trigger for constraint message_resume_id_fkey on resume: time=50.043 calls=1
-- Execution time: 193.050 ms

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
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.058..0.060 rows=1 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.038..0.039 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.010..0.010 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.045..0.046 rows=1 loops=1)
-- Planning time: 0.088 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.143 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.088 calls=1
-- Execution time: 0.341 ms

-- Посмотреть все вакансии
EXPLAIN ANALYSE SELECT name, title, city, description,salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE active;
-- Hash Join  (cost=70564.01..80188.61 rows=503536 width=91) (actual time=241.073..626.291 rows=500005 loops=1)
--   Hash Cond: (vacancy.company_id = company.company_id)
--   ->  Merge Join  (cost=70535.64..78832.55 rows=503536 width=74) (actual time=240.407..543.248 rows=500005 loops=1)
--         Merge Cond: (job.job_id = vacancy.job_id)
--         ->  Index Scan using job_pkey on job  (cost=0.43..171452.18 rows=3999842 width=74) (actual time=0.015..145.830 rows=956 loops=1)
--         ->  Materialize  (cost=69979.78..72497.46 rows=503536 width=8) (actual time=240.385..332.398 rows=500005 loops=1)
--               ->  Sort  (cost=69979.78..71238.62 rows=503536 width=8) (actual time=240.382..291.772 rows=500005 loops=1)
--                     Sort Key: vacancy.job_id
--                     Sort Method: external merge  Disk: 8856kB
--                     ->  Seq Scan on vacancy  (cost=0.00..15406.05 rows=503536 width=8) (actual time=0.038..114.026 rows=500005 loops=1)
--                           Filter: active
--                           Rows Removed by Filter: 500000
--   ->  Hash  (cost=16.50..16.50 rows=950 width=25) (actual time=0.653..0.653 rows=950 loops=1)
--         Buckets: 1024  Batches: 1  Memory Usage: 63kB
--         ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=25) (actual time=0.011..0.313 rows=950 loops=1)
-- Planning time: 40.396 ms
-- Execution time: 642.859 ms

-- Поиск активных вакансий по городу и названию и чтоб платили много
EXPLAIN ANALYSE SELECT name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE '%Инженер%' AND salary && '[600000,]' AND active;
-- Nested Loop  (cost=83582.90..100310.75 rows=1 width=91) (actual time=8743.650..8940.158 rows=1 loops=1)
--   ->  Hash Join  (cost=83582.63..100310.46 rows=1 width=74) (actual time=8743.604..8940.111 rows=1 loops=1)
--         Hash Cond: (vacancy.job_id = job.job_id)
--         ->  Seq Scan on vacancy  (cost=0.00..15406.05 rows=503536 width=8) (actual time=0.081..133.546 rows=500005 loops=1)
--               Filter: active
--               Rows Removed by Filter: 500000
--         ->  Hash  (cost=83582.61..83582.61 rows=1 width=74) (actual time=8743.483..8743.483 rows=1 loops=1)
--               Buckets: 1024  Batches: 1  Memory Usage: 9kB
--               ->  Gather  (cost=1000.00..83582.61 rows=1 width=74) (actual time=0.835..8743.527 rows=1 loops=1)
--                     Workers Planned: 2
--                     Workers Launched: 2
--                     ->  Parallel Seq Scan on job  (cost=0.00..82582.51 rows=1 width=74) (actual time=5819.846..8733.779 rows=0 loops=3)
--                           Filter: (((title)::text ~~ '%Инженер%'::text) AND (salary && '[600000,)'::int8range) AND ((city)::text = 'Москва'::text))
--                           Rows Removed by Filter: 1333336
--   ->  Index Scan using company_pkey on company  (cost=0.28..0.29 rows=1 width=25) (actual time=0.034..0.034 rows=1 loops=1)
--         Index Cond: (company_id = vacancy.company_id)
-- Planning time: 1.172 ms
-- Execution time: 8940.327 ms

-- Написать сообщение
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (7, 5, 4, 'Здравствуйте, меня заинтересовала вакансия инженера ЦПИР в Москве, я монго работал над созданием очень сложных систем управления для космической техники.', '2019-01-20 14:52:02');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.277..0.277 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.181..0.182 rows=1 loops=1)
-- Planning time: 0.050 ms
-- Trigger for constraint message_account_id_fkey: time=0.410 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.517 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.238 calls=1
-- Execution time: 1.490 ms

-- Пришел ответ от hr менеджера через 30 мин
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (6, 5, 4, 'Здравствуйте, приглашаем Вас на собеседование в четверг 15.05 в 16:30.', '2019-01-20 15:22:02');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.132..0.132 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.028..0.029 rows=1 loops=1)
-- Planning time: 0.042 ms
-- Trigger for constraint message_account_id_fkey: time=0.920 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.379 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.092 calls=1
-- Execution time: 1.579 ms

-- Посмотреть диалог по паре резюме 4 вакансия 5
EXPLAIN ANALYSE SELECT send, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
WHERE resume_id = 4 AND vacancy_id=5
ORDER BY send ASC ;
-- Sort  (cost=10039.48..10039.48 rows=1 width=57) (actual time=38.024..38.024 rows=2 loops=1)
--   Sort Key: message.send
--   Sort Method: quicksort  Memory: 25kB
--   ->  Nested Loop  (cost=1001.28..10039.47 rows=1 width=57) (actual time=37.994..38.014 rows=2 loops=1)
--         ->  Nested Loop  (cost=1000.85..10035.01 rows=1 width=57) (actual time=37.984..38.000 rows=2 loops=1)
--               ->  Nested Loop  (cost=1000.43..10030.55 rows=1 width=61) (actual time=37.975..37.987 rows=2 loops=1)
--                     ->  Gather  (cost=1000.00..10022.11 rows=1 width=37) (actual time=37.941..39.717 rows=2 loops=1)
--                           Workers Planned: 2
--                           Workers Launched: 2
--                           ->  Parallel Seq Scan on message  (cost=0.00..9022.01 rows=1 width=37) (actual time=34.717..34.717 rows=1 loops=3)
--                                 Filter: ((vacancy_id = 5) AND (resume_id = 4))
--                                 Rows Removed by Filter: 190001
--                     ->  Index Scan using account_pkey on account hr  (cost=0.43..8.45 rows=1 width=32) (actual time=0.011..0.011 rows=1 loops=2)
--                           Index Cond: (account_id = message.account_id)
--               ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.42..4.44 rows=1 width=4) (actual time=0.006..0.006 rows=1 loops=2)
--                     Index Cond: (vacancy_id = 5)
--                     Heap Fetches: 0
--         ->  Index Only Scan using resume_pkey on resume  (cost=0.43..4.45 rows=1 width=4) (actual time=0.004..0.005 rows=1 loops=2)
--               Index Cond: (resume_id = 4)
--               Heap Fetches: 0
-- Planning time: 0.445 ms
-- Execution time: 39.860 ms

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
-- Insert on resume  (cost=0.01..0.04 rows=1 width=13) (actual time=0.066..0.066 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.041..0.042 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.011..0.011 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.048..0.050 rows=1 loops=1)
-- Planning time: 0.113 ms
-- Trigger for constraint resume_applicant_id_fkey on resume: time=0.146 calls=1
-- Trigger for constraint resume_job_id_fkey on resume: time=0.098 calls=1
-- Execution time: 0.365 ms

-- Пришло еще одно сообщение от hr менеджера
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (6, 5, 4, 'Извините, но в связи с непредвиденными обстоятельствами собеседование переносится на 20.05 в 16:30.', '2019-01-20 15:28:25');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.044..0.044 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.011..0.011 rows=1 loops=1)
-- Planning time: 0.037 ms
-- Trigger for constraint message_account_id_fkey: time=0.162 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.102 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.102 calls=1
-- Execution time: 0.444 ms

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
-- Nested Loop  (cost=35639.02..35647.39 rows=1 width=150) (actual time=241.221..241.249 rows=4 loops=1)
--   ->  Nested Loop  (cost=35638.59..35646.84 rows=1 width=95) (actual time=241.217..241.239 rows=4 loops=1)
--         ->  Nested Loop  (cost=35638.16..35646.37 rows=1 width=95) (actual time=241.212..241.228 rows=4 loops=1)
--               ->  Nested Loop  (cost=35637.73..35645.79 rows=1 width=29) (actual time=241.207..241.218 rows=4 loops=1)
--                     ->  GroupAggregate  (cost=35637.31..35637.33 rows=1 width=20) (actual time=241.183..241.185 rows=4 loops=1)
--                           Group Key: resume_1.resume_id
--                           ->  Sort  (cost=35637.31..35637.31 rows=1 width=12) (actual time=241.178..241.179 rows=4 loops=1)
--                                 Sort Key: resume_1.resume_id
--                                 Sort Method: quicksort  Memory: 25kB
--                                 ->  Nested Loop Left Join  (cost=22341.56..35637.30 rows=1 width=12) (actual time=241.151..241.170 rows=4 loops=1)
--                                       Join Filter: (read_message.account_id = account_1.account_id)
--                                       ->  Nested Loop  (cost=22341.27..35636.97 rows=1 width=12) (actual time=241.149..241.166 rows=4 loops=1)
--                                             ->  Nested Loop  (cost=22340.84..35632.52 rows=1 width=12) (actual time=241.142..241.153 rows=4 loops=1)
--                                                   ->  Hash Right Join  (cost=22340.41..35632.04 rows=1 width=16) (actual time=241.124..241.125 rows=4 loops=1)
--                                                         Hash Cond: (message.resume_id = resume_1.resume_id)
--                                                         Filter: ((message.account_id <> 7) OR (message.account_id IS NULL))
--                                                         ->  Seq Scan on message  (cost=0.00..11156.81 rows=569281 width=12) (actual time=0.008..40.323 rows=570005 loops=1)
--                                                         ->  Hash  (cost=22340.40..22340.40 rows=1 width=12) (actual time=149.230..149.230 rows=4 loops=1)
--                                                               Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                               ->  Gather  (cost=1008.46..22340.40 rows=1 width=12) (actual time=149.144..149.278 rows=4 loops=1)
--                                                                     Workers Planned: 2
--                                                                     Workers Launched: 2
--                                                                     ->  Hash Join  (cost=8.46..21340.30 rows=1 width=12) (actual time=107.534..144.048 rows=1 loops=3)
--                                                                           Hash Cond: (resume_1.applicant_id = applicant_1.applicant_id)
--                                                                           ->  Parallel Seq Scan on resume resume_1  (cost=0.00..19144.34 rows=833334 width=12) (actual time=0.021..64.944 rows=666668 loops=3)
--                                                                           ->  Hash  (cost=8.45..8.45 rows=1 width=8) (actual time=0.023..0.023 rows=1 loops=3)
--                                                                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                                                 ->  Index Scan using applicant_account_id_key on applicant applicant_1  (cost=0.43..8.45 rows=1 width=8) (actual time=0.015..0.016 rows=1 loops=3)
--                                                                                       Index Cond: (account_id = 7)
--                                                   ->  Index Only Scan using job_pkey on job job_1  (cost=0.43..0.48 rows=1 width=4) (actual time=0.005..0.005 rows=1 loops=4)
--                                                         Index Cond: (job_id = resume_1.job_id)
--                                                         Heap Fetches: 3
--                                             ->  Index Only Scan using account_pkey on account account_1  (cost=0.43..4.45 rows=1 width=4) (actual time=0.002..0.003 rows=1 loops=4)
--                                                   Index Cond: (account_id = 7)
--                                                   Heap Fetches: 4
--                                       ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.31 rows=1 width=8) (actual time=0.000..0.000 rows=0 loops=4)
--                                             Index Cond: ((message_id = message.message_id) AND (account_id = 7))
--                                             Heap Fetches: 0
--                     ->  Index Scan using resume_pkey on resume  (cost=0.43..8.45 rows=1 width=13) (actual time=0.007..0.007 rows=1 loops=4)
--                           Index Cond: (resume_id = resume_1.resume_id)
--               ->  Index Scan using job_pkey on job  (cost=0.43..0.58 rows=1 width=74) (actual time=0.002..0.002 rows=1 loops=4)
--                     Index Cond: (job_id = resume.job_id)
--         ->  Index Scan using applicant_pkey on applicant  (cost=0.43..0.47 rows=1 width=8) (actual time=0.002..0.002 rows=1 loops=4)
--               Index Cond: (applicant_id = resume.applicant_id)
--   ->  Index Scan using account_pkey on account  (cost=0.43..0.54 rows=1 width=63) (actual time=0.001..0.001 rows=1 loops=4)
--         Index Cond: (account_id = applicant.account_id)
-- Planning time: 1.779 ms
-- Execution time: 241.446 ms

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
-- Unique  (cost=35641.45..35641.48 rows=1 width=150) (actual time=247.930..247.935 rows=4 loops=1)
--   ->  Sort  (cost=35641.45..35641.45 rows=1 width=150) (actual time=247.929..247.930 rows=4 loops=1)
--         Sort Key: (count(message.message_id) OVER (?)), ((count(message.message_id) OVER (?) - count(read_message.message_id) OVER (?))), resume.active, resume.resume_id, account.first_name, account.family_name, account.contact_phone, account.contact_email, job.title, job.city, job.description, job.salary
--         Sort Method: quicksort  Memory: 27kB
--         ->  WindowAgg  (cost=35641.41..35641.44 rows=1 width=150) (actual time=247.879..247.883 rows=4 loops=1)
--               ->  Sort  (cost=35641.41..35641.42 rows=1 width=142) (actual time=247.872..247.872 rows=4 loops=1)
--                     Sort Key: resume.resume_id
--                     Sort Method: quicksort  Memory: 27kB
--                     ->  Nested Loop Left Join  (cost=22341.56..35641.40 rows=1 width=142) (actual time=247.844..247.863 rows=4 loops=1)
--                           Join Filter: (read_message.account_id = account.account_id)
--                           ->  Nested Loop  (cost=22341.27..35641.08 rows=1 width=142) (actual time=247.842..247.859 rows=4 loops=1)
--                                 ->  Nested Loop  (cost=22340.84..35632.62 rows=1 width=83) (actual time=247.834..247.845 rows=4 loops=1)
--                                       ->  Hash Right Join  (cost=22340.41..35632.04 rows=1 width=17) (actual time=247.817..247.819 rows=4 loops=1)
--                                             Hash Cond: (message.resume_id = resume.resume_id)
--                                             Filter: ((message.account_id <> 7) OR (message.account_id IS NULL))
--                                             ->  Seq Scan on message  (cost=0.00..11156.81 rows=569281 width=12) (actual time=0.009..41.376 rows=570005 loops=1)
--                                             ->  Hash  (cost=22340.40..22340.40 rows=1 width=13) (actual time=154.053..154.053 rows=4 loops=1)
--                                                   Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                   ->  Gather  (cost=1008.46..22340.40 rows=1 width=13) (actual time=154.022..154.105 rows=4 loops=1)
--                                                         Workers Planned: 2
--                                                         Workers Launched: 2
--                                                         ->  Hash Join  (cost=8.46..21340.30 rows=1 width=13) (actual time=110.357..146.619 rows=1 loops=3)
--                                                               Hash Cond: (resume.applicant_id = applicant.applicant_id)
--                                                               ->  Parallel Seq Scan on resume  (cost=0.00..19144.34 rows=833334 width=13) (actual time=0.019..64.393 rows=666668 loops=3)
--                                                               ->  Hash  (cost=8.45..8.45 rows=1 width=8) (actual time=0.019..0.019 rows=1 loops=3)
--                                                                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                                     ->  Index Scan using applicant_account_id_key on applicant  (cost=0.43..8.45 rows=1 width=8) (actual time=0.014..0.015 rows=1 loops=3)
--                                                                           Index Cond: (account_id = 7)
--                                       ->  Index Scan using job_pkey on job  (cost=0.43..0.58 rows=1 width=74) (actual time=0.005..0.005 rows=1 loops=4)
--                                             Index Cond: (job_id = resume.job_id)
--                                 ->  Index Scan using account_pkey on account  (cost=0.43..8.45 rows=1 width=63) (actual time=0.003..0.003 rows=1 loops=4)
--                                       Index Cond: (account_id = 7)
--                           ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.31 rows=1 width=8) (actual time=0.000..0.000 rows=0 loops=4)
--                                 Index Cond: ((message_id = message.message_id) AND (account_id = 7))
--                                 Heap Fetches: 0
-- Planning time: 1.847 ms
-- Execution time: 248.157 ms

-- прочитать сообщение #4
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (4,7);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.186..0.186 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.097..0.098 rows=1 loops=1)
-- Planning time: 0.034 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.361 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.268 calls=1
-- Execution time: 0.868 ms

-- прочитать сообщение #5
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (5,7);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.042..0.042 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.009..0.009 rows=1 loops=1)
-- Planning time: 0.024 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.144 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.095 calls=1
-- Execution time: 0.313 ms