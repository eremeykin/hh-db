-- Зарегистрироваться
WITH ins1 AS (
       INSERT INTO users (login, password, profile_fk)
       VALUES ('eremeykin4@gmail.com', 'mySuPerPaSsWRD', null)
       RETURNING user_id
   )
INSERT INTO applicants (user_fk)
SELECT user_id FROM ins1;
