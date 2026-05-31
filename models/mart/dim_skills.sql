{{ config(
    materialized='table',
    schema='marts'
) }}

select distinct
    skill_name

from {{ ref('int_job_skills') }}
