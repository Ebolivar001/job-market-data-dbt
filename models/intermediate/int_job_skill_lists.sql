{{ config(
    materialized='view',
    alias='int_job_skill_lists',
    schema='intermediate'
) }}

select
job_id
, regexp_replace(job_skills_raw, '^\[|\]$|''|"', '', 'g') as skills_csv

from {{ ref('int_job_postings_cleaned') }}

where job_skills_raw is not null
