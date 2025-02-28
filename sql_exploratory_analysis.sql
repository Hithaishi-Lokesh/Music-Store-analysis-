-- 1) Who is the most senior employee on the job title

Select employee_id, last_name , first_name , levels from employee 
order by levels desc
limit 1

-- 2) which countries have the most invoices 

select billing_country, count (total)  as invoices from invoice
group by billing_country
order by invoices desc

--- 3) what  are the top 3 values  of total invoice

select total from invoice
order by total  desc
limit 3

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals.Return both the city name & sum of all invoice totals

select billing_city , sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1
	
	
---Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returnsthe person who has spent the most money.
	
select cusinfo.customer_id , cusinfo.first_name , cusinfo.last_name , sum(invoice.total)
from customer as cusinfo
join invoice
on cusinfo.customer_id = invoice.customer_id
group by cusinfo.customer_id
order by sum(invoice.total) desc
limit 1

----6) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
---	Return your list ordered alphabetically by email starting with A

select distinct customer.email , customer.first_name , last_name
from customer
join invoice 
on customer.customer_id = invoice.customer_id
join invoice_line 
on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
    join genre
    on track.genre_id = genre.genre_id
    where genre.name = 'Rock' 
)
order  by customer.email

----7)Let's invite the artists who have written the most rock music in our dataset. 
---Write a query that returns the Artist name and total track count of the top 10 rock bands

select artist.name , count(artist.artist_id) as total_track  
From track 
Join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
	group by  artist.artist_id
order by total_track desc
limit 10
	
----8) Return all the track names that have a song length longer than the average song length.
----Return the Name and Milliseconds for each track. 
----Order by the song length with the longest songs listed first

select name , milliseconds from track
where milliseconds <
	(
select avg(milliseconds) from track
)
order by milliseconds desc



---9)Find how much amount spent by each customer on artists? 
---Write a query to return customer name, artist name and total spent


select * from customer
select * from invoice
	select * from invoice_line
	select * from track
	select * from album
	select * from artist

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

	
---10)We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
----Write a query that returns each country along with the top Genre. 
---For countries where the maximum number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

---11)Write a query that determines the customer that has spent the most on music for each country. 
---Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

