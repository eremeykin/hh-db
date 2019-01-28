-- account
INSERT INTO account (account_id, login, password, first_name, family_name, contact_email, contact_phone)
SELECT new_id, login, password, first_name, family_name, contact_email, contact_phone FROM tmp_account
ORDER BY account_id ASC OFFSET 0 LIMIT 1000;

-- job
INSERT INTO job (job_id, title,city, description, salary)
SELECT new_id, title,city, description, salary FROM tmp_job
ORDER BY job_id ASC OFFSET 0 LIMIT 1000;

-- company
INSERT INTO company (company_id, name)
SELECT new_id, name FROM tmp_company
ORDER BY company_id ASC OFFSET 0 LIMIT 1000;

-- hr_manager
INSERT INTO hr_manager (hr_manager_id, account_id, company_id)
SELECT tmp_hr_manager.new_id, tmp_account.new_id, tmp_company.new_id
FROM tmp_hr_manager
JOIN tmp_account USING (account_id)
JOIN tmp_company USING (company_id)
ORDER BY hr_manager_id ASC OFFSET 0 LIMIT 1000;

-- applicant
INSERT INTO applicant (applicant_id, account_id)
SELECT tmp_applicant.new_id, tmp_account.new_id FROM tmp_applicant
JOIN tmp_account USING (account_id)
ORDER BY applicant_id ASC OFFSET 0 LIMIT 1000;

-- vacancy
INSERT INTO vacancy (vacancy_id, active, company_id, job_id)
SELECT tmp_vacancy.new_id, active, tmp_company.new_id, tmp_job.new_id
FROM tmp_vacancy
JOIN tmp_company USING (company_id)
JOIN tmp_job USING (job_id)
ORDER BY vacancy_id ASC OFFSET 0 LIMIT 1000;

-- resume
INSERT INTO resume (resume_id, active, applicant_id, job_id)
SELECT tmp_resume.new_id, active, tmp_applicant.new_id, tmp_job.new_id
FROM tmp_resume
JOIN tmp_applicant USING (applicant_id)
JOIN tmp_job USING (job_id)
ORDER BY resume_id ASC OFFSET 0 LIMIT 1000;

-- message
INSERT INTO message (message_id, send, account_id, vacancy_id, resume_id, text)
SELECT tmp_message.new_id, send, tmp_account.new_id, tmp_vacancy.new_id, tmp_resume.new_id, text
FROM tmp_message
JOIN tmp_account USING (account_id)
JOIN tmp_vacancy USING (vacancy_id)
JOIN tmp_resume USING  (resume_id)
ORDER BY message_id ASC OFFSET 0 LIMIT 1000;

-- read_message
INSERT INTO read_message (read_message_id, message_id, account_id)
SELECT tmp_read_message.new_id, tmp_message.new_id, tmp_account.new_id
FROM tmp_read_message
JOIN tmp_message USING (message_id)
JOIN tmp_account ON (tmp_read_message.account_id = tmp_account.account_id)
ORDER BY read_message_id ASC OFFSET 0 LIMIT 1000;
--
