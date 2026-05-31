{{ config(
    materialized='view',
    alias='int_job_skills_exploded',
    schema='intermediate'
) }}

select
job_id
, coalesce(lower(trim(skill_name)), 'unknown_skill') as skill_name

from {{ ref('int_job_skill_lists') }}
cross join lateral unnest(string_to_array(skills_csv, ',')) as skill(skill_name)

where nullif(lower(trim(skill_name)), '') is not null
