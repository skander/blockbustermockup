view: total_rental_film {
 derived_table: {
  persist_for: "1 hour"
  indexes: ["film_id"]
  sql: SELECT film.film_id as film_id,
              film.title as title,
              count(distinct(rental.customer_id)) as total_customer_film
       FROM sakila.film film
       INNER JOIN sakila.inventory inventory
       ON film.film_id = inventory.inventory_id
       INNER JOIN sakila.rental rental
       ON rental.inventory_id = inventory.inventory_id
       group by 1,2
  ;;
    }

  dimension: film_id  {
    type: number
    sql: ${TABLE}.film_id ;;
  }
  dimension: title  {
    type: string
    sql: ${TABLE}.title ;;
  }
  dimension: total_customer_film {
    type: number
    sql: ${TABLE}.total_customer_film ;;
  }
}
