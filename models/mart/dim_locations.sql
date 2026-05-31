{{ config(
    materialized='table',
    alias='dim_locations',
    schema='marts'
) }}

select
    location_id,
    job_location,
    job_country

from {{ ref('int_locations') }}
