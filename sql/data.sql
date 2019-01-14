INSERT INTO users (login, password, first_name, family_name, contact_email, contact_phone)
VALUES  ('ivanov@gmail.com', 'ivaTestNOV', 'Фёдор','Иванов', 'ivanov@gmail.com', 79166284732),
        ('petrov@yandex.ru', 'pvDragon', 'Николай','Петров', 'kolya@dragon.org', 79743454297),
        ('smrnv@ya.ru', 's62dfA25SDd52fsoi', 'Максим','Смирнов', 'smrnv@ya.ru',  79962145873),
        ('vigor@okf.ru', 'NbhprwR', 'Игорь','Воробьев', 'vorobev@okf.ru',  79170773300),
        ('belkin@rambler.ru','b31kin','Евгений', 'Белкин','belkin@rambler.ru', 79356214720),
        ('tkalugin78@gmail.com','o2faD3F0A','Тимур', 'Калугин','tkalugin@aec.ru', 79424251294);

INSERT INTO companies (name)
VALUES ('OOO "Дракон"'),
       ('ОКФ'),
       ('Центр перспективных инженерных разработок');


INSERT INTO applicants (user_fk)
VALUES (1),(3),(5);

INSERT INTO employers (user_fk, company_fk)
VALUES (2,1), (4,2), (6, 3);

INSERT INTO jobs (title, city, description, salary)
VALUES ('Электрик', 'Н. Новгород', 'В компанию требуется электрик 4 разряда. В сферу ответственност входит своевременный ремонт и диагностика оборудования на заводе', '[40000,60000]'),
       ('Слесарь', 'Н. Новгород', 'В должностные обязанности входит монтаж, настройка и техническое обслуживание контрольно-измерительных приборов и устройств автоматики', '[50000,70000]'),
       ('Зоолог', 'Иркутск', 'Необходимо следить за жизнедеятельностью крупных присмыкающихся.', '[90000,110000]'),
       ('Биолог', 'Иркутск', 'Большой опыт работы с присмыкающимися, долгое время выполнял обязанности главного биолога в Национальном кенийском парке клювоголовых', '[100000,)'),
       ('Электрик 4 разряда', NULL , 'Квалифицированный и ответственный электрик 4 разряда. Иммется опыт ремонта и обслуживания индукционных генераторов.','[50000,)'),
       ('Юрист', 'Владивосток', 'От кандидата требуется отличное знание законодательства РФ в вопросах содержания крупных рептилий.', '[100000,150000]'),
       ('Инженер', 'Москва', 'В Московский филиал центра перспективных инженерных разработок (ЦПИР) требуется инженер-конструктор для разработки систем управления сложной техникой', '[500000,650000]'),
       ('Технолог', 'Москва', 'В Московский филиал центра перспективных инженерных разработок (ЦПИР) требуется технолог для расчета режимов обработки деталей сложной конфигурации', '[300000,370000]');


INSERT INTO vacancies (company_fk, job_fk)
VALUES (2,1), (2,2), (1,3),(1,6), (3,7);

INSERT INTO resumes (applicant_fk, job_fk)
VALUES (3,4), (3,5);

INSERT INTO suggestions (resume_fk, employer_fk, vacancy_fk, message)
VALUES (2, 2, 1, 'Предлагаю Вам работу электрика в нашей компании');


INSERT INTO responses(vacancy_fk, appliсant_fk, message)
VALUES (3, 2, 'Меня заинтересовала Ваша вакансия зоолога в Иркутске. У меня большой опыт работы с различными присмыкающимися.');
