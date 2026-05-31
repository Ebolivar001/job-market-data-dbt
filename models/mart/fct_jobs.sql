{{ config(
    materialized='table',
    alias='fct_jobs',
    schema='marts'
) }}

select
    job_id,
    raw_row_id,
    company_id,
    location_id,
    job_title_short,
    job_title,
    job_via,
    job_schedule_type,
    is_work_from_home,
    job_posted_at,
    has_no_degree_mention,
    has_health_insurance,
    salary_rate,
    salary_year_avg,
    salary_hour_avg

from {{ ref('int_job_postings_cleaned') }}
