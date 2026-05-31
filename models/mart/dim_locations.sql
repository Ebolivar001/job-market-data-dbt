{{ config(
    materialized='table',
    alias='dim_locations',
    schema='mart'
) }}

select
    location_id,
    job_location,
    job_country

from {{ ref('int_locations') }}
