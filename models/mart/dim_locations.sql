{{ config(
    materialized='table',
    schema='marts'
) }}

select distinct
    location_id,
    job_location,
    search_location,
    job_country

from {{ ref('int_job_postings_cleaned') }}
