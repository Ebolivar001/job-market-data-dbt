{{ config(
    materialized='table',
    alias='dim_companies',
    schema='mart'
) }}

select
    company_id,
    company_name

from {{ ref('int_companies') }}
