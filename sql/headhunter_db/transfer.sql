-- simulate account conflict
INSERT INTO account (login, password, first_name, family_name, contact_email, contact_phone)
SELECT login, password, first_name, family_name, contact_email, contact_phone FROM tmp_account
ORDER BY account_id ASC OFFSET 300 LIMIT 1400;

-- account
WITH id_insert AS (
  INSERT INTO map_account (old_id)
  SELECT tmp_account.account_id FROM tmp_account
  ORDER BY account_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO account (account_id, login, password, first_name, family_name, contact_email, contact_phone)
SELECT id_insert.new_id, login, password, first_name, family_name, contact_email, contact_phone
  FROM tmp_account
  JOIN id_insert ON (tmp_account.account_id = id_insert.old_id)
  ON CONFLICT ON CONSTRAINT account_login_key DO NOTHING;

-- job
WITH id_insert AS (
  INSERT INTO map_job (old_id)
  SELECT tmp_job.job_id FROM tmp_job
  ORDER BY job_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO job  (job_id, title, city, description, salary)
SELECT id_insert.new_id, title, city, description, salary
  FROM tmp_job
  JOIN id_insert ON (tmp_job.job_id = id_insert.old_id);

-- company
WITH id_insert AS (
  INSERT INTO map_company (old_id)
  SELECT tmp_company.company_id FROM tmp_company
  ORDER BY company_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO company (company_id, name)
SELECT id_insert.new_id, name
  FROM tmp_company
  JOIN id_insert ON (tmp_company.company_id = id_insert.old_id);

-- hr_manager
WITH id_insert AS (
  INSERT INTO map_hr_manager (old_id)
  SELECT tmp_hr_manager.hr_manager_id FROM tmp_hr_manager
  ORDER BY hr_manager_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO hr_manager (hr_manager_id, account_id, company_id)
SELECT id_insert.new_id, map_account.new_id, map_company.new_id
  FROM tmp_hr_manager
  JOIN id_insert ON (tmp_hr_manager.hr_manager_id = id_insert.old_id)
  JOIN map_account ON (map_account.old_id = tmp_hr_manager.account_id)
  JOIN map_company ON (map_company.old_id = tmp_hr_manager.company_id)
  JOIN account ON (map_account.new_id = account.account_id)

-- applicant
WITH id_insert AS (
  INSERT INTO map_applicant (old_id)
  SELECT tmp_applicant.applicant_id FROM tmp_applicant
  ORDER BY applicant_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO applicant (applicant_id, account_id)
SELECT id_insert.new_id, map_account.new_id
  FROM tmp_applicant
  JOIN id_insert ON (tmp_applicant.applicant_id = id_insert.old_id)
  JOIN map_account ON (map_account.old_id = tmp_applicant.account_id)
  JOIN account ON (map_account.new_id = account.account_id);

-- vacancy
WITH id_insert AS (
  INSERT INTO map_vacancy (old_id)
  SELECT tmp_vacancy.vacancy_id FROM tmp_vacancy
  ORDER BY vacancy_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO vacancy  (vacancy_id, active, company_id, job_id)
SELECT id_insert.new_id, active, map_company.new_id, map_job.new_id
  FROM tmp_vacancy
  JOIN id_insert ON (tmp_vacancy.vacancy_id = id_insert.old_id)
  JOIN map_company ON (map_company.old_id = tmp_vacancy.company_id)
  JOIN map_job ON (map_job.old_id = tmp_vacancy.company_id);

-- resume
WITH id_insert AS (
  INSERT INTO map_resume (old_id)
  SELECT tmp_resume.resume_id FROM tmp_resume
  ORDER BY resume_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO resume (resume_id, active, applicant_id, job_id)
SELECT id_insert.new_id, active, map_applicant.new_id, map_job.new_id
  FROM tmp_resume
  JOIN id_insert ON (tmp_resume.resume_id = id_insert.old_id)
  JOIN map_applicant ON (map_applicant.old_id = tmp_resume.applicant_id)
  JOIN map_job ON (map_job.old_id = tmp_resume.job_id)
  JOIN applicant ON (map_applicant.new_id = applicant.applicant_id);

-- message
WITH id_insert AS (
  INSERT INTO map_message (old_id)
  SELECT tmp_message.message_id FROM tmp_message
  ORDER BY message_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO message (message_id, send, account_id, vacancy_id, resume_id, text)
SELECT id_insert.new_id, send, map_account.new_id, map_vacancy.new_id, map_resume.new_id, text
  FROM tmp_message
  JOIN id_insert ON (tmp_message.message_id = id_insert.old_id)
  JOIN map_account ON (map_account.old_id = tmp_message.account_id)
  JOIN map_vacancy ON (map_vacancy.old_id = tmp_message.vacancy_id)
  JOIN map_resume ON (map_resume.old_id = tmp_message.resume_id)
  JOIN account ON (map_account.new_id = account.account_id)
  JOIN vacancy ON (map_vacancy.new_id = vacancy.vacancy_id)
  JOIN resume ON (map_resume.new_id = resume.resume_id);

-- read_message
WITH id_insert AS (
  INSERT INTO map_read_message (old_id)
  SELECT tmp_read_message.read_message_id FROM tmp_read_message
  ORDER BY read_message_id ASC OFFSET 0 LIMIT 1000
  RETURNING old_id, new_id
)
INSERT INTO read_message (read_message_id, message_id, account_id)
SELECT id_insert.new_id, map_message.new_id, map_account.new_id
  FROM tmp_read_message
  JOIN id_insert ON (tmp_read_message.read_message_id = id_insert.old_id)
  JOIN map_message ON (map_message.old_id = tmp_read_message.message_id)
  JOIN map_account ON (map_account.old_id = tmp_read_message.account_id)
  JOIN account ON (map_account.new_id = account.account_id)
  JOIN message ON (map_message.new_id = message.message_id);
--
