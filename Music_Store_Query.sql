/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
select first_name,last_name,levels,title 
from employee 
order by levels desc 
limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country as country,
count(invoice_id) from invoice 
group by billing_country 
order by count(invoice_id) desc,country asc 

/* Q3: What are top 3 values of total invoice? */

select invoice_id,total 
from invoice 
order by total desc 
limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as total
from invoice 
group by billing_city 
order by sum(total) desc 
limit 1


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id,customer.first_name,customer.last_name,sum(total) 
from customer 
join invoice on invoice.customer_id=customer.customer_id 
group by customer.customer_id 
order by sum(total) desc 
limit 1

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


select * from playlist;

select distinct email,first_name,last_name,genre.name 
from customer 
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id 
join track on track.track_id=invoice_line.track_id 
join genre on track.genre_id=genre.genre_id 
where genre.name like 'Rock'
order by customer.email asc

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id,artist.name,count(artist.artist_id) 
from artist 
join album on album.artist_id=artist.artist_id 
join track on track.album_id=album.album_id 
join genre on track.genre_id=genre.genre_id 
where genre.name like 'Rock' 
group by artist.artist_id 
order by count(artist.artist_id) desc 
limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name 
from track 
where milliseconds > (select avg(milliseconds) from track) 
order by milliseconds desc


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */



WITH best_selling_artist as (
	
	select artist.artist_id,artist.name as name,sum(invoice_line.quantity*invoice_line.unit_price) as total from artist 
	join album on album.artist_id=artist.artist_id
	join track on track.album_id=album.album_id
	join invoice_line on invoice_line.track_id=track.track_id
	group by artist.artist_id
	order by total desc
	limit 1
	
)

select customer.customer_id,customer.first_name,customer.last_name,bsa.name,sum(invoice_line.quantity*invoice_line.unit_price) as total from customer join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id 
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join best_selling_artist as bsa on bsa.artist_id=artist.artist_id
group by 1,2,3,4
order by total desc


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


with pupular_genre as (
	select invoice.billing_country as c,
	genre.name g,count(invoice_line.quantity) as total 
	,ROW_NUMBER() over (partition by invoice.billing_country order by count(invoice_line.quantity) desc) r
from invoice 
join invoice_line on invoice_line.invoice_id=invoice.invoice_id 
join track on track.track_id=invoice_line.track_id 
join genre on genre.genre_id=track.genre_id 
group by invoice.billing_country,genre.name 
order by c asc,total desc)

select c,g,total,r from pupular_genre where r<=1


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with most_spent as

(select customer.customer_id id,
 customer.first_name f,
 invoice.billing_country c,
 sum(invoice.total) s,
 ROW_NUMBER() over (partition by invoice.billing_country  order by sum(invoice.total)  desc) r
from customer 
join invoice on customer.customer_id = invoice.customer_id 
group by 1,2,3 
order by 3 asc,4 desc)

select id,f,c,s from most_spent where r<=1


