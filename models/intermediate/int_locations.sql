{{ config(
    materialized='view',
    alias='int_locations',
    schema='intermediate'
) }}


with int_job_postings_cleaned as (
    select * 
    from {{ ref('int_job_postings_cleaned') }}
)
select
location_id
, job_location
, search_location
, job_country

from int_job_postings_cleaned

group by
location_id, job_location, search_location, job_country
