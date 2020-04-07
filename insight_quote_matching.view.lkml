view: insight_quote_matching {


derived_table: {
  sql:

 select
    *
    ,ins_new.acceptance as new_acceptance
    ,ins_old.acceptance as old_acceptance
  from
    (select *
     from
        qs_cover
     where customer_key <> '' and to_date(sysdate) - to_date(quote_dttm ) < 90
     ) cov

left join
    (select
      *
      ,case when live_member = 'Y' and aa_score_22sep2015 < 1.1 then 'Member'
              when live_member = 'N' and aa_score_22sep2015 < 1.1 and aa_score_22sep2015 > 0 and tenure_current > 0 then 'Ex-Member'
              when Live_member = 'N'
                   and (HOME_HISTORY = 'C' or HOME_HISTORY = 'X')
                   /*and aa_score_22sep2015 < 1.1*/ then 'Home'
              else 'Unacceptable' end as acceptance
      ,1 as current_match
     from
        insight
     )ins_old
    on cov.customer_key = ins_old.customer_key
    and ins_old.acceptance <> 'Unacceptable'

left join
    (select
      *
      ,case when live_member = 'Y' and aa_score_22sep2015 < 1.1 then 'Member'
              when live_member = 'N' and aa_score_22sep2015 < 1.1 and aa_score_22sep2015 > 0 and tenure_current > 0 then 'Ex-Member'
              when Live_member = 'N'
                   and (HOME_HISTORY = 'C' or HOME_HISTORY = 'X')
                   /*and aa_score_22sep2015 < 1.1*/ then 'Home'
              else 'Unacceptable' end as acceptance
      ,1 as new_match
     from
        staging_insight_row
     )ins_new
    on cov.customer_key = ins_new.customer_key
    and ins_new.acceptance <> 'Unacceptable'

         ;;
}

 dimension: acceptance_type_current {
  type: string
  sql: old_acceptance ;;
 }

  dimension: acceptance_type_new {
    type: string
    sql: new_acceptance ;;
  }

  measure: quotes_matched_new {
    type: sum
    sql: new_match;;
  }

  measure: quotes_matched_current {
    type: sum
    sql: current_match;;
  }





}
