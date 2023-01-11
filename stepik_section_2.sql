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