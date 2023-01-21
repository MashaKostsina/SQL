1. Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.
select title, name_genre, price 
from genre inner join book
on genre.genre_id = book.genre_id
where amount > 8
order by price desc;

2. Вывести все жанры, которые не представлены в книгах на складе.
select name_genre
from genre left join book
on genre.genre_id = book.genre_id
where book.genre_id is NULL;

3. Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город, автора и дату проведения выставки. Последний столбец назвать Дата. Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.
select name_city, name_author, DATE_ADD('2020-01-01', INTERVAL (FLOOR(RAND() * 365)) day) as Дата
from city, author
order by name_city asc, Дата desc;

4.  Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «роман» в отсортированном по названиям книг виде.
select name_genre, title, name_author
from genre inner join book on genre.genre_id = book.genre_id
           inner join author on book.author_id = author.author_id
where name_genre like "%роман%"
order by title;

5. Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,  количество книг которых меньше 10, в отсортированном по возрастанию количества виде. Последний столбец назвать Количество.
select name_author, sum(amount) as Количество
from author left join book on author.author_id = book.author_id
group by name_author
having Количество<10 or count(title) = 0
order by Количество;

6. Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре. Поскольку у нас в таблицах так занесены данные, что у каждого автора книги только в одном жанре,  для этого запроса внесем изменения в таблицу book. Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).
select name_author
from book inner join author on book.author_id = author.author_id
group by name_author
having count(distinct (genre_id))=1
order by name_author;

7. Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книг), написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде. Самым популярным считать жанр, общее количество экземпляров книг которого на складе максимально.
select title, name_author, name_genre, price, amount
from 
    author 
    inner join book on author.author_id = book.author_id
    inner join genre on  book.genre_id = genre.genre_id
group by title, name_author, name_genre, price, amount, genre.genre_id
having genre.genre_id in
         (select query_in_1.genre_id
          from 
              (select genre_id, sum(amount) as sum_amount
               from book
               group by genre_id
              )query_in_1
          inner join 
              (select genre_id, sum(amount) as sum_amount
               from book
               group by genre_id
               order by sum_amount desc
               limit 1
              )query_in_2
          on query_in_1.sum_amount= query_in_2.sum_amount
         )
order by title; 
_______________________________________________

select title, name_author, name_genre, price, amount
from author inner join book on author.author_id = book.author_id
            inner join genre on book.genre_id = genre.genre_id
where book.genre_id in 
    (select genre_id
     from book
     group by genre_id
     having sum(amount) >= all(select sum(amount) from book group by genre_id)
     )
order by title;

8. Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,  вывести их название и автора, а также посчитать общее количество экземпляров книг в таблицах supply и book,  столбцы назвать Название, Автор  и Количество.
select book.title as Название, name_author as Автор, (sum(book.amount) + sum(supply.amount))  as Количество
from author inner join book using(author_id)
            inner join supply on book.title = supply.title 
                         and book.price = supply.price
group by book.title, name_author;

9. Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. А в таблице  supply обнулить количество этих книг.
update book b inner join author a on a.author_id = b.author_id
              inner join supply s on b.title = s.title and s.author = a.name_author
set b.amount = b.amount + s.amount,
    b.price = (b.price*b.amount+s.price*s.amount)/(b.amount+s.amount),
    s.amount = 0
where b.price != s.price;

10. Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все данные из таблицы author.  Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.
insert into author (name_author)
select supply.author
from author right join supply on author.name_author = supply.author
where name_author is null;

11. Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса. Затем вывести для просмотра таблицу book.
insert into book (title, author_id, price, amount)
select title, author_id, price, amount
from author inner join supply on author.name_author = supply.author
where amount <> 0;

12.  Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» Стивенсона - «Приключения». (Использовать два запроса).
update book
set genre_id = (select genre_id from genre where name_genre = 'Поэзия') where book_id = 10;

update book
set genre_id = (select genre_id from genre where name_genre = 'Приключения') where book_id = 11;

13. Удалить всех авторов и все их книги, общее количество книг которых меньше 20.
delete from author
where author_id IN (select author_id
                   from book 
                   group by author_id 
                   having sum(amount) < 20);

14. Удалить все жанры, к которым относится меньше 4-х книг. В таблице book для этих жанров установить значение Null.
delete from genre
where genre_id IN (select genre_id
                   from book
                   group by genre_id
                   having count(title) <4);

15. Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов. В запросе для отбора авторов использовать полное название жанра, а не его id.
delete from author
using author inner join book on author.author_id = book.author_id
             inner join genre on book.genre_id = genre.genre_id
where genre.name_genre = 'Поэзия';

16. Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в отсортированном по номеру заказа и названиям книг виде.
select buy.buy_id, book.title, book.price, buy_book.amount
from client inner join buy using(client_id)
            inner join buy_book using(buy_id)
            inner join book using(book_id)
where client.name_client = "Баранов Павел"
order by buy.buy_id, book.title;

17. Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).  Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.
select author.name_author, book.title, count(buy_book.amount) as Количество
from author inner join book using (author_id)
     left join buy_book using (book_id)
group by author.name_author, book.title
order by author.name_author, book.title;

18. Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.
select city.name_city, count(buy.client_id) as Количество
from city inner join client using (city_id)
          inner join buy using (client_id)
group by city.name_city
order by Количество desc, city.name_city;

19. Вывести номера всех оплаченных заказов и даты, когда они были оплачены.
select buy.buy_id, date_step_end
from buy inner join buy_step using (buy_id)
         inner join step using (step_id)
where name_step = "Оплата" and date_step_end is not null;

20. Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений количества заказанных книг и их цены), в отсортированном по номеру заказа виде. Последний столбец назвать Стоимость.
select buy.buy_id, name_client, sum(book.price * buy_book.amount) as Стоимость
from client inner join buy using (client_id)
     inner join buy_book using (buy_id)
     inner join book using (book_id)
group by buy.buy_id, name_client
order by buy.buy_id;

21. Вывести номера заказов (buy_id) и названия этапов, на которых они в данный момент находятся. Если заказ доставлен –  информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id.
select buy_id, name_step
from buy_step inner join step using(step_id)
where date_step_beg is not null and date_step_end is null and not (name_step = 'Доставка' and date_step_end is not null)
order by buy_id;

22. В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап "Транспортировка"). Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город. А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0. В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде.
select buy.buy_id, datediff(date_step_end, date_step_beg) as Количество_дней, if(datediff(date_step_end, date_step_beg) > days_delivery, (datediff(date_step_end, date_step_beg) - days_delivery), 0) as Опоздание
from city inner join client using (city_id)
          inner join buy using (client_id)
          inner join buy_step using (buy_id)
          inner join step using (step_id)
where name_step = 'Транспортировка' and date_step_end is not null
order by buy.buy_id;

23. Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. В решении используйте фамилию автора, а не его id.
select distinct name_client
from client inner join buy using(client_id)
            inner join buy_book using(buy_id)
            inner join book using(book_id)
            inner join author using(author_id)
where name_author="Достоевский Ф.М."
order by name_client;

select distinct name_client
from client inner join buy using(client_id)
            inner join buy_book using(buy_id)
            inner join book using(book_id)
            inner join author using(author_id)
where name_author like "Достоевский%"
order by name_client;

select name_client
from client inner join buy using(client_id)
            inner join buy_book using(buy_id)
            inner join book using(book_id)
            inner join author on author.author_id=book.author_id
and name_author='Достоевский Ф.М.'
group by name_client
order by name_client;

24. Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество . Последний столбец назвать Количество.
select name_genre, sum(buy_book.amount) as Количество
from genre inner join book using(genre_id)
           inner join buy_book using(book_id)
group by name_genre
having sum(buy_book.amount) = (select max(sum_amount) as max_sum_amount
                               from 
                                  (select genre_id, sum(buy_book.amount) as sum_amount
                                   from book inner join buy_book using(book_id)
                                   group by genre_id
                                  )query_in
                               );

25. Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.
select year(date_step_end) as Год, monthname(date_step_end) as Месяц, sum(book.price * buy_book.amount) as Сумма
from book inner join buy_book using(book_id)
          inner join buy_step on buy_book.buy_id = buy_step.buy_id and buy_step.step_id = 1 and date_step_end is not null
group by Год, Месяц          
union 
select year(date_payment) as Год, monthname(date_payment) as Месяц, sum(price * amount) as Сумма
from buy_archive
group by Год, Месяц
order by Месяц, Год;

26. Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за 2020 и 2019 год . Вычисляемые столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию стоимости.
select title, sum(query_in.sum_amount) as Количество, sum(query_in.sum_price) as Сумма
from
(select title, sum(buy_archive.amount) as sum_amount, sum(buy_archive.amount * buy_archive.price) as sum_price
 from buy_archive inner join book using(book_id)
 group by title
 union all
 select title, sum(buy_book.amount) as sum_amount, sum(buy_book.amount * book.price) as sum_price
 from book inner join buy_book using(book_id)
           inner join buy_step on buy_book.buy_id = buy_step.buy_id and buy_step.step_id = 1 and date_step_end is not null
group by title
) as query_in
group by title
order by Сумма desc; 

27.  Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.
insert into client (name_client, city_id, email)
select 'Попов Илья', city_id, 'popov@test'
from city
where name_city = "Москва";

28.  Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки». Важно! В решении нельзя использоваться VALUES и делать отбор по client_id.
insert into buy (buy_description, client_id)
select 'Связаться со мной по вопросу доставки', client_id
from client
where name_client like "%Попов%_Иль%";

29. В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.
insert into buy_book (buy_id, book_id, amount)
values (5, (select book_id from book inner join author on author.author_id = book.author_id and name_author like "Пастернак%" and title = "Лирика"), 2),
       (5, (select book_id from book inner join author on author.author_id = book.author_id and name_author like "Булгаков%" and title = "Белая гвардия"), 1);

30. Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг и  стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести в отсортированном по названиям книг виде.
create table buy_pay as
select title, name_author, price, buy_book.amount, (price * buy_book.amount) as Стоимость
from buy_book inner join book using (book_id)
              inner join author using (author_id)
where buy_id = 5
order by title;

31. Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого).  Для решения используйте ОДИН запрос.
create table buy_pay as
select buy_id, sum(buy_book.amount) as Количество, sum(price * buy_book.amount) as Итого 
from buy_book inner join book on buy_book.book_id = book.book_id and buy_id = 5
group by buy_id;

32. В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. В столбцы date_step_beg и date_step_end всех записей занести Null.
insert into buy_step (buy_id, step_id, date_step_beg, date_step_end)
select buy_id, step_id, Null, Null
from buy, step 
where buy.buy_id = 5;

33. В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.
Правильнее было бы занести не конкретную, а текущую дату. Но при этом в разные дни будут вставляться разная дата, и задание нельзя будет проверить, поэтому  вставим дату 12.04.2020.
update buy_step
set date_step_beg  = (select now())
where buy_id = 5 and step_id = (select step_id from step where name_step = "Оплата");

update buy_step
set date_step_beg  = "2020-04-12"
where buy_id = 5 and step_id = (select step_id from step where name_step = "Оплата");

34. Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату. Реализовать два запроса для завершения этапа и начале следующего. Они должны быть записаны в общем виде, чтобы его можно было применять для любых этапов, изменив только текущий этап. Для примера пусть это будет этап «Оплата».
update buy_step
set date_step_end  = "2020-04-13"
where buy_id = 5 and step_id = (select step_id from step where name_step = "Оплата");

update buy_step
set date_step_beg  = "2020-04-13"
where buy_id = 5 and step_id = (select step_id from step where name_step = "Упаковка");

35.  Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. Информацию вывести по убыванию результатов тестирования.
select name_student, date_attempt, result
from student inner join attempt using(student_id)
             inner join subject on attempt.subject_id = subject.subject_id and name_subject = "Основы баз данных"
order by result desc;

36. Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных ответов на вопросы теста, который занесен в столбец result.  В результат включить название дисциплины, а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.
select name_subject, count(attempt_id) as Количество, round(avg(result), 2) as Среднее
from subject left join attempt using(subject_id)
group by name_subject 
order by Среднее desc;

37. Вывести студентов (различных студентов), имеющих максимальные результаты попыток . Информацию отсортировать в алфавитном порядке по фамилии студента.
select name_student, result
from student inner join attempt using(student_id)
group by name_student, result
having result = (select max(result) from attempt)
order by name_student;

38. Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. 
select name_student, name_subject, datediff(max(date_attempt), min(date_attempt)) as Интервал
from student inner join attempt using (student_id)
             inner join subject using (subject_id)
group by name_student, name_subject
having count(date_attempt) >1
order by Интервал;

39. Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.
select  name_subject, count(distinct(student_id)) as Количество
from subject left join attempt using(subject_id)
group by name_subject
order by Количество desc, name_subject;

40. Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.
select question_id, name_question
from question inner join subject on question.subject_id = subject.subject_id and name_subject = "Основы баз данных"
order by rand()
limit 3;

41. Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет(вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат.
select name_question, name_answer, if(is_correct=true, "Верно", "Неверно") as Результат
from question inner join testing on question.question_id = testing.question_id and attempt_id = 7
              inner join answer using (answer_id);

42.