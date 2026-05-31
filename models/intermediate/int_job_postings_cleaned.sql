{{ config(
    materialized='view',
    alias='int_job_postings_cleaned',
    schema='intermediate'
) }}

select
raw_row_id
, job_id
, job_title_short
, job_title
, job_via
, job_schedule_type
, company_name
, company_id
, job_location
, search_location
, job_country
, location_id
, is_work_from_home
, has_no_degree_mention
, has_health_insurance
, job_posted_at
, salary_rate
, salary_year_avg
, salary_hour_avg
, job_skills_raw
, skills_csv
, job_type_skills_raw
from {{ ref('int_job_postings_transformed') }}