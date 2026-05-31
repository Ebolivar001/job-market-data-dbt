{{ config(
    materialized='table',
    schema='marts'
) }}

select distinct
    job_id,
    skill_name

from {{ ref('int_job_skills') }}
