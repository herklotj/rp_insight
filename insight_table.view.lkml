view: insight_table {

  derived_table: {
    sql:

    select
        *
    from
      insight


       ;;
  }

  dimension: live_member  {
    type: string
    sql: live_member ;;
  }

  dimension: live_product_count  {
    type: string
    sql: live_product_count ;;
  }

  dimension:   buildings_history  {
    type: string
    sql:   buildings_history ;;
  }

  dimension: contents_history {
    type: string
    sql: contents_history ;;
  }

  dimension: home_history {
    type: string
    sql: home_history ;;
  }

  dimension: motor_history {
    type: string
    sql: motor_history ;;
  }

  dimension: mem_history {
    type: string
    sql:  mem_history ;;
  }

  dimension: age {
    type: tier
    tiers: [20,30,40,50,60,70,80,90]
    style: integer
    sql:  age;;
  }

  dimension: tenure_current {
    type: tier
    tiers: [5,10,20,30,40]
    style: integer
    sql:  tenure_current;;
  }





  measure: Count {
    type: count

  }

  measure: breakdowns_ever {
    type: sum
    sql: num_breakdown_ever ;;
  }

  measure: current_motor {
    type: sum
    sql: case when motor_history='C' then 1.00 else 0.00 end ;;
  }

  measure: current_home {
    type: sum
    sql: case when home_history='C' then 1.00 else 0.00 end ;;
  }

  measure: live_member_count {
    type: sum
    sql: case when mem_history='C' then 1.00 else 0.00 end ;;
  }

  measure: members_with_motor_pct {
    type: number
    sql: ${current_motor}/nullif(${live_member_count},0)  ;;
    value_format_name: percent_1
  }

  measure: members_with_home_pct {
    type: number
    sql: ${current_home}/nullif(${live_member_count},0)  ;;
    value_format_name: percent_1
  }

}
