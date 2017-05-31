view: total_rental {
  derived_table: {
    persist_for: "1 hour"
    indexes: ["customer_id"]
    sql: SELECT count(distinct rental.customer_id) as total_customer
        from sakila.rental rental ;;
}
  dimension: total_customer {
    type: number
    sql: ${TABLE}.total_customer ;;
    view_label: "Rental Purchase Affinity"
    label: "Total customers"
  }
}
