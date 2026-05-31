{{ config(
    materialized='table',
    schema='marts'
) }}

select
    company_id,
    company_name

from {{ ref('int_companies') }}
