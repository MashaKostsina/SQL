1. Вывести название и автора тех книг, название которых состоит из двух и более слов, а инициалы автора содержат букву «С». Считать, что в названии слова отделяются друг от друга пробелами и не содержат знаков препинания, между фамилией автора и инициалами обязателен пробел, инициалы записываются без пробела в формате: буква, точка, буква, точка. Информацию отсортировать по названию книги в алфавитном порядке.
SELECT title, author FROM book
WHERE title LIKE '_% _%' AND (author LIKE '% С.%' OR author LIKE '% _.С%')
ORDER BY title;

2. Посчитать стоимость всех экземпляров каждого автора без учета книг «Идиот» и «Белая гвардия». В результат включить только тех авторов, у которых суммарная стоимость книг (без учета книг «Идиот» и «Белая гвардия») более 5000 руб. Вычисляемый столбец назвать Стоимость. Результат отсортировать по убыванию стоимости.
SELECT author, SUM(price*amount) AS Стоимость FROM book
WHERE title <> 'Идиот' AND title <> 'Белая гвардия'
GROUP BY author
HAVING Стоимость > 5000
ORDER BY Стоимость DESC;

3. Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы на складе стало одинаковое количество экземпляров каждой книги, равное значению самого большего количества экземпляров одной книги на складе. Вывести название книги, ее автора, текущее количество экземпляров на складе и количество заказываемых экземпляров книг. Последнему столбцу присвоить имя Заказ. В результат не включать книги, которые заказывать не нужно.
SELECT title, author, amount, ((SELECT MAX(amount) from book) - amount) AS Заказ FROM book
where amount < (select max(amount) from book);

4. Добавить из таблицы supply в таблицу book, все книги, кроме книг, написанных Булгаковым М.А. и Достоевским Ф.М.
insert into book (title, author, price, amount) 
select title, author, price, amount 
from supply
where (author != 'Булгаков М.А.') AND (author != 'Достоевский Ф.М.'); 

5. Занести из таблицы supply в таблицу book только те книги, авторов которых нет в  book.
insert into book (title, author, price, amount) 
select title, author, price, amount 
from supply
where author not in (select author from book);

6. В таблице book необходимо скорректировать значение для покупателя в столбце buy таким образом, чтобы оно не превышало количество экземпляров книг, указанных в столбце amount. А цену тех книг, которые покупатель не заказывал, снизить на 10%.
update book
set buy = if(buy > amount, amount, buy), price = if(buy=0, 0.9*price, price);

7. Для тех книг в таблице book , которые есть в таблице supply, не только увеличить их количество в таблице book ( увеличить их количество на значение столбца amountтаблицы supply), но и пересчитать их цену (для каждой книги найти сумму цен из таблиц book и supply и разделить на 2).
update book, supply 
set book.amount = book.amount + supply.amount,
book.price = (book.price + supply.price) / 2
where book.title = supply.title AND book.author = supply.author;

8. Удалить из таблицы supply книги тех авторов, общее количество экземпляров книг которых в таблице book превышает 10.
delete from supply
where author in (select author from book group by author having sum(amount) > 10);

9. Создать таблицу заказ (ordering), куда включить авторов и названия тех книг, количество экземпляров которых в таблице book меньше среднего количества экземпляров книг в таблице book. В таблицу включить столбец   amount, в котором для всех книг указать одинаковое значение - среднее количество экземпляров книг в таблице book.
create table ordering AS
select author, title, (select round(avg(amount)) from book) as amount from book 
where amount<(select ROUND(avg(amount)) from book);