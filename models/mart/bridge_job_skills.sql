{{ config(
    materialized='table',
    alias='bridge_job_skills',
    schema='mart'
) }}

select
    job_id,
    skill_name

from {{ ref('int_job_skills') }}
