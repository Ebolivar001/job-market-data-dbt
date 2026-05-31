{{ config(
    materialized='view',
    alias='int_companies',
    schema='intermediate'
) }}


with int_job_postings_cleaned as (
    select * 
    from {{ ref('int_job_postings_cleaned') }}
)

select
company_id  
, company_name

from int_job_postings_cleaned
group by
company_id
, company_name
