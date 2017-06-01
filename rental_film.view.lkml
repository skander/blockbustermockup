view: rental_film {

  derived_table: {
    persist_for: "1 hour"
    indexes: ["film_id"]
    sql: SELECT film.film_id as film_id,
        film.title,
        rental.customer_id
        FROM sakila.film film
        INNER JOIN sakila.inventory inventory
        ON film.film_id = inventory.film_id
        INNER JOIN sakila.rental rental
        ON rental.inventory_id = inventory.inventory_id
        AND film.film_id < 200
        group by rental.customer_id,film.title, film_id;;
  }

  dimension: film_id  {
    type: number
    sql: ${TABLE}.film_id ;;
  }
  dimension: title  {
    type: string
    sql: ${TABLE}.title ;;
  }
  dimension: customer_id  {
    type: number
    sql: ${TABLE}.customer_id ;;
  }


 }
