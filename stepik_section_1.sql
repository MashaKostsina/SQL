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

10. Вывести информацию о командировках во все города кроме Москвы и Санкт-Петербурга (фамилии и инициалы сотрудников, город ,  длительность командировки в днях, при этом первый и последний день относится к периоду командировки). Последний столбец назвать Длительность. Информацию вывести в упорядоченном по убыванию длительности поездки, а потом по убыванию названий городов (в обратном алфавитном порядке).
select name, city, (datediff(date_last, date_first) +1) as Длительность
from trip
where (city != 'Москва') and (city != 'Санкт-Петербург')
order by Длительность desc

11. Вывести информацию о командировках сотрудника(ов), которые были самыми короткими по времени. В результат включить столбцы name, city, date_first, date_last.
select name, city, date_first, date_last
from trip
where (datediff(date_last, date_first)) = (select min(datediff(date_last, date_first)) from trip);

12. Вывести сумму суточных (произведение количества дней командировки и размера суточных) для командировок, первый день которых пришелся на февраль или март 2020 года. Значение суточных для каждой командировки занесено в столбец per_diem. Вывести фамилию и инициалы сотрудника, город, первый день командировки и сумму суточных. Последний столбец назвать Сумма. Информацию отсортировать сначала  в алфавитном порядке по фамилиям сотрудников, а затем по убыванию суммы суточных.
select name , city, date_first, ((datediff(date_last, date_first)+1) * per_diem) as Сумма 
from trip
where month(date_first) in (2, 3)
order by name, Сумма desc

13. Вывести фамилию с инициалами и общую сумму суточных, полученных за все командировки для тех сотрудников, которые были в командировках больше чем 3 раза, в отсортированном по убыванию сумм суточных виде. Последний столбец назвать Сумма.
select name, sum((datediff(date_last, date_first) + 1) * per_diem) AS Сумма
from trip
group by name
having count(name) > 3
order by Сумма desc

14. Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, в соответствии с данными из таблицы traffic_violation. При этом суммы заносить только в пустые поля столбца  sum_fine.
update fine f, traffic_violation tv
set f.sum_fine = tv.sum_fine 
where (f.sum_fine is NULL) and (f.violation = tv.violation);

15. Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили одно и то же правило   два и более раз. При этом учитывать все нарушения, независимо от того оплачены они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, потом по номеру машины и, наконец, по нарушению.
select name, number_plate, violation 
from fine
group by name, number_plate, violation
having count(*)>=2
order by name asc, number_plate, violation;

16. В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных на предыдущем шаге записей. 
update fine,  
(select name, number_plate, violation 
from fine
group by name, number_plate, violation
having count(*)>=2) query_in
set sum_fine = (sum_fine * 2)
where (fine.date_payment is NULL and 
      fine.name = query_in.name and
      fine.number_plate = query_in.number_plate and
      fine.violation = query_in.violation);

17. Необходимо: в таблицу fine занести дату оплаты соответствующего штрафа из таблицы payment; уменьшить начисленный штраф в таблице fine в два раза  (только для тех штрафов, информация о которых занесена в таблицу payment) , если оплата произведена не позднее 20 дней со дня нарушения.
update fine f, payment p
set f.date_payment = p.date_payment,
f.sum_fine = if (DATEDIFF(p.date_payment, p.date_violation) < 21, f.sum_fine/2, f.sum_fine)
where
f.date_payment is null and (f.name,f.number_plate,f.violation) = (p.name,p.number_plate,p.violation);
select * from fine;