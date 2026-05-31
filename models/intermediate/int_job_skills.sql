{{ config(
    materialized='view',
    alias='int_job_skills',
    schema='intermediate'
) }}

select distinct
job_id
, skill_name

from {{ ref('int_job_skills_exploded') }}
