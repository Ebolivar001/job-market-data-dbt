{{ config(
    materialized='table',
    schema='marts'
) }}

select
    job_id,
    skill_name

from {{ ref('int_job_skills') }}
