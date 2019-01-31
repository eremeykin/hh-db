-- Зарегистрироваться
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('kukushkin@hepi.ru', 'id6AWf3g', 'Руслан', 'Кукушкин', 'kukushkin@hepi.ru', 71354572398)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id)
SELECT account_id FROM insert_account;
-- Insert on hr_manager  (cost=0.01..0.04 rows=1 width=12) (actual time=82.391..82.392 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.132..0.135 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.019..0.020 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=12) (actual time=34.003..34.010 rows=1 loops=1)
-- Planning time: 0.100 ms
-- Trigger for constraint hr_manager_account_id_fkey on hr_manager: time=0.618 calls=1
-- Trigger for constraint hr_manager_company_id_fkey on hr_manager: time=0.052 calls=1
-- Execution time: 83.140 ms

-- Залогиниться
EXPLAIN ANALYSE SELECT password, account_id, applicant_id, hr_manager_id FROM account
LEFT JOIN applicant USING (account_id)
LEFT JOIN hr_manager USING (account_id)
WHERE login = 'kukushkin@hepi.ru';
-- Nested Loop Left Join  (cost=1.28..25.33 rows=1 width=19) (actual time=0.029..0.030 rows=1 loops=1)
--   ->  Nested Loop Left Join  (cost=0.86..16.89 rows=1 width=15) (actual time=0.024..0.025 rows=1 loops=1)
--         ->  Index Scan using account_login_key on account  (cost=0.43..8.45 rows=1 width=11) (actual time=0.016..0.016 rows=1 loops=1)
--               Index Cond: ((login)::text = 'kukushkin@hepi.ru'::text)
--         ->  Index Scan using applicant_account_id_key on applicant  (cost=0.43..8.45 rows=1 width=8) (actual time=0.006..0.006 rows=0 loops=1)
--               Index Cond: (account.account_id = account_id)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..8.44 rows=1 width=8) (actual time=0.004..0.004 rows=1 loops=1)
--         Index Cond: (account.account_id = account_id)
-- Planning time: 0.332 ms
-- Execution time: 0.064 ms

-- Создать компанию
EXPLAIN ANALYSE WITH insert_company AS (
        INSERT INTO company (name)
        VALUES ('Институт физики высоких энергий')
        RETURNING company_id
    )
UPDATE hr_manager SET
        company_id = (SELECT company_id from insert_company)
WHERE account_id = 8;
-- Update on hr_manager  (cost=0.46..8.47 rows=1 width=18) (actual time=0.022..0.022 rows=0 loops=1)
--   CTE insert_company
--     ->  Insert on company  (cost=0.00..0.01 rows=1 width=520) (actual time=55.878..55.880 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=520) (actual time=38.302..38.303 rows=1 loops=1)
--   InitPlan 2 (returns $2)
--     ->  CTE Scan on insert_company  (cost=0.00..0.02 rows=1 width=4) (never executed)
--   ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..8.44 rows=1 width=18) (actual time=0.021..0.021 rows=0 loops=1)
--         Index Cond: (account_id = 8)
-- Planning time: 0.223 ms
-- Execution time: 55.972 ms

--Посмотреть компании
EXPLAIN ANALYSE SELECT name, first_name, family_name, contact_email, contact_phone FROM company
JOIN hr_manager USING (company_id)
JOIN account USING (account_id);
-- Hash Join  (cost=32929.40..79796.44 rows=499461 width=80) (actual time=0.622..7565.639 rows=499461 loops=1)
--   Hash Cond: (hr_manager.company_id = company.company_id)
--   ->  Merge Join  (cost=32901.02..78451.12 rows=499461 width=63) (actual time=0.035..7406.508 rows=499462 loops=1)
--         Merge Cond: (hr_manager.account_id = account.account_id)
--         ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..15683.34 rows=499461 width=8) (actual time=0.016..127.707 rows=499462 loops=1)
--         ->  Index Scan using account_pkey on account  (cost=0.43..112721.07 rows=2500120 width=63) (actual time=0.013..6700.587 rows=2500009 loops=1)
--   ->  Hash  (cost=16.50..16.50 rows=950 width=25) (actual time=0.577..0.577 rows=951 loops=1)
--         Buckets: 1024  Batches: 1  Memory Usage: 63kB
--         ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=25) (actual time=0.011..0.257 rows=951 loops=1)
-- Planning time: 0.618 ms
-- Execution time: 7592.158 ms

-- Зарегистрируем ещё одного hr менеджера, так как в компании их может быть несколько
EXPLAIN ANALYSE WITH insert_account AS (
        INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
        VALUES ('ezhikov@mail.ru', 'EzhhIG', 'Артемий', 'Ежиков', 'a.ezhikov@hepi.ru', 71359847532)
        RETURNING account_id
   )
INSERT INTO hr_manager (account_id, company_id)
SELECT account_id,4 FROM insert_account;
-- Insert on hr_manager  (cost=0.01..0.04 rows=1 width=12) (actual time=34.064..34.064 rows=0 loops=1)
--   CTE insert_account
--     ->  Insert on account  (cost=0.00..0.01 rows=1 width=2592) (actual time=33.767..33.771 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=2592) (actual time=0.104..0.106 rows=1 loops=1)
--   ->  CTE Scan on insert_account  (cost=0.00..0.03 rows=1 width=12) (actual time=33.875..33.881 rows=1 loops=1)
-- Planning time: 0.071 ms
-- Trigger for constraint hr_manager_account_id_fkey on hr_manager: time=0.500 calls=1
-- Trigger for constraint hr_manager_company_id_fkey on hr_manager: time=0.606 calls=1
-- Execution time: 35.240 ms

-- Посмотреть менеджеров компании
EXPLAIN ANALYSE SELECT login, first_name, family_name FROM hr_manager
JOIN account USING (account_id)
WHERE company_id = 4;
-- Gather  (cost=1000.43..9926.43 rows=512 width=51) (actual time=1.134..50.994 rows=546 loops=1)
--   Workers Planned: 1
--   Workers Launched: 1
--   ->  Nested Loop  (cost=0.43..8875.23 rows=301 width=51) (actual time=0.385..27.093 rows=273 loops=2)
--         ->  Parallel Seq Scan on hr_manager  (cost=0.00..6372.51 rows=301 width=4) (actual time=0.339..23.923 rows=273 loops=2)
--               Filter: (company_id = 4)
--               Rows Removed by Filter: 249458
--         ->  Index Scan using account_pkey on account  (cost=0.43..8.31 rows=1 width=55) (actual time=0.011..0.011 rows=1 loops=546)
--               Index Cond: (account_id = hr_manager.account_id)
-- Planning time: 0.600 ms
-- Execution time: 51.094 ms

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
-- Insert on vacancy  (cost=0.01..0.04 rows=1 width=13) (actual time=39.244..39.245 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.148..0.151 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.075..0.076 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=39.023..39.028 rows=1 loops=1)
-- Planning time: 0.118 ms
-- Trigger for constraint vacancy_company_id_fkey on vacancy: time=0.472 calls=1
-- Trigger for constraint vacancy_job_id_fkey on vacancy: time=0.252 calls=1
-- Execution time: 40.050 ms

-- Посмотреть созданные вакансии
EXPLAIN ANALYSE SELECT active, vacancy_id, name, title, city, description, salary FROM vacancy
JOIN company USING (company_id)
JOIN hr_manager USING (company_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE account_id = 8;
-- Nested Loop  (cost=11869.49..11939.14 rows=1053 width=96) (actual time=4.300..4.300 rows=0 loops=1)
--   ->  Index Only Scan using account_pkey on account  (cost=0.43..4.45 rows=1 width=4) (actual time=0.038..0.041 rows=1 loops=1)
--         Index Cond: (account_id = 8)
--         Heap Fetches: 0
--   ->  Merge Join  (cost=11869.06..11924.16 rows=1053 width=100) (actual time=4.257..4.257 rows=0 loops=1)
--         Merge Cond: (job.job_id = vacancy.job_id)
--         ->  Index Scan using job_pkey on job  (cost=0.43..171452.18 rows=3999842 width=74) (actual time=0.009..0.009 rows=1 loops=1)
--         ->  Sort  (cost=11867.47..11870.10 rows=1053 width=34) (actual time=4.246..4.246 rows=0 loops=1)
--               Sort Key: vacancy.job_id
--               Sort Method: quicksort  Memory: 25kB
--               ->  Gather  (cost=1036.83..11814.61 rows=1053 width=34) (actual time=4.240..5.636 rows=0 loops=1)
--                     Workers Planned: 2
--                     Workers Launched: 2
--                     ->  Hash Join  (cost=36.83..10709.31 rows=439 width=34) (actual time=0.124..0.124 rows=0 loops=3)
--                           Hash Cond: (vacancy.company_id = company.company_id)
--                           ->  Hash Join  (cost=8.45..10679.78 rows=439 width=21) (actual time=0.123..0.123 rows=0 loops=3)
--                                 Hash Cond: (vacancy.company_id = hr_manager.company_id)
--                                 ->  Parallel Seq Scan on vacancy  (cost=0.00..9572.69 rows=416669 width=13) (actual time=0.018..0.018 rows=1 loops=3)
--                                 ->  Hash  (cost=8.44..8.44 rows=1 width=8) (actual time=0.013..0.013 rows=0 loops=3)
--                                       Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                       ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..8.44 rows=1 width=8) (actual time=0.013..0.013 rows=0 loops=3)
--                                             Index Cond: (account_id = 8)
--                           ->  Hash  (cost=16.50..16.50 rows=950 width=25) (never executed)
--                                 ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=25) (never executed)
-- Planning time: 1.401 ms
-- Execution time: 5.775 ms

-- Деактивировать вакансию #6
EXPLAIN ANALYSE UPDATE vacancy SET
    active = FALSE
WHERE vacancy_id = 6;
-- Update on vacancy  (cost=0.42..8.44 rows=1 width=19) (actual time=0.155..0.156 rows=0 loops=1)
--   ->  Index Scan using vacancy_pkey on vacancy  (cost=0.42..8.44 rows=1 width=19) (actual time=0.078..0.081 rows=1 loops=1)
--         Index Cond: (vacancy_id = 6)
-- Planning time: 0.113 ms
-- Execution time: 0.207 ms


-- Активировать обратно вакансию #6
EXPLAIN ANALYSE UPDATE vacancy SET
    active = TRUE
WHERE vacancy_id = 6;
-- Update on vacancy  (cost=0.42..8.44 rows=1 width=19) (actual time=0.120..0.120 rows=0 loops=1)
--   ->  Index Scan using vacancy_pkey on vacancy  (cost=0.42..8.44 rows=1 width=19) (actual time=0.034..0.079 rows=1 loops=1)
--         Index Cond: (vacancy_id = 6)
-- Planning time: 0.135 ms
-- Execution time: 0.188 ms

-- Посмотреть все резюме
EXPLAIN ANALYSE SELECT first_name, family_name, contact_email, contact_phone, title, city, description FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE active;
-- Hash Join  (cost=309685.93..514040.47 rows=1003001 width=107) (actual time=2771.483..5274.569 rows=999588 loops=1)
--   Hash Cond: (resume.job_id = job.job_id)
--   ->  Hash Join  (cost=127211.49..268322.15 rows=1003001 width=63) (actual time=1222.199..2808.518 rows=999588 loops=1)
--         Hash Cond: (account.account_id = applicant.account_id)
--         ->  Seq Scan on account  (cost=0.00..64073.20 rows=2500120 width=63) (actual time=0.006..386.053 rows=2500010 loops=1)
--         ->  Hash  (cost=110755.98..110755.98 rows=1003001 width=8) (actual time=1222.001..1222.001 rows=999588 loops=1)
--               Buckets: 131072  Batches: 16  Memory Usage: 3489kB
--               ->  Hash Join  (cost=61663.07..110755.98 rows=1003001 width=8) (actual time=365.617..1084.059 rows=999588 loops=1)
--                     Hash Cond: (resume.applicant_id = applicant.applicant_id)
--                     ->  Seq Scan on resume  (cost=0.00..30811.02 rows=1003001 width=8) (actual time=0.024..197.206 rows=999588 loops=1)
--                           Filter: active
--                           Rows Removed by Filter: 1000416
--                     ->  Hash  (cost=28850.03..28850.03 rows=2000003 width=8) (actual time=365.218..365.218 rows=2000004 loops=1)
--                           Buckets: 131072  Batches: 32  Memory Usage: 3477kB
--                           ->  Seq Scan on applicant  (cost=0.00..28850.03 rows=2000003 width=8) (actual time=0.007..133.546 rows=2000004 loops=1)
--   ->  Hash  (cost=93415.42..93415.42 rows=3999842 width=52) (actual time=1547.954..1547.954 rows=4000012 loops=1)
--         Buckets: 65536  Batches: 128  Memory Usage: 3221kB
--         ->  Seq Scan on job  (cost=0.00..93415.42 rows=3999842 width=52) (actual time=0.009..570.932 rows=4000012 loops=1)
-- Planning time: 0.953 ms
-- Execution time: 5305.100 ms

-- Поиск резюме по городу, названию и зарплате
EXPLAIN ANALYSE SELECT first_name, family_name, contact_email, contact_phone, title, city, description, salary FROM resume
JOIN applicant USING (applicant_id)
JOIN account USING (account_id)
JOIN job USING (job_id)
WHERE city='Москва' AND title LIKE 'Инженер' AND salary && '[,410000]' AND active;
-- Nested Loop  (cost=83583.48..117027.57 rows=1 width=129) (actual time=507.353..507.359 rows=2 loops=1)
--   ->  Nested Loop  (cost=83583.05..117027.03 rows=1 width=74) (actual time=507.345..507.349 rows=2 loops=1)
--         ->  Hash Join  (cost=83582.63..117026.52 rows=1 width=74) (actual time=507.330..507.331 rows=2 loops=1)
--               Hash Cond: (resume.job_id = job.job_id)
--               ->  Seq Scan on resume  (cost=0.00..30811.02 rows=1003001 width=8) (actual time=0.040..181.557 rows=999588 loops=1)
--                     Filter: active
--                     Rows Removed by Filter: 1000416
--               ->  Hash  (cost=83582.61..83582.61 rows=1 width=74) (actual time=240.976..240.976 rows=2 loops=1)
--                     Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                     ->  Gather  (cost=1000.00..83582.61 rows=1 width=74) (actual time=240.965..241.020 rows=2 loops=1)
--                           Workers Planned: 2
--                           Workers Launched: 2
--                           ->  Parallel Seq Scan on job  (cost=0.00..82582.51 rows=1 width=74) (actual time=237.756..237.757 rows=1 loops=3)
--                                 Filter: (((title)::text ~~ 'Инженер'::text) AND (salary && '(,410001)'::int8range) AND ((city)::text = 'Москва'::text))
--                                 Rows Removed by Filter: 1333337
--         ->  Index Scan using applicant_pkey on applicant  (cost=0.43..0.50 rows=1 width=8) (actual time=0.006..0.006 rows=1 loops=2)
--               Index Cond: (applicant_id = resume.applicant_id)
--   ->  Index Scan using account_pkey on account  (cost=0.43..0.54 rows=1 width=63) (actual time=0.004..0.004 rows=1 loops=2)
--         Index Cond: (account_id = applicant.account_id)
-- Planning time: 0.990 ms
-- Execution time: 507.479 ms

-- Написать сообщение соискателю
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (8, 6, 4, 'Здравствуйте, приглашаем Вас пройти собеседование на должность исследователя!', '2019-01-25 17:01:58');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.145..0.145 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.072..0.073 rows=1 loops=1)
-- Planning time: 0.046 ms
-- Trigger for constraint message_account_id_fkey: time=0.231 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.145 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.185 calls=1
-- Execution time: 0.748 ms

-- Пришел ответ от соискателя через 1 час
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text , send)
VALUES (7, 6, 4, 'Здравствуйте, меня устроит любое время в ближайший вторник или среду.', '2019-01-25 18:01:58');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.043..0.043 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.010..0.011 rows=1 loops=1)
-- Planning time: 0.035 ms
-- Trigger for constraint message_account_id_fkey: time=0.155 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.098 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.081 calls=1
-- Execution time: 0.408 ms


-- Посмотреть диалог по вакансии 6
EXPLAIN ANALYSE SELECT send, hr.first_name || ' ' ||  hr.family_name AS name, text  FROM message
JOIN account hr USING (account_id)
JOIN vacancy USING (vacancy_id)
JOIN resume USING (resume_id)
WHERE vacancy_id = 6 AND resume_id =4
ORDER BY send ASC;
-- Sort  (cost=10039.48..10039.48 rows=1 width=57) (actual time=41.081..41.082 rows=2 loops=1)
--   Sort Key: message.send
--   Sort Method: quicksort  Memory: 25kB
--   ->  Nested Loop  (cost=1001.28..10039.47 rows=1 width=57) (actual time=39.895..41.069 rows=2 loops=1)
--         ->  Nested Loop  (cost=1000.85..10035.01 rows=1 width=57) (actual time=39.884..41.054 rows=2 loops=1)
--               ->  Nested Loop  (cost=1000.43..10030.55 rows=1 width=61) (actual time=39.873..41.037 rows=2 loops=1)
--                     ->  Gather  (cost=1000.00..10022.11 rows=1 width=37) (actual time=39.837..42.079 rows=2 loops=1)
--                           Workers Planned: 2
--                           Workers Launched: 2
--                           ->  Parallel Seq Scan on message  (cost=0.00..9022.01 rows=1 width=37) (actual time=36.185..36.186 rows=1 loops=3)
--                                 Filter: ((vacancy_id = 6) AND (resume_id = 4))
--                                 Rows Removed by Filter: 190002
--                     ->  Index Scan using account_pkey on account hr  (cost=0.43..8.45 rows=1 width=32) (actual time=0.015..0.015 rows=1 loops=2)
--                           Index Cond: (account_id = message.account_id)
--               ->  Index Only Scan using vacancy_pkey on vacancy  (cost=0.42..4.44 rows=1 width=4) (actual time=0.007..0.007 rows=1 loops=2)
--                     Index Cond: (vacancy_id = 6)
--                     Heap Fetches: 2
--         ->  Index Only Scan using resume_pkey on resume  (cost=0.43..4.45 rows=1 width=4) (actual time=0.005..0.006 rows=1 loops=2)
--               Index Cond: (resume_id = 4)
--               Heap Fetches: 0
-- Planning time: 0.446 ms
-- Execution time: 42.232 ms

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
-- Insert on vacancy  (cost=0.01..0.04 rows=1 width=13) (actual time=0.067..0.067 rows=0 loops=1)
--   CTE insert_job
--     ->  Insert on job  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.041..0.042 rows=1 loops=1)
--           ->  Result  (cost=0.00..0.01 rows=1 width=1584) (actual time=0.010..0.011 rows=1 loops=1)
--   ->  CTE Scan on insert_job  (cost=0.00..0.03 rows=1 width=13) (actual time=0.049..0.051 rows=1 loops=1)
-- Planning time: 0.092 ms
-- Trigger for constraint vacancy_company_id_fkey on vacancy: time=0.147 calls=1
-- Trigger for constraint vacancy_job_id_fkey on vacancy: time=0.101 calls=1
-- Execution time: 0.369 ms

-- Пришло ещё сообщение
EXPLAIN ANALYSE INSERT INTO message (account_id, vacancy_id, resume_id, text, send)
VALUES (7, 6, 4, 'Проверка связи', '2019-01-20 18:23:14');
-- Insert on message  (cost=0.00..0.01 rows=1 width=540) (actual time=0.056..0.056 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=540) (actual time=0.013..0.013 rows=1 loops=1)
-- Planning time: 0.087 ms
-- Trigger for constraint message_account_id_fkey: time=0.251 calls=1
-- Trigger for constraint message_vacancy_id_fkey: time=0.193 calls=1
-- Trigger for constraint message_resume_id_fkey: time=0.193 calls=1
-- Execution time: 0.748 ms

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
-- Merge Join  (cost=33720.33..33775.43 rows=1053 width=91) (actual time=4.604..4.604 rows=0 loops=1)
--   Merge Cond: (job.job_id = vacancy.job_id)
--   ->  Index Scan using job_pkey on job  (cost=0.43..171452.18 rows=3999842 width=74) (actual time=0.017..0.017 rows=1 loops=1)
--   ->  Sort  (cost=33718.74..33721.37 rows=1053 width=25) (actual time=4.585..4.586 rows=0 loops=1)
--         Sort Key: vacancy.job_id
--         Sort Method: quicksort  Memory: 25kB
--         ->  Nested Loop  (cost=25631.50..33665.88 rows=1053 width=25) (actual time=4.571..4.571 rows=0 loops=1)
--               ->  GroupAggregate  (cost=25631.07..25657.40 rows=1053 width=20) (actual time=4.570..4.570 rows=0 loops=1)
--                     Group Key: vacancy_1.vacancy_id
--                     ->  Sort  (cost=25631.07..25633.70 rows=1053 width=12) (actual time=4.569..4.569 rows=0 loops=1)
--                           Sort Key: vacancy_1.vacancy_id
--                           Sort Method: quicksort  Memory: 25kB
--                           ->  Nested Loop Left Join  (cost=11926.13..25578.21 rows=1053 width=12) (actual time=4.566..4.566 rows=0 loops=1)
--                                 Join Filter: (read_message.account_id = account.account_id)
--                                 ->  Nested Loop  (cost=11925.84..25239.49 rows=1053 width=12) (actual time=4.566..4.566 rows=0 loops=1)
--                                       ->  Index Only Scan using account_pkey on account  (cost=0.43..4.45 rows=1 width=4) (actual time=0.012..0.014 rows=1 loops=1)
--                                             Index Cond: (account_id = 8)
--                                             Heap Fetches: 0
--                                       ->  Hash Right Join  (cost=11925.41..25224.51 rows=1053 width=12) (actual time=4.550..4.550 rows=0 loops=1)
--                                             Hash Cond: (message.vacancy_id = vacancy_1.vacancy_id)
--                                             Filter: ((message.account_id <> 8) OR (message.account_id IS NULL))
--                                             ->  Seq Scan on message  (cost=0.00..11156.81 rows=569281 width=12) (never executed)
--                                             ->  Hash  (cost=11912.25..11912.25 rows=1053 width=8) (actual time=4.544..4.544 rows=0 loops=1)
--                                                   Buckets: 2048  Batches: 1  Memory Usage: 16kB
--                                                   ->  Merge Join  (cost=11869.06..11912.25 rows=1053 width=8) (actual time=4.544..4.544 rows=0 loops=1)
--                                                         Merge Cond: (job_1.job_id = vacancy_1.job_id)
--                                                         ->  Index Only Scan using job_pkey on job job_1  (cost=0.43..118030.06 rows=3999842 width=4) (actual time=0.043..0.043 rows=1 loops=1)
--                                                               Heap Fetches: 0
--                                                         ->  Sort  (cost=11867.47..11870.10 rows=1053 width=12) (actual time=4.499..4.499 rows=0 loops=1)
--                                                               Sort Key: vacancy_1.job_id
--                                                               Sort Method: quicksort  Memory: 25kB
--                                                               ->  Gather  (cost=1036.83..11814.61 rows=1053 width=12) (actual time=4.494..5.965 rows=0 loops=1)
--                                                                     Workers Planned: 2
--                                                                     Workers Launched: 2
--                                                                     ->  Hash Join  (cost=36.83..10709.31 rows=439 width=12) (actual time=0.086..0.086 rows=0 loops=3)
--                                                                           Hash Cond: (vacancy_1.company_id = company.company_id)
--                                                                           ->  Hash Join  (cost=8.45..10679.78 rows=439 width=20) (actual time=0.086..0.086 rows=0 loops=3)
--                                                                                 Hash Cond: (vacancy_1.company_id = hr_manager.company_id)
--                                                                                 ->  Parallel Seq Scan on vacancy vacancy_1  (cost=0.00..9572.69 rows=416669 width=12) (actual time=0.007..0.007 rows=1 loops=3)
--                                                                                 ->  Hash  (cost=8.44..8.44 rows=1 width=8) (actual time=0.012..0.012 rows=0 loops=3)
--                                                                                       Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                                                                       ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..8.44 rows=1 width=8) (actual time=0.012..0.012 rows=0 loops=3)
--                                                                                             Index Cond: (account_id = 8)
--                                                                           ->  Hash  (cost=16.50..16.50 rows=950 width=4) (never executed)
--                                                                                 ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=4) (never executed)
--                                 ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.31 rows=1 width=8) (never executed)
--                                       Index Cond: ((message_id = message.message_id) AND (account_id = 8))
--                                       Heap Fetches: 0
--               ->  Index Scan using vacancy_pkey on vacancy  (cost=0.42..7.60 rows=1 width=9) (never executed)
--                     Index Cond: (vacancy_id = vacancy_1.vacancy_id)
-- Planning time: 2.541 ms
-- Execution time: 6.224 ms

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
-- Unique  (cost=25719.54..25743.23 rows=1053 width=95) (actual time=6.266..6.266 rows=0 loops=1)
--   ->  Sort  (cost=25719.54..25722.17 rows=1053 width=95) (actual time=6.264..6.264 rows=0 loops=1)
--         Sort Key: (count(message.message_id) OVER (?)), ((count(message.message_id) OVER (?) - count(read_message.message_id) OVER (?))), vacancy.active, vacancy.vacancy_id, job.title, job.city, job.description, job.salary
--         Sort Method: quicksort  Memory: 25kB
--         ->  WindowAgg  (cost=25642.98..25666.68 rows=1053 width=95) (actual time=6.246..6.246 rows=0 loops=1)
--               ->  Sort  (cost=25642.98..25645.62 rows=1053 width=87) (actual time=6.239..6.240 rows=0 loops=1)
--                     Sort Key: message.resume_id
--                     Sort Method: quicksort  Memory: 25kB
--                     ->  Nested Loop Left Join  (cost=11938.04..25590.12 rows=1053 width=87) (actual time=6.236..6.236 rows=0 loops=1)
--                           Join Filter: (read_message.account_id = account.account_id)
--                           ->  Nested Loop  (cost=11937.75..25251.40 rows=1053 width=87) (actual time=6.234..6.235 rows=0 loops=1)
--                                 ->  Index Only Scan using account_pkey on account  (cost=0.43..4.45 rows=1 width=4) (actual time=0.019..0.034 rows=1 loops=1)
--                                       Index Cond: (account_id = 8)
--                                       Heap Fetches: 0
--                                 ->  Hash Right Join  (cost=11937.32..25236.42 rows=1053 width=87) (actual time=6.196..6.197 rows=0 loops=1)
--                                       Hash Cond: (message.vacancy_id = vacancy.vacancy_id)
--                                       Filter: ((message.account_id <> 8) OR (message.account_id IS NULL))
--                                       ->  Seq Scan on message  (cost=0.00..11156.81 rows=569281 width=16) (never executed)
--                                       ->  Hash  (cost=11924.16..11924.16 rows=1053 width=79) (actual time=6.188..6.188 rows=0 loops=1)
--                                             Buckets: 2048  Batches: 1  Memory Usage: 16kB
--                                             ->  Merge Join  (cost=11869.06..11924.16 rows=1053 width=79) (actual time=6.187..6.187 rows=0 loops=1)
--                                                   Merge Cond: (job.job_id = vacancy.job_id)
--                                                   ->  Index Scan using job_pkey on job  (cost=0.43..171452.18 rows=3999842 width=74) (actual time=0.015..0.015 rows=1 loops=1)
--                                                   ->  Sort  (cost=11867.47..11870.10 rows=1053 width=13) (actual time=6.166..6.166 rows=0 loops=1)
--                                                         Sort Key: vacancy.job_id
--                                                         Sort Method: quicksort  Memory: 25kB
--                                                         ->  Gather  (cost=1036.83..11814.61 rows=1053 width=13) (actual time=6.156..8.477 rows=0 loops=1)
--                                                               Workers Planned: 2
--                                                               Workers Launched: 2
--                                                               ->  Hash Join  (cost=36.83..10709.31 rows=439 width=13) (actual time=0.190..0.190 rows=0 loops=3)
--                                                                     Hash Cond: (vacancy.company_id = company.company_id)
--                                                                     ->  Hash Join  (cost=8.45..10679.78 rows=439 width=21) (actual time=0.189..0.189 rows=0 loops=3)
--                                                                           Hash Cond: (vacancy.company_id = hr_manager.company_id)
--                                                                           ->  Parallel Seq Scan on vacancy  (cost=0.00..9572.69 rows=416669 width=13) (actual time=0.008..0.008 rows=1 loops=3)
--                                                                           ->  Hash  (cost=8.44..8.44 rows=1 width=8) (actual time=0.017..0.017 rows=0 loops=3)
--                                                                                 Buckets: 1024  Batches: 1  Memory Usage: 8kB
--                                                                                 ->  Index Scan using hr_manager_account_id_key on hr_manager  (cost=0.42..8.44 rows=1 width=8) (actual time=0.017..0.017 rows=0 loops=3)
--                                                                                       Index Cond: (account_id = 8)
--                                                                     ->  Hash  (cost=16.50..16.50 rows=950 width=4) (never executed)
--                                                                           ->  Seq Scan on company  (cost=0.00..16.50 rows=950 width=4) (never executed)
--                           ->  Index Only Scan using read_message_message_id_account_id_key on read_message  (cost=0.29..0.31 rows=1 width=8) (never executed)
--                                 Index Cond: ((message_id = message.message_id) AND (account_id = 8))
--                                 Heap Fetches: 0
-- Planning time: 3.680 ms
-- Execution time: 8.769 ms

-- прочитать сообщение #7
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (7,8);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.318..0.318 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.184..0.185 rows=1 loops=1)
-- Planning time: 0.048 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.475 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.257 calls=1
-- Execution time: 1.119 ms

-- прочитать сообщение #8
EXPLAIN ANALYSE INSERT INTO read_message (message_id, account_id)
VALUES (8,8);
-- Insert on read_message  (cost=0.00..0.01 rows=1 width=12) (actual time=0.062..0.062 rows=0 loops=1)
--   ->  Result  (cost=0.00..0.01 rows=1 width=12) (actual time=0.013..0.013 rows=1 loops=1)
-- Planning time: 0.032 ms
-- Trigger for constraint read_message_message_id_fkey: time=0.242 calls=1
-- Trigger for constraint read_message_account_id_fkey: time=0.149 calls=1
-- Execution time: 0.499 ms