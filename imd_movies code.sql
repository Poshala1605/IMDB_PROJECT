create database IMD_movie;
use imd_movies;

#--Segment 1: Database - Tables, Columns, Relationships

	---What are the different tables in the database?  
    --ans: total there are 6 tables (
    1. movie,2. genre, 3. dirctor_mapping, 4.role_mapping, 5.rating, 6.  names )
    
    --how are they connected to each other in the database?
    
    --movie table field id connected with role_mapping table Field movie_id
    --movie table field id connected with genre table Field movie_id
    --movie table field id connected with ratting table Field movie_id
    --names table field id connected with dirctor_mapping table Field name_id
    --names table field id connected with role_mapping table Field name_id
    
--Find the total number of rows in each table of the schema?

SELECT count(*) FROM movie;
SELECT count(*) FROM genre;
SELECT counT(*) FROM rating;
SELECT count(*) FROM role_mapping;
select count(*) from rating;
select count(*) from dirctor_mapping;

 --Identify which columns in the movie table have null values  
 
 set sql_safe_updates=0;
 Update movie set country= null where country =''; 
 SELECT count(*) from movie where country is null;
 --O/P=20
 Update movie set worlwide_gross_income =null where worlwide_gross_income = '';
 SELECT count(*) from movie where worlwide_gross_income is null;
 --O/P=3724
 Update movie set languages=null where languages = '';
 SELECT count(*) from movie where languages is null;
 --O/P=194
 update genre set movie_id=null where movie_id='';
 SELECT count(*) from genre where movie_id is null;
 --o/p= 0
 
 #--Segment 2: movie Release Trends   
--1. Determine the total number of movie released each year and analyse the month-wise trend.
    
    select year, substr(date_published,4,2) as month, count(id) from movie
    group by year,month order by year,substr(date_published,4,2);
    
    
    --2.	Calculate the number of movie produced in the USA or India in the year 2019.
    
    select count(id) from movie where (country = 'india' or country='usa') and year in (2019);
    
#---Segment 3: Production Statistics and Genre Analysis
    
-3a.	Retrieve the unique list of genres present in the dataset.

select  distinct genre from  genre
left join movie on (movie.id=genre.movie_id);

--3b.	Identify the genre with the highest number of movie produced overall;

select genre, count(movie_id)a from genre group by genre order by a desc limit 1;

select genre.genre,count(id) as movie from movie
left join genre on (movie.id=genre.movie_id)
group by genre.genre order by movie desc limit 1;

--o/p 'Drama', '4285'


with cte as


(select id as movie_count , count(distinct genre) as genres from movie
         left join genre on (movie.id = genre.movie_id) 
group by id
		 having count(distinct genre) = 1) 
         select count(movie_count) from cte;	 


-3c.	Determine the count of movie that belong to only one genre;

with cte as 
(select movie_id, count(genre) from genre group by movie_id having count(genre)=1)
select count(movie_id) from cte;


--3d.	Calculate the average duration of movie in each genre;

select genre.genre, avg(duration) as movie from movie
left join genre on (movie.id=genre.movie_id)
group by genre.genre order by 1;

-- 3e	Find the rank of the 'thriller' genre among all genres in terms of the number of movie produced;

select genre.genre, count(movie.id), rank() over(order by count(movie.id) desc) as genre_rank from movie
left join genre on (movie.id=genre.movie_id)
group by genre.genre; 
  
 select * from (
 select genre, count(movie_id) as movie_count, rank() over(order by count(movie_id) desc) as genre_rank from genre
 group by genre) a
 where genre='Thriller';
 
-- O/P 'Thriller', '1484', '1'

 
 Segment 4: Ratings Analysis and Crew Members
 
--4a	Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).

select min(avg_rating), max(avg_rating), min(total_votes), max(total_votes), min(median_rating), max(median_rating)  from ratings;

--4b	Identify the top 10 movie based on average rating

 SELECT avg_rating, count(movie_id) as top10_movie  
FROM ratings
group by avg_rating order by top10_movie desc limit 10;

--4c.	Summarise the ratings table based on movie counts by median ratings.

SELECT median_rating, count(movie_id) as movie_count  
FROM ratings
group by median_rating order by median_rating;

select * from ratings

--4c.	Identify the production house that has produced the most number of hit movie (average rating > 8).

select  movie.production_company as production_house,count(movie.id) as movie
from movie left join ratings on (movie.id=ratings.movie_id) 
where ratings.avg_rating > 8
group by production_house   order by movie desc;

--4d.	Determine the number of movie released in each genre during March 2017 in the USA with more than 1,000 votes.

select genre.genre,substr(movie.date_published,4,7) as monthas,count(genre.movie_id) from movie
left join genre on ( genre.movie_id=movie.id) 
left join ratings on (ratings.movie_id=movie.id) where movie.country='usa'  and
ratings.total_votes>1000 group by genre.genre, substr(date_published,4,7)
 having monthas='03-2017';


--4e	Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.

select genre.genre,count(genre.movie_id) as movie from genre
left join ratings on ( ratings.movie_id=genre.movie_id)
where genre like 'T%' and ratings.avg_rating>8
group by genre.genre;

 #-- Segment 5: Crew Analysis
 
--5a	Identify the columns in the names table that have null values.
set sql_safe_updates=0;


update names set id='null' where id='';
select count(*) from names where id is null;

update names set known_for_movies ='null' where known_for_movies ='';
select count(*) from names where known_for_movies is null;

update names set height='null' where height='';
select count(*) from names where height is null;

update names set date_of_birth='null' where date_of_birth ='';
select count(*) from names where date_of_birth is null;


-- 5b Determine the top three directors in the top three genres with movie having an average rating > 8.


with cte as (
select  genre, name_id as director_id  , count(id) as movie
from movie
left join genre on (movie.id = genre.movie_id)
left join director_mapping on (movie.id = director_mapping.movie_id)
group by name_id , genre order by  genre, movie desc),
-- 2. Ranking for director
cte2 as
(select * , row_number() over(partition by genre order by movie desc) as pos  from cte
 where director_id is not null
order by genre, pos  ),


cte3 as
(select genre , count(genre.movie_id) as movie from genre
left join ratings on (ratings.movie_id=genre.movie_id)
where avg_rating > 8
group by genre order by movie desc limit 3)
select director_id, name , genre,pos  from cte2
left join names on (cte2.director_id = names.id)
 where pos <= 3
and genre in (select genre from cte3)
order by genre, pos;

-- 5c Find the top two actors whose movie have a median rating >= 8.


select name as actor_name, count(r.movie_id) as movie
FROM   role_mapping r
                INNER JOIN names n
                        ON n.id = r.name_id
                INNER JOIN ratings r1
                        ON r1.movie_id = r.movie_id
         WHERE  r.category = 'actor'
                AND median_rating >= 8
         GROUP  BY actor_name order by  movie  desc limit 2;

-- 5d	Identify the top three production houses based on the number of votes received by their movie.

select production_company, count(movie_id), sum(total_votes) as votes
from movie 
inner join ratings on(movie.id=ratings.movie_id)
group by production_company order by votes desc limit 3;

-- 5e Rank actors based on their average ratings in Indian movie released in India.

select a.*, n.name from
(select name_id,rank() over(order by avg_rating desc) as rank_of_actor from movie
left join role_mapping on (movie.id=role_mapping.movie_id)
left join ratings on (movie.id=ratings.movie_id)
where country= 'india' and category='actor')a
left join names n on (a.name_id=n.id);

-- 5f Identify the top five actresses in Hindi movie released in India based on their average ratings;

select distinct name_id, row_number() over(order by avg_rating desc) from movie 
left join role_mapping on (movie.id=role_mapping.movie_id)
left join ratings on (movie.id=ratings.movie_id)
where languages='Hindi' and category='actress' and country='india' limit 10;

#-- Segment 6: Broader Understanding of Data

-- 6a	Classify thriller movie based on average ratings into different categories.

select id , avg_rating ,
case when avg_rating > '6' then 'Hit Movie'
     when avg_rating < '6' then 'Flop Movie'
	 else 'Avg Movie' end as Movie_category
from movie m left join genre g on (m.id = g.movie_id)
left join ratings r on (m.id = r.movie_id)
where genre = 'Thriller';

-- 6b	analyse the genre-wise running total and moving average of the average movie duration;

select  genre , duration ,
sum(duration) over(partition by genre order by id asc) cum_sum,
avg(duration) over(partition by genre order by id asc) moving_average
from movie
left join genre on (movie.id = genre.movie_id) order by genre , id;
	
-- 6c	Identify the five highest-grossing movie of each year that belong to the top three genres.

select  year,genre ,sum(worlwide_gross_income)
from movie 
left join genre on (movie.id = genre.movie_id) 
group by year,genre

select worlwide_gross_income from movie




-- 6d Determine the top two production houses that have produced the highest number of hits among multilingual movie.

select  production_company , count(id)
	from movie where  languages like '%,%,%,%'
    group by 1 order by count(id) desc limit 2;


-- 6e	Identify the top three actresses based on the number of Super Hit movie (average rating > 8) in the drama genre.

select name, genre,avg_rating from ratings r
left join genre g on (r.movie_id=g.movie_id)
left join role_mapping rm on (r.movie_id=rm.movie_id) 
left join names n on (rm.name_id=n.id)
order by avg_rating desc limit 3;


-- 6f	Retrieve details for the top nine directors based on the number of movie, including average inter-movie duration, ratings, and more.

select  director_mapping.name_id as director_id ,
	count(id) as Num_of_movie,
	avg(duration) as avg_movie_duration,
	avg(avg_rating) as avg_rating
	from movie
left join ratings on (movie.id = ratings.movie_id)
left join director_mapping on (movie.id = director_mapping.movie_id)
where  director_mapping.name_id is not null
group by director_mapping.name_id order by Num_of_movie desc limit 9;



Segment 7: Recommendations

-	Based on the analysis, provide recommendations for the types of content Bolly movie should focus on producing.
BOLLY MOVIE FOCUS ON DIRECTORS 1)Steven Soderbergh	
                               2)Jesse V. Johnson
AND GENRE ACTION, COMEDY,DRAMA                               






















































 

 

-	Find the top two actors whose movie have a median rating >= 8.




-	Identify the top three production houses based on the number of votes received by their movie.



-	Rank actors based on their average ratings in Indian movie released in India.
-	Identify the top five actresses in Hindi movie released in India based on their average ratings.

 
 
 
 
 
 
 
 
 
 
 
			