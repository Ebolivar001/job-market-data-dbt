{{ config(
    materialized='table',
    schema='marts'
) }}

select distinct
    company_id,
    company_name

from {{ ref('int_job_postings_cleaned') }}
