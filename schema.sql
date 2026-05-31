create schema if not exists mart;

create table if not exists mart.dim_companies (
    company_id text primary key,
    company_name text not null
);

create table if not exists mart.dim_locations (
    location_id text primary key,
    job_location text,
    job_country text
);

create table if not exists mart.dim_skills (
    skill_name text primary key
);

create table if not exists mart.fct_jobs (
    job_id text primary key,
    raw_row_id bigint not null unique,
    company_id text not null references mart.dim_companies (company_id),
    location_id text not null references mart.dim_locations (location_id),
    job_title_short text,
    job_title text,
    job_via text,
    job_schedule_type text,
    is_work_from_home boolean,
    job_posted_at timestamp,
    has_no_degree_mention boolean,
    has_health_insurance boolean,
    salary_rate text,
    salary_year_avg numeric,
    salary_hour_avg numeric
);

create table if not exists mart.bridge_job_skills (
    job_id text not null references mart.fct_jobs (job_id),
    skill_name text not null references mart.dim_skills (skill_name),
    primary key (job_id, skill_name)
);
