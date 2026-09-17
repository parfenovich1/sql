select c.name, count(f.film_id) as count from public.category c 
join public.film_category f on c.category_id = f.category_id
group by c.name
order by count desc


select a.actor_id, a.first_name, a.last_name, count(r.rental_id) as count from public.actor a
join public.film_actor fa on fa.actor_id=a.actor_id
join public.film f on f.film_id=fa.film_id 
join public.inventory i on f.film_id = i.film_id 
join public.rental r on r.inventory_id = i.inventory_id 
group by a.actor_id, a.first_name, a.last_name
order by count desc
limit 10


select c.name, sum(p.amount) as sum from public.category c
join public.film_category fc on c.category_id = fc.category_id
join public.inventory i on i.film_id = fc.film_id 
join public.rental r on i.inventory_id = r.inventory_id 
join public.payment p on p.rental_id = r.rental_id
group by c.name
order by sum desc
limit 1


select f.title from public.film f 
left join public.inventory i on f.film_id = i.film_id 
where i.inventory_id is null


--select * from (
--    select a.first_name, a.last_name, count(fa.film_id) as count, dense_rank() over(order by count(fa.film_id) desc) as rank from public.actor a 
--    join public.film_actor fa on fa.actor_id = a.actor_id 
--    join public.film_category fc on fa.film_id = fc.film_id 
--    join public.category c on fc.category_id = c.category_id 
--    where c.name = 'Children' 
--    group by a.actor_id, a.first_name, a.last_name) as rating
--where rank <= 3
--order by count desc


with rating as (
	select a.first_name, a.last_name, count(fa.film_id) as count, dense_rank() over(order by count(fa.film_id) desc) as rank from public.actor a 
    join public.film_actor fa on fa.actor_id = a.actor_id 
    join public.film_category fc on fa.film_id = fc.film_id 
    join public.category c on fc.category_id = c.category_id 
    where c.name = 'Children' 
    group by a.actor_id, a.first_name, a.last_name
)
select * from rating
where rank <= 3
order by count desc


--select c.city, count(case cu.active when 1 then 1 else null end) as ones, count(case cu.active when 0 then 0 else null end) as zeros  from public.city c
--join public.address a on a.city_id = c.city_id 
--join public.customer cu on a.address_id = cu.address_id
--group by c.city
--order by zeros desc


select c.city, count(*) filter (where cu.active=1) as ones, count(*) filter (where cu.active=0) as zeros  from public.city c
join public.address a on a.city_id=c.city_id 
join public.customer cu on a.address_id=cu.address_id
group by c.city
order by zeros desc


--select ci.city, name, sum, nmb from 
--	(select ci.city_id, c.name, sum(rental_len.amount) as sum, row_number() over (partition by ci.city_id order by sum(rental_len.amount) desc) as nmb from 
--		(select r.rental_id, c.address_id, i.film_id, extract(epoch from (r.return_date - r.rental_date)) / 3600 as amount from public.rental r
--		join public.customer c on r.customer_id = c.customer_id
--		join public.inventory i on r.inventory_id = i.inventory_id
--		where r.return_date is not null) as rental_len
--	join public.address a on a.address_id = rental_len.address_id
--	join public.city ci on a.city_id = ci.city_id 
--	join public.film_category fc on fc.film_id = rental_len.film_id
--	join public.category c on c.category_id = fc.category_id
--	where ci.city like 'A%' or ci.city like '%-%'
--	group by ci.city_id, c.name) as amount
--join public.city ci on ci.city_id = amount.city_id
--where nmb = 1


with rental_len as (
	select r.rental_id, c.address_id, i.film_id, extract(epoch from (r.return_date - r.rental_date)) / 3600 as amount from public.rental r
	join public.customer c on r.customer_id = c.customer_id
	join public.inventory i on r.inventory_id = i.inventory_id
	where r.return_date is not null
),
amount as (
	select ci.city_id, c.name, sum(rental_len.amount) as sum, row_number() over (partition by ci.city_id order by sum(rental_len.amount) desc) as nmb from rental_len
	join public.address a on a.address_id = rental_len.address_id
	join public.city ci on a.city_id = ci.city_id 
	join public.film_category fc on fc.film_id = rental_len.film_id
	join public.category c on c.category_id = fc.category_id
	where ci.city like 'A%' or ci.city like '%-%'
	group by ci.city_id, c.name
)
select ci.city, name, sum, nmb from amount
join public.city ci on ci.city_id = amount.city_id
where nmb = 1

