view: rental_affinity {
  derived_table: {
    persist_for: "1 hour"
    indexes: ["title_a"]
    sql: SELECT title_a
      , title_b
      , joint_order_count
      , top1.total_customer_film as title_a_order_count   -- total number of orders with title A in them
      , top2.total_customer_film as title_b_order_count   -- total number of orders with title B in them
      FROM (
        SELECT op1.title as title_a
        , op2.title as title_b
        , count(*) as joint_order_count
        FROM ${rental_film.SQL_TABLE_NAME} as op1
        JOIN ${rental_film.SQL_TABLE_NAME} op2
        ON op1.customer_id = op2.customer_id
        AND op1.title <> op2.title  -- ensures we don't match on the same order items in the same order, which would corrupt our frequency metrics

        GROUP BY title_a, title_b
      ) as prop
      JOIN ${total_rental_film.SQL_TABLE_NAME} as top1 ON prop.title_a = top1.title
      JOIN ${total_rental_film.SQL_TABLE_NAME} as top2 ON prop.title_b = top2.title
      ORDER BY title_a, joint_order_count DESC, title_b
       ;;
  }


  dimension: title_a {
    type: string
    sql: ${TABLE}.title_a ;;
  }

  dimension: title_b {
    type: string
    sql: ${TABLE}.title_b ;;
  }

  dimension: joint_order_count {
    description: "How many times item A and B were purchased in the same order"
    type: number
    sql: ${TABLE}.joint_order_count ;;
    value_format: "#"
  }

  dimension: title_a_order_count {
    description: "Total number of orders with title A in them, during specified timeframe"
    type: number
    sql: ${TABLE}.title_a_order_count ;;
    value_format: "#"
  }

  dimension: title_b_order_count {
    description: "Total number of orders with title B in them, during specified timeframe"
    type: number
    sql: ${TABLE}.title_b_order_count ;;
    value_format: "#"
  }

  #  Frequencies
  dimension: title_a_order_frequency {
    description: "How frequently orders include title A as a percent of total orders"
    type: number
    sql: 1.0*${title_a_order_count}/${total_rental.total_customer} ;;
    value_format: "#.00%"
  }

  dimension: title_b_order_frequency {
    description: "How frequently orders include title B as a percent of total orders"
    type: number
    sql: 1.0*${title_b_order_count}/${total_rental.total_customer} ;;
  }

  #     value_format: '#.00%'

  dimension: joint_order_frequency {
    description: "How frequently orders include both title A and B as a percent of total orders"
    type: number
    sql: 1.0*${joint_order_count}/${total_rental.total_customer} ;;
    value_format: "#.00%"
  }

  # Affinity Metrics

  dimension: add_on_frequency {
    description: "How many times both titles are purchased when title A is purchased"
    type: number
    sql: 1.0*${joint_order_count}/${title_a_order_count} ;;
    value_format: "#.00%"
  }

  dimension: lift {
    description: "The likelihood that buying title A drove the purchase of title B"
    type: number
    sql: 1*${joint_order_frequency}/(${title_a_order_frequency} * ${title_b_order_frequency}) ;;
  }

  ## Do not display unless users have a solid understanding of  statistics and probability models
  dimension: jaccard_similarity {
    description: "The probability both items would be purchased together, should be considered in relation to total order count, the highest score being 1"
    type: number
    sql: 1.0*${joint_order_count}/(${title_a_order_count} + ${title_b_order_count} - ${joint_order_count}) ;;
    value_format: "#,##0.#0"
  }

  # Aggregate Measures - ONLY TO BE USED WHEN FILTERING ON AN AGGREGATE DIMENSION (E.G. BRAND_A, CATEGORY_A)


  measure: aggregated_joint_order_count {
    description: "Only use when filtering on a rollup of title items, such as brand_a or category_a"
    type: sum
    sql: ${joint_order_count} ;;
  }
}
