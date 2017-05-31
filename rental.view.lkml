view: rental {
  sql_table_name: sakila.rental ;;

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: customer_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: inventory_id {
    type: number
    sql: ${TABLE}.inventory_id ;;
  }

  dimension_group: last_update {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_update ;;
  }

  dimension_group: rental {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.rental_date ;;
  }

  dimension: overdue_flag {
    type: yesno
    sql: datediff(CurDate(),${rental_date})>14 and ${return_date} is null;;
  }
 dimension: late_flag {
  type: yesno
  sql: datediff(${return_date},${rental_date})>7 ;;
}

  dimension_group: return {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.return_date ;;
  }

  dimension: staff_id {
    type: yesno
    sql: ${TABLE}.staff_id ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_id, customer.customer_id, customer.last_name, customer.first_name, payment.count]
  }
  measure: total_overdue {
    type: count
    filters: {
      field: overdue_flag
      value: "yes"
          }
    }
  measure: total_late {
    type: count
    filters: {
      field: late_flag
      value: "yes"
    }
  }
    measure: ratio_overdue {
      type: number
      value_format_name: percent_1
      sql: (1.0*${total_overdue})/NULLIF(${count},0) ;;
    }
  measure: ratio_late {
    type: number
    value_format_name: percent_1
    sql: (1.0*${total_late})/NULLIF(${count},0) ;;
  }

}
