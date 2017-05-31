connection: "video_store"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }
explore: payment {
  join: customer {
    relationship: many_to_one
    type: left_outer
    sql_on: ${payment.customer_id} = ${customer.customer_id};;
  }
  join: rental {
    relationship: one_to_one
    type: left_outer
    sql_on: ${payment.rental_id} = ${rental.rental_id};;
  }
  join: inventory {
    relationship: one_to_one
    type: left_outer
    sql_on: ${rental.inventory_id} = ${inventory.inventory_id};;
  }
  join: film {
    relationship: one_to_many
    type: left_outer
    sql_on: ${film.film_id} = ${inventory.film_id};;
  }
  join: store {
    relationship: one_to_one
    type: left_outer
    sql_on: ${store.store_id} = ${inventory.film_id};;
  }

}

explore: rental_affinity {
  label: "Affinity"
  view_label: "Affinity"

  join: total_rental {
    type: cross
    relationship: many_to_one
  }
}
