view: insight_quote_matching {


derived_table: {
  sql:

 select
    *
    ,ins_new.acceptance as new_acceptance
    ,ins_old.acceptance as old_acceptance
    ,case when ins_new.acceptance ='Member' then 1
          when ins_new.acceptance ='Ex-Member' then 1
          when ins_new.acceptance ='Home' then 1
          else 0 end
          as new_acceptable_match
    ,case when ins_old.acceptance ='Member' then 1
          when ins_old.acceptance ='Ex-Member' then 1
          when ins_old.acceptance ='Home' then 1
          else 0 end
          as old_acceptable_match
    ,case when rct_noquote_an = 1 then 0 else 1 end as Actual_Quoted
  from
    (select *
            ,upper(squeeze(concat(left(replace(replace(replace(drv.surname,' ',''),'''',''),'-',''),5),'_',left(replace(forename,' ',''),1)))) as ck_suff
     from
        qs_cover c
     inner join
        qs_drivers drv
        on c.quote_id = drv.quote_id and drv.driver_id = 0
     where customer_key <> '' and to_date(sysdate) - to_date(c.quote_dttm ) < 90
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
      ,case when live_member = 'Y' then 'Member'
              when live_member = 'N' and aa_score_22sep2015 > 0 and tenure_current > 0 then 'Ex-Member'
              when Live_member = 'N'
                   and (HOME_HISTORY = 'C' or HOME_HISTORY = 'X')
                   then 'Home'
              else 'No Match' end as Match_type
      ,1 as current_match
     from
        insight
     )ins_old
    on left(ins_old.qas_premise_id,8) = cov.qqas1_address_key1 and cov.ck_suff = ins_old.ck_suffix
    and ins_old.match_type <> 'No Match'

left join
    (select
      *
      ,case when live_member = 'Y' and aa_score_22sep2015 < 1.1 then 'Member'
              when live_member = 'N' and aa_score_22sep2015 < 1.1 and aa_score_22sep2015 > 0 and tenure_current > 0 then 'Ex-Member'
              when Live_member = 'N'
                   and (HOME_HISTORY = 'C' or HOME_HISTORY = 'X')
                   /*and aa_score_22sep2015 < 1.1*/ then 'Home'
              else 'Unacceptable' end as acceptance
      ,case when live_member = 'Y' then 'Member'
              when live_member = 'N' and aa_score_22sep2015 > 0 and tenure_current > 0 then 'Ex-Member'
              when Live_member = 'N'
                   and (HOME_HISTORY = 'C' or HOME_HISTORY = 'X')
                   then 'Home'
              else 'No Match' end as Match_type
      ,1 as new_match
     from
        staging_insight_row
     )ins_new
    on left(ins_new.qas_premise_id,8) = cov.qqas1_address_key1 and cov.ck_suff = ins_new.ck_suffix
    and ins_new.Match_type <> 'No Match'

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

  measure:  old_acceptable_match{
    type: sum
    sql: old_acceptable_match ;;

  }

  measure:  new_acceptable_match{
    type: sum
    sql: new_acceptable_match ;;

  }

  measure: current_actual_quoted{
    type: number
    sql: sum(case when old_acceptable_match = 1 and Actual_Quoted = 1 then 1 else 0 end) ;;

  }

  measure: new_actual_quoted{
    type: number
    sql: sum(case when new_acceptable_match = 1 and Actual_Quoted = 1 then 1 else 0 end) ;;

  }

}
