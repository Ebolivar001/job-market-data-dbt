{{ config(
    materialized='table',
    alias='dim_skills',
    schema='mart'
) }}

select
    skill_name

from {{ ref('int_skills') }}
