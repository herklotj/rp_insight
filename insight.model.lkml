connection: "echo_aapricing"

# include all the views
include: "*.view"

datagroup: insight_table_datagroup {
  max_cache_age: "24 hours"
}

persist_with: insight_table_datagroup

explore: insight_table {}
explore: insight_quote_matching {}
