{{ config(
    materialized='view',
    schema='staging'
) }}



with source_data as (
    select * from {{ source('raw', 'job_postings_raw') }}
)


select
raw_row_id
, job_title_short
, job_title
, job_location
, job_via
, job_schedule_type
, job_work_from_home as is_work_from_home
, search_location
, job_posted_date
, job_no_degree_mention as has_no_degree_mention
, job_health_insurance as has_health_insurance
, job_country
, salary_rate
, salary_year_avg
, salary_hour_avg
, company_name
, job_skills as job_skills_raw
, job_type_skills as job_type_skills_raw

from source_data
