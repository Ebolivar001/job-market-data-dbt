{{ config(
    materialized='table',
    schema='marts'
) }}

select
    skill_name

from {{ ref('int_skills') }}
