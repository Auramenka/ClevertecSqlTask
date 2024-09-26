-- Вывести к каждому самолету класс обслуживания и количество мест этого класса

select aircrafts.aircraft_code, seats.fare_conditions, count (seats.seat_no)
from aircrafts
    join seats on aircrafts.aircraft_code = seats.aircraft_code
group by aircrafts.aircraft_code, seats.fare_conditions;

-- Найти 3 самых вместительных самолета (модель + кол-во мест)

select aircrafts.model, count (seats.seat_no)
from aircrafts
    join seats on aircrafts.aircraft_code = seats.aircraft_code
group by aircrafts.model
order by count (seats.seat_no) desc
limit 3;

-- Вывести код, модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам

select aircrafts.aircraft_code, aircrafts.model, seats.seat_no
from aircrafts
    join seats on aircrafts.aircraft_code = seats.aircraft_code
where aircrafts.model = 'Аэробус A321-200' and seats.fare_conditions != 'Economy'
order by seats.seat_no;

-- Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)

select airports.airport_code, airports.airport_name, airport.city
from (select city
      from airports
      group by city
      having count(city) > 1) airport
    join airports on airports.city = airport.city;

-- Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

select flights.flight_id, flights.flight_no, flights.scheduled_departure
from flights
    join airports departure_airport on departure_airport.airport_code = flights.departure_airport
    join airports arrival_airport on arrival_airport.airport_code = flights.arrival_airport
where departure_airport.city = 'Екатеринбург' and arrival_airport.city = 'Москва'
    and flights.status in ('Scheduled', 'On Time', 'Delayed')
  and flights.scheduled_departure =
      (select min(flights.scheduled_departure)
       from flights
       join airports d_airport on d_airport.airport_code = flights.departure_airport
       join airports a_airport on a_airport.airport_code = flights.arrival_airport
       where d_airport.city = 'Екатеринбург' and a_airport.city = 'Москва'
  and flights.status in ('Scheduled', 'On Time', 'Delayed'));

-- Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)

select tickets.ticket_no, ticket_flights.amount
from tickets
    join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
where ticket_flights.amount = (select min(amount) from ticket_flights)
union all
select tickets.ticket_no, ticket_flights.amount
from tickets
    join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
where ticket_flights.amount = (select max(amount) from ticket_flights);

-- Вывести информацию о вылете с наибольшей суммарной стоимостью билетов

select flights.*, sum(ticket_flights.amount)
from flights
    join ticket_flights on ticket_flights.flight_id = flights.flight_id
group by flights.flight_id
having sum(ticket_flights.amount) = (select max(total_amount)
                                     from (select sum(ticket_flights.amount) as total_amount
                                           from ticket_flights
                                           join flights on ticket_flights.flight_id = flights.flight_id
                                           group by flights.flight_id) as subquery);

-- Найти модель самолета, принесшую наибольшую прибыль (наибольшая суммарная стоимость билетов). Вывести код модели, информацию о модели и общую стоимость

select aircrafts.aircraft_code, aircrafts.model, sum(ticket_flights.amount)
from ticket_flights
    join flights on ticket_flights.flight_id = flights.flight_id
    join aircrafts on flights.aircraft_code = aircrafts.aircraft_code
group by aircrafts.aircraft_code, aircrafts.model
having sum(ticket_flights.amount) = (select max(total_amount)
                                     from (select sum(ticket_flights.amount) as total_amount
                                           from ticket_flights
                                           join flights on ticket_flights.flight_id = flights.flight_id
                                           group by flights.aircraft_code) as subquery);

-- Найти самый частый аэропорт назначения для каждой модели самолета. Вывести количество вылетов, информацию о модели самолета, аэропорт назначения, город

select aircrafts.aircraft_code, aircrafts.model, flights.arrival_airport, airports.city, count(flights.arrival_airport)
from aircrafts
    join flights on aircrafts.aircraft_code = flights.aircraft_code
    join airports on flights.arrival_airport = airports.airport_code
group by aircrafts.aircraft_code, aircrafts.model, flights.arrival_airport, airports.city
having count(flights.arrival_airport) = (
    select max(flights_count)
    from (select count(flights.arrival_airport) as flights_count
          from flights
          where flights.aircraft_code = aircrafts.aircraft_code
          group by flights.arrival_airport) as subquery);