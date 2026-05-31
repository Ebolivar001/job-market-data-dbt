{{ config(
    materialized='table',
    alias='bridge_job_skills',
    schema='marts'
) }}

select
    job_id,
    skill_name

from {{ ref('int_job_skills') }}
