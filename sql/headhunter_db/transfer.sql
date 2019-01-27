-- account
WITH ins AS (
  INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
  SELECT login, password, first_name, family_name, contact_email, contact_phone FROM tmp_account ORDER BY account_id ASC OFFSET 0 LIMIT 1000
  RETURNING account_id
)
INSERT INTO map_account (new_id)
SELECT account_id FROM ins;


-- job
WITH ins AS (
  INSERT INTO job (title,city, description, salary)
  SELECT title,city, description, salary FROM tmp_job ORDER BY job_id ASC OFFSET 0 LIMIT 1000
  RETURNING job_id
)
INSERT INTO map_job (new_id)
SELECT job_id FROM ins;


-- company
WITH ins AS (
  INSERT INTO company (name)
  SELECT name FROM tmp_company ORDER BY company_id ASC OFFSET 0 LIMIT 1000
  RETURNING company_id
)
INSERT INTO map_company (new_id)
SELECT company_id FROM ins;

-- hr_manager
WITH ins AS (
  INSERT INTO hr_manager (account_id, company_id)
  SELECT map_account.new_id, map_company.new_id
  FROM tmp_hr_manager
  JOIN map_account ON (tmp_hr_manager.hr_manager_id=map_account.map_id)
  JOIN map_company ON (tmp_hr_manager.company_id = map_company.map_id)
  ORDER BY hr_manager_id ASC OFFSET 0 LIMIT 1000
  RETURNING hr_manager_id
)
INSERT INTO map_hr_manager (new_id)
SELECT hr_manager_id FROM ins;

-- applicant
WITH ins AS (
  INSERT INTO applicant (account_id)
  SELECT map_account.new_id
  FROM tmp_applicant
  JOIN map_account ON (tmp_applicant.applicant_id = map_account.map_id)
  ORDER BY applicant_id ASC OFFSET 0 LIMIT 1000
  RETURNING applicant_id
)
INSERT INTO map_applicant (new_id)
SELECT applicant_id FROM ins;

-- vacancy
WITH ins AS (
  INSERT INTO vacancy (active, company_id, job_id)
  SELECT active, map_company.new_id, map_job.new_id
  FROM tmp_vacancy
  JOIN map_company ON (tmp_vacancy.company_id=map_company.map_id)
  JOIN map_job ON (tmp_vacancy.job_id = map_job.map_id)
  ORDER BY vacancy_id ASC OFFSET 0 LIMIT 1000
  RETURNING vacancy_id
)
INSERT INTO map_vacancy (new_id)
SELECT vacancy_id FROM ins;

-- resume
WITH ins AS (
  INSERT INTO resume (active, applicant_id, job_id)
  SELECT active, map_applicant.new_id, map_job.new_id
  FROM tmp_resume
  JOIN map_applicant ON (tmp_resume.applicant_id=map_applicant.map_id)
  JOIN map_job ON (tmp_resume.job_id = map_job.map_id)
  ORDER BY resume_id ASC OFFSET 0 LIMIT 1000
  RETURNING resume_id
)
INSERT INTO map_resume (new_id)
SELECT resume_id FROM ins;


-- message
WITH ins AS (
  INSERT INTO message (send, account_id, vacancy_id, resume_id, text)
  SELECT send, map_account.new_id, map_vacancy.new_id, map_resume.new_id, text
  FROM tmp_message
  JOIN map_account ON (tmp_message.account_id = map_account.map_id)
  JOIN map_vacancy ON (tmp_message.vacancy_id = map_vacancy.map_id)
  JOIN map_resume ON (tmp_message.resume_id = map_resume.map_id)
  ORDER BY message_id ASC OFFSET 0 LIMIT 1000
  RETURNING message_id
)
INSERT INTO map_message (new_id)
SELECT message_id FROM ins;

-- read_message
WITH ins AS (
  INSERT INTO read_message (message_id, account_id)
  SELECT map_message.new_id, map_account.new_id
  FROM tmp_read_message
  JOIN map_account ON (tmp_read_message.account_id = map_account.map_id)
  JOIN map_message ON (tmp_read_message.message_id = map_message.map_id)
  ORDER BY read_message_id ASC OFFSET 0 LIMIT 1000
  RETURNING read_message_id
)
INSERT INTO map_read_message (new_id)
SELECT read_message_id  FROM ins;
--
