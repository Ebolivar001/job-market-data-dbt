{{ config(
    materialized='table',
    alias='dim_companies',
    schema='marts'
) }}

select
    company_id,
    company_name

from {{ ref('int_companies') }}
