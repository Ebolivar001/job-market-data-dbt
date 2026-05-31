{{ config(
    materialized='table',
    alias='dim_skills',
    schema='marts'
) }}

select
    skill_name

from {{ ref('int_skills') }}
