1.  Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. Информацию вывести по убыванию результатов тестирования.
select name_student, date_attempt, result
from student inner join attempt using(student_id)
             inner join subject on attempt.subject_id = subject.subject_id and name_subject = "Основы баз данных"
order by result desc;

2. Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных ответов на вопросы теста, который занесен в столбец result.  В результат включить название дисциплины, а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.
select name_subject, count(attempt_id) as Количество, round(avg(result), 2) as Среднее
from subject left join attempt using(subject_id)
group by name_subject 
order by Среднее desc;

3. Вывести студентов (различных студентов), имеющих максимальные результаты попыток . Информацию отсортировать в алфавитном порядке по фамилии студента.
select name_student, result
from student inner join attempt using(student_id)
group by name_student, result
having result = (select max(result) from attempt)
order by name_student;

4. Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. 
select name_student, name_subject, datediff(max(date_attempt), min(date_attempt)) as Интервал
from student inner join attempt using (student_id)
             inner join subject using (subject_id)
group by name_student, name_subject
having count(date_attempt) >1
order by Интервал;

5. Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.
select  name_subject, count(distinct(student_id)) as Количество
from subject left join attempt using(subject_id)
group by name_subject
order by Количество desc, name_subject;

6. Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.
select question_id, name_question
from question inner join subject on question.subject_id = subject.subject_id and name_subject = "Основы баз данных"
order by rand()
limit 3;

7. Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет(вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат.
select name_question, name_answer, if(is_correct=true, "Верно", "Неверно") as Результат
from question inner join testing on question.question_id = testing.question_id and attempt_id = 7
              inner join answer using (answer_id);

8. Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух знаков после запятой. Вывести фамилию студента, название предмета, дату и результат. Последний столбец назвать Результат. Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.
select name_student, name_subject, date_attempt, round((count(is_correct)/3 * 100), 2) as Результат
from student inner join attempt using (student_id)
             inner join testing using (attempt_id)
             left join answer on testing.answer_id  = answer.answer_id and is_correct = true
             inner join subject on attempt.subject_id = subject.subject_id            
group by name_student, name_subject, date_attempt
order by name_student, date_attempt desc; 

9. Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству ответов, значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос, и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос), а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию дисциплины, потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке. Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".
select name_subject, concat(left(name_question, 30),"...") as Вопрос, count(testing.answer_id) as Всего_ответов, round(((sum(is_correct) / count(testing.answer_id)) * 100), 2) as Успешность
from subject inner join question using (subject_id)
             inner join testing using (question_id)
             left join answer on testing.answer_id  = answer.answer_id
group by name_subject, name_question
order by name_subject, Успешность desc, name_question; 

10. В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных». Установить текущую дату в качестве даты выполнения попытки.
insert into attempt (student_id, subject_id, date_attempt)
select student.student_id, subject.subject_id, now() 
from student inner join attempt on student.student_id = attempt.student_id and name_student = "Баранов Павел"
             inner join subject on attempt.subject_id = subject.subject_id and name_subject = "Основы баз данных";
             
insert into attempt (student_id, subject_id, date_attempt)
select student_id, subject_id, now()
from  student, subject
where name_student = 'Баранов Павел' and name_subject = 'Основы баз данных';

insert into attempt (student_id, subject_id, date_attempt)
(
    (select student_id from student where name_student = 'Баранов Павел'),
    (select subject_id from subject where name_subject = 'Основы баз данных'),
    now()
);

11.  Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается проходить студент, занесенный в таблицу attempt последним, и добавить их в таблицу testing.id последней попытки получить как максимальное значение id из таблицы attempt.
insert into testing (attempt_id, question_id)
select attempt_id, question_id
from  question
      inner join attempt using (subject_id)
where attempt_id = (select max(attempt_id) from attempt)
order by rand()
limit 3;

insert into testing (attempt_id, question_id)
values ((select max(attempt_id) from attempt), (select question_id
from question inner join attempt using (subject_id) order by rand() limit 1)),
((select max(attempt_id) from attempt), (select question_id
from question inner join attempt using (subject_id) order by rand() limit 1)),
((select max(attempt_id) from attempt), (select question_id
from question inner join attempt using (subject_id) order by rand() limit 1));

12. Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо вычислить результат(запрос) и занести его в таблицу attempt для соответствующей попытки.  Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до целого. Будем считать, что мы знаем id попытки,  для которой вычисляется результат, в нашем случае это 8.
update attempt
set result = (select round((sum(is_correct)/3 * 100), 0) from testing inner join answer on testing.answer_id  = answer.answer_id where attempt_id = 8)
where attempt_id = 8;

13. Вывести абитуриентов, которые хотят поступать на образовательную программу «Мехатроника и робототехника» в отсортированном по фамилиям виде.
select name_enrollee
from enrollee inner join program_enrollee using (enrollee_id)
             inner join program on program_enrollee.program_id = program.program_id and name_program = "Мехатроника и робототехника"
order by name_enrollee;

14. Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». Программы отсортировать в обратном алфавитном порядке.
select name_program 
from program inner join program_subject using (program_id)
             inner join subject on program_subject.subject_id = subject.subject_id and name_subject = "Информатика"
order by name_program desc;
 