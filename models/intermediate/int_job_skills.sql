{{ config(
    materialized='view',
    alias='int_job_skills',
    schema='intermediate'
) }}


with int_job_skills_exploded as (
    select * 
    from {{ ref('int_job_skills_exploded') }}
)
select
job_id
, skill_name

from int_job_skills_exploded
group by
job_id, skill_name
