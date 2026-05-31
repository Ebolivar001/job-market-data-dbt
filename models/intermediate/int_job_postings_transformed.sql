{{ config(
    materialized='view',
    alias='int_job_postings_transformed',
    schema='intermediate'
) }}


with stg_job_postings as (
    select * from {{ ref('stg_job_postings') }}
)


select
raw_row_id::bigint as raw_row_id
, md5(raw_row_id::text) as job_id
, nullif(trim(job_title_short::text), '') as job_title_short
, nullif(trim(job_title::text), '') as job_title
, nullif(trim(job_via::text), '') as job_via
, nullif(trim(job_schedule_type::text), '') as job_schedule_type
, coalesce(nullif(initcap(trim(company_name::text)), ''), 'Unknown') as company_name
, md5(coalesce(nullif(lower(trim(company_name::text)), ''), '__unknown_company__')) as company_id
, coalesce(nullif(initcap(trim(job_location::text)), ''), 'Unknown') as job_location
, coalesce(nullif(initcap(trim(search_location::text)), ''), 'Unknown') as search_location
, coalesce(nullif(initcap(trim(job_country::text)), ''), 'Unknown') as job_country
, md5(coalesce(nullif(lower(trim(job_location::text)), ''), '__unknown_location__') || '|' || coalesce(nullif(lower(trim(job_country::text)), ''), '__unknown_country__')) as location_id
, case
    when lower(trim(is_work_from_home::text)) in ('true', 't', 'yes', 'y', '1') then true
    when lower(trim(is_work_from_home::text)) in ('false', 'f', 'no', 'n', '0') then false
  end as is_work_from_home
, case
    when lower(trim(has_no_degree_mention::text)) in ('true', 't', 'yes', 'y', '1') then true
    when lower(trim(has_no_degree_mention::text)) in ('false', 'f', 'no', 'n', '0') then false
  end as has_no_degree_mention
, case
    when lower(trim(has_health_insurance::text)) in ('true', 't', 'yes', 'y', '1') then true
    when lower(trim(has_health_insurance::text)) in ('false', 'f', 'no', 'n', '0') then false
  end as has_health_insurance
, case
    case
    when job_posted_date::text ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}' then job_posted_date::timestamp
  end as job_posted_at
, nullif(trim(salary_rate::text), '') as salary_rate
, nullif(regexp_replace(salary_year_avg::text, '[^0-9.-]', '', 'g'), '')::numeric as salary_year_avg
, nullif(regexp_replace(salary_hour_avg::text, '[^0-9.-]', '', 'g'), '')::numeric as salary_hour_avg
, nullif(trim(job_skills_raw::text), '') as job_skills_raw
, nullif(trim(skills_csv::text), '') as skills_csv
, nullif(trim(job_type_skills_raw::text), '') as job_type_skills_raw

from stg_job_postings


