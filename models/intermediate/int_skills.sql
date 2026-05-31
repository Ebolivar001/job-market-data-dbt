{{ config(
    materialized='view',
    alias='int_skills',
    schema='intermediate'
) }}

select
skill_name

from {{ ref('int_job_skills') }}

group by
skill_name
