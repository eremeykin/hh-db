DROP TABLE IF EXISTS tmp_female_first_name;
DROP TABLE IF EXISTS tmp_female_family_name;
DROP TABLE IF EXISTS tmp_male_first_name;
DROP TABLE IF EXISTS tmp_male_family_name;
DROP TABLE IF EXISTS tmp_login;
DROP TABLE IF EXISTS tmp_password;
DROP TABLE IF EXISTS tmp_domain;

CREATE TABLE tmp_female_first_name
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

CREATE TABLE tmp_female_family_name
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

CREATE TABLE tmp_male_first_name
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

CREATE TABLE tmp_male_family_name
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

CREATE TABLE tmp_login
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

CREATE TABLE tmp_password
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

CREATE TABLE tmp_domain
(
    id SERIAL PRIMARY KEY,
    val VARCHAR(500)
);

INSERT INTO tmp_female_first_name (val)
VALUES ('Анастасия'),('Марина'),('Мирослава'),('Марьяна'),('Анна'),('Светлана'),('Галина'),('Анжелика'),('Мария'),('Варвара'),('Людмила'),('Нелли'),('Елена'),('Софья'),('Валентина'),('Влада'),('Дарья'),('Диана'),('Нина'),('Виталина'),('Алина'),('Яна'),('Эмилия'),('Майя'),('Ирина'),('Кира'),('Камилла'),('Тамара'),('Екатерина'),('Ангелина'),('Альбина'),('Мелания'),('Арина'),('Маргарита'),('Лилия'),('Лиана'),('Полина'),('Ева'),('Любовь'),('Василина'),('Ольга'),('Алёна'),('Лариса'),('Зарина'),('Юлия'),('Дарина'),('Эвелина'),('Алия'),('Татьяна'),('Карина'),('Инна'),('Владислава'),('Наталья'),('Василиса'),('Агата'),('Самира'),('Виктория'),('Олеся'),('Амелия'),('Антонина'),('Елизавета'),('Аделина'),('Амина'),('Ника'),('Ксения'),('Оксана'),('Эльвира'),('Мадина'),('Милана'),('Таисия'),('Ярослава'),('Наташа'),('Вероника'),('Надежда'),('Стефания'),('Снежана'),('Алиса'),('Евгения'),('Регина'),('Каролина'),('Валерия'),('Элина'),('Алла'),('Юлиана'),('Александра'),('Злата'),('Виолетта'),('Ариана'),('Ульяна'),('Есения'),('Лидия'),('Эльмира'),('Кристина'),('Милена'),('Амалия'),('Ясмина'),('София'),('Вера'),('Наталия'),('Сабина');

INSERT INTO tmp_female_family_name (val)
VALUES ('Смирнова'),('Иванова'),('Кузнецова'),('Соколова'),('Попова'),('Лебедева'),('Козлова'),('Новикова'),('Морозова'),('Петрова'),('Волкова'),('Соловьёва'),('Васильева'),('Зайцева'),('Павлова'),('Семёнова'),('Голубева'),('Виноградова'),('Богданова'),('Воробьёва'),('Фёдорова'),('Михайлова'),('Беляева'),('Тарасова'),('Белова'),('Комарова'),('Орлова'),('Киселёва'),('Макарова'),('Андреева');

INSERT INTO tmp_male_first_name (val)
VALUES ('Александр'),('Марк'),('Георгий'),('Артемий'),('Дмитрий'),('Константин'),('Давид'),('Эмиль'),('Максим'),('Тимур'),('Платон'),('Назар'),('Сергей'),('Олег'),('Анатолий'),('Савва'),('Андрей'),('Ярослав'),('Григорий'),('Ян'),('Алексей'),('Антон'),('Демид'),('Рустам'),('Артём'),('Николай'),('Данила'),('Игнат'),('Илья'),('Глеб'),('Станислав'),('Влад'),('Кирилл'),('Данил'),('Василий'),('Альберт'),('Михаил'),('Савелий'),('Федор'),('Тамерлан'),('Никита'),('Вадим'),('Родион'),('Айдар'),('Матвей'),('Степан'),('Леонид'),('Роберт'),('Роман'),('Юрий'),('Одиссей'),('Адель'),('Егор'),('Богдан'),('Валерий'),('Марсель'),('Арсений'),('Артур'),('Святослав'),('Ильдар'),('Иван'),('Семен'),('Борис'),('Самир'),('Денис'),('Макар'),('Эдуард'),('Тихон'),('Евгений'),('Лев'),('Марат'),('Рамиль'),('Даниил'),('Виктор'),('Герман'),('Ринат'),('Тимофей'),('Елисей'),('Даниэль'),('Радмир'),('Владислав'),('Виталий'),('Петр'),('Филипп'),('Игорь'),('Вячеслав'),('Амир'),('Арсен'),('Владимир'),('Захар'),('Всеволод'),('Ростислав'),('Павел'),('Мирон'),('Мирослав'),('Святогор'),('Руслан'),('Дамир'),('Гордей'),('Яромир');

INSERT INTO tmp_male_family_name (val)
VALUES ('Смирнов'),('Иванов'),('Кузнецов'),('Соколов'),('Попов'),('Лебедев'),('Козлов'),('Новиков'),('Морозов'),('Петров'),('Волков'),('Соловьёв'),('Васильев'),('Зайцев'),('Павлов'),('Семёнов'),('Голубев'),('Виноградов'),('Богданов'),('Воробьёв'),('Фёдоров'),('Михайлов'),('Беляев'),('Тарасов'),('Белов'),('Комаров'),('Орлов'),('Киселёв'),('Макаров'),('Андреев'),('Ковалёв'),('Ильин'),('Гусев'),('Титов'),('Кузьмин'),('Кудрявцев'),('Баранов'),('Куликов'),('Алексеев'),('Степанов'),('Яковлев'),('Сорокин'),('Сергеев'),('Романов'),('Захаров'),('Борисов'),('Королёв'),('Герасимов'),('Пономарёв'),('Григорьев'),('Лазарев'),('Медведев'),('Ершов'),('Никитин'),('Соболев'),('Рябов'),('Поляков'),('Цветков'),('Данилов'),('Жуков'),('Фролов'),('Журавлёв'),('Николаев'),('Крылов'),('Максимов'),('Сидоров'),('Осипов'),('Белоусов'),('Федотов'),('Дорофеев'),('Егоров'),('Матвеев'),('Бобров'),('Дмитриев'),('Калинин'),('Анисимов'),('Петухов'),('Антонов'),('Тимофеев'),('Никифоров'),('Веселов'),('Филиппов'),('Марков'),('Большаков'),('Суханов'),('Миронов'),('Ширяев'),('Александров'),('Коновалов'),('Шестаков'),('Казаков'),('Ефимов'),('Денисов'),('Громов'),('Фомин'),('Давыдов'),('Мельников'),('Щербаков'),('Блинов'),('Колесников'),('Карпов'),('Афанасьев'),('Власов'),('Маслов'),('Исаков'),('Тихонов'),('Аксёнов'),('Гаврилов'),('Родионов'),('Котов'),('Горбунов'),('Кудряшов'),('Быков'),('Зуев'),('Третьяков'),('Савельев'),('Панов'),('Рыбаков'),('Суворов'),('Абрамов'),('Воронов'),('Мухин'),('Архипов'),('Трофимов'),('Мартынов'),('Емельянов'),('Горшков'),('Чернов'),('Овчинников'),('Селезнёв'),('Панфилов'),('Копылов'),('Михеев'),('Галкин'),('Назаров'),('Лобанов'),('Лукин'),('Беляков'),('Потапов'),('Некрасов'),('Хохлов'),('Жданов'),('Наумов'),('Шилов'),('Воронцов'),('Ермаков'),('Дроздов'),('Игнатьев'),('Савин'),('Логинов'),('Сафонов'),('Капустин'),('Кириллов'),('Моисеев'),('Елисеев'),('Кошелев'),('Костин'),('Горбачёв'),('Орехов'),('Ефремов'),('Исаев'),('Евдокимов'),('Калашников'),('Кабанов'),('Носков'),('Юдин'),('Кулагин'),('Лапин'),('Прохоров'),('Нестеров'),('Харитонов'),('Агафонов'),('Муравьёв'),('Ларионов'),('Федосеев'),('Зимин'),('Пахомов'),('Шубин'),('Игнатов'),('Филатов'),('Крюков'),('Рогов'),('Кулаков'),('Терентьев'),('Молчанов'),('Владимиров'),('Артемьев'),('Гурьев'),('Зиновьев'),('Гришин'),('Кононов'),('Дементьев'),('Ситников'),('Симонов'),('Мишин'),('Фадеев'),('Комиссаров'),('Мамонтов'),('Носов'),('Гуляев'),('Шаров'),('Устинов'),('Вишняков'),('Евсеев'),('Лаврентьев'),('Брагин'),('Константинов'),('Корнилов'),('Авдеев'),('Зыков'),('Бирюков'),('Шарапов'),('Никонов'),('Щукин'),('Дьячков'),('Одинцов'),('Сазонов'),('Якушев'),('Красильников'),('Гордеев'),('Самойлов'),('Князев'),('Беспалов'),('Уваров'),('Шашков'),('Бобылёв'),('Доронин'),('Белозёров'),('Рожков'),('Самсонов'),('Мясников'),('Лихачёв'),('Буров'),('Сысоев'),('Фомичёв'),('Русаков'),('Стрелков'),('Гущин'),('Тетерин'),('Колобов'),('Субботин'),('Фокин'),('Блохин'),('Селиверстов'),('Пестов'),('Кондратьев'),('Силин'),('Меркушев'),('Лыткин'),('Туров');

INSERT INTO tmp_login (val)
VALUES ('antol'),('aozt'),('art'),('avto'),('bank'),('buh'),('buhgalter'),('business'),('bux'),('catchthismail'),('company'),('contact'),('contactus'),('corp'),('design'),('dir'),('director'),('dragon'),('economist'),('edu'),('email'),('er'),('expert'),('export'),('fabrika'),('fin'),('finance'),('ftp'),('glavbuh'),('glbuh'),('help'),('home'),('hr'),('iamj'),('info'),('ingthisleter'),('job'),('letmein'),('mail'),('manager'),('marketing'),('mike'),('mogggnomgon'),('monkey'),('moscow'),('office'),('ok'),('oracle'),('personal'),('postmaster');

INSERT INTO tmp_password (val)
VALUES ('123456'), ('password'), ('qwerty'), ('abc123'), ('football'), ('baseball'), ('welcome'), ('admin'), ('1qaz2wsx'), ('starwars'), ('princess'), ('master'), ('sunshine'), ('dragon'), ('flower'), ('shadow'), ('monkey'), ('passw0rd'), ('batman'), ('hello');

INSERT INTO tmp_domain (val)
VALUES ('example.com'),('test.com'),('yandex.ru'),('gmail.com'),('mail.ru');

INSERT INTO tmp_account (first_name, family_name, login, password, contact_email, contact_phone)
-- female (~ 1 m 17s)
SELECT tmp_female_first_name.val as first_name,
       tmp_female_family_name.val as family_name,
       CONCAT(tmp_login.val, generate_series, '@', tmp_domain.val) as login,
       tmp_password.val as password,
       CONCAT(generate_series, tmp_login.val, '@', tmp_domain.val) as contact_email,
       floor(random() * (1000000000) + 1000000000)::int as contact_phone
       FROM
(
  SELECT generate_series,
         floor(random() * (SELECT COUNT(*) FROM tmp_login) + 1)::int as login,
         floor(random() * (SELECT COUNT(*) FROM tmp_female_first_name) + 1)::int as first_name,
         floor(random() * (SELECT COUNT(*) FROM tmp_female_family_name) + 1)::int as family_name,
         floor(random() * (SELECT COUNT(*) FROM tmp_password) + 1)::int as password,
         floor(random() * (SELECT COUNT(*) FROM tmp_domain) + 1)::int as login_domain
  FROM generate_series(1,2000000) -- 2 M females
) AS IDS
JOIN tmp_female_first_name ON (first_name=tmp_female_first_name.id)
JOIN tmp_female_family_name ON (family_name=tmp_female_family_name.id)
JOIN tmp_login ON (login=tmp_login.id)
JOIN tmp_password ON (password=tmp_password.id)
JOIN tmp_domain ON (login_domain=tmp_domain.id);

INSERT INTO tmp_account (first_name, family_name, login, password, contact_email, contact_phone)
-- male (~4 m 23 s)
SELECT tmp_male_first_name.val as first_name,
       tmp_male_family_name.val as family_name,
       CONCAT(tmp_login.val, generate_series, '@', tmp_domain.val) as login,
       tmp_password.val as password,
       CONCAT(generate_series, tmp_login.val, '@', tmp_domain.val) as contact_email,
       floor(random() * (1000000000) + 1000000000)::int as contact_phone
       FROM
(
  SELECT generate_series,
         floor(random() * (SELECT COUNT(*) FROM tmp_login) + 1)::int as login,
         floor(random() * (SELECT COUNT(*) FROM tmp_male_first_name) + 1)::int as first_name,
         floor(random() * (SELECT COUNT(*) FROM tmp_male_family_name) + 1)::int as family_name,
         floor(random() * (SELECT COUNT(*) FROM tmp_password) + 1)::int as password,
         floor(random() * (SELECT COUNT(*) FROM tmp_domain) + 1)::int as login_domain
  FROM generate_series(2000000,5000000) -- 3 M males
) AS IDS
JOIN tmp_male_first_name ON (first_name=tmp_male_first_name.id)
JOIN tmp_male_family_name ON (family_name=tmp_male_family_name.id)
JOIN tmp_login ON (login=tmp_login.id)
JOIN tmp_password ON (password=tmp_password.id)
JOIN tmp_domain ON (login_domain=tmp_domain.id);


--  (~1 m 33 s)
INSERT INTO tmp_job (title, city, description, salary)
SELECT SUBSTRING(MD5(random()::text), 0, floor(random() * 25 + 5)::int) as title,
       SUBSTRING(MD5(random()::text), 0, floor(random() * 25 + 5)::int) as city,
       SUBSTRING(MD5(random()::text), 0, floor(random() * 25 + 5)::int) as description,
       INT8RANGE(floor(random() * 30000 + 20000)::int, floor(random() * 120000 + 80000)::int)
FROM generate_series(1,4000000);


