---------------------------------------------------------
-- abbas.hooshmand
-- This code generates session level tables
-- and filters fraudulent tickets to better
-- calculate DACT scores.
---------------------------------------------------------

SET start_date = 2016-12-01;
SET end_date = 2017-10-31;

---------------------------------------------------------
-- Feedback
-- This table might contain trips with 5* rating.
-- Such trips should be assigned zero feedback
---------------------------------------------------------
drop table if exists secure_insurance.tmp_ah_driving_feedback_trips_2016_2017;
create table secure_insurance.tmp_ah_driving_feedback_trips_2016_2017
stored as parquet as

select a.trip_uuid,
       max(b.driver_uuid) as driver_uuid,
       max(b.client_uuid) as client_uuid,
       max(b.datestr) as datestr,
       max(case when a.value in ('driving', 'rough_driving', 'unsafe_driving',
                                 'distracted_driving', 'aggressive_driving') then 1 else 0 end) as dd_feedback
from dwh.fact_trip_feedback a
-- inner join ins_exposures.exposure_base b
inner join secure_insurance.exposure_trips b
on a.trip_uuid = b.uuid and a.datestr = b.datestr
where a.datestr between '${hiveconf:start_date}' and '${hiveconf:end_date}'
      and b.monthstr between '${hiveconf:start_date}' and '${hiveconf:end_date}'
      and a.feedback_type = 'tag'
      and a.reviewee_type = 'driver'
      -- and b.driver_rating in (1, 2, 3, 4)
      and a.value in ('other',
                'car_smell', 'car_quality', 'cleanliness', 'unclean_car', 'car_temperature', 'comfort',
                'driving', 'rough_driving', 'unsafe_driving', 'distracted_driving', 'aggressive_driving',
                'professionalism', 'unprofessional_clothing', 'conversation', 'music', 'rude_driver',
                'navigation', 'gps_route',
                'improper_dropoff', 'pickup', 'long_pickup')
group by 1;

---------------------------------------------------------
-- Ticket
-- This table contains IPD and DD tickets
---------------------------------------------------------

drop table if exists secure_insurance.tmp_ah_driving_ticket_trips_2016_2017_all_tickets;
create table secure_insurance.tmp_ah_driving_ticket_trips_2016_2017_all_tickets
stored as parquet as

select
    i.trip_uuid as trip_uuid,
    max(event_id) AS event_uuid,
    max(unix_timestamp(concat(substr(i.first_reported_at,1,10),' ',
          substr(i.first_reported_at,12,19)), 'yyyy-MM-dd HH:mm:ss') -
          unix_timestamp(i.trip_request_time)) as time_ticket_submission_after_request_seconds,
    max(i.trip_client_uuid) as client_uuid,
    max(i.trip_driver_uuid) as driver_uuid,
    max(level) as level,
    max(case when category = 'Dangerous Driving' then 1 else 0 end) as dd_ticket,
    max(case when category = 'Law Enforcement / Regulatory' then 1 else 0 end) as law_ticket,
    max(case when category = 'Vehicle Crash or Claim' then 1 else 0 end) as vcc_ticket,
    max(case when category in ('Dangerous Driving',
                               'Law Enforcement / Regulatory',
                               'Vehicle Crash or Claim') then 'DD' else 'IPC' end) as ticket_type
FROM secure_safety.on_trip_incidents i
where   1=1
        and from_unixtime(unix_timestamp(i.trip_request_time),
            'yyyy-MM-dd') between '${hiveconf:start_date}' and '${hiveconf:end_date}'
        and i.trip_country_name = 'United States'
        and ((category = 'Dangerous Driving' AND
                                subcategory IN ('Drowsy Driving',
                                'Other Poor/Dangerous Driving',
                                'Phone-related Distracted Driving'))
                        OR  (category = 'Law Enforcement / Regulatory' AND
                                subcategory IN ('Car Impounded',
                                'Driver Detained or Arrested',
                                'Driver Fined',
                                'Driver License / Plate Revoked',
                                'Driver Stopped'))
                        OR (category = 'Vehicle Crash or Claim' AND
                                subcategory IN ('Motor Vehicle Crash with Animal or Non Vehicle Object - Fatality',
                                'Motor Vehicle Crash with Animal or Non Vehicle Object - Hospitalization/Ambulance',
                                'Motor Vehicle Crash with Animal or Non Vehicle Object - Life-Altering Injuries Alleged',
                                'Motor Vehicle Crash with Animal or Non Vehicle Object - Minor/Moderate Injury',
                                'Motor Vehicle Crash with Animal or Non Vehicle Object - No Injury',
                                'Motor Vehicle Crash with One or More Motor Vehicles - Fatality',
                                'Motor Vehicle Crash with One or More Motor Vehicles - Hospitalization/Ambulance',
                                'Motor Vehicle Crash with One or More Motor Vehicles - Life-Altering Injuries Alleged',
                                'Motor Vehicle Crash with One or More Motor Vehicles - Minor/Moderate Injury',
                                'Motor Vehicle Crash with One or More Motor Vehicles - No Injury',
                                'Motor Vehicle Crash with Pedestrian or Pedalcycle - Fatality',
                                'Motor Vehicle Crash with Pedestrian or Pedalcycle - Hospitalization/Ambulance',
                                'Motor Vehicle Crash with Pedestrian or Pedalcycle - Life-Altering Injuries Alleged',
                                'Motor Vehicle Crash with Pedestrian or Pedalcycle - Minor/Moderate Injury',
                                'Motor Vehicle Crash with Pedestrian or Pedalcycle - No Injury'))
                        OR (category = 'Inappropriate Post-Trip Contact / Media Upload' AND
                            subcategory IN ('Live-Streaming / Non-Consensual Media Upload',
                                'Physical Stalking',
                                'Post-Trip Text Messages/Phone Calls/Communication'))
                    OR (category = 'Law Enforcement / Regulatory' AND
                            subcategory IN ('Active Kidnapping or Hostage Situation',
                                'Missing Person or Abduction Inquiry'))
                    OR (category = 'Physical Altercation' AND
                            subcategory IN ('No Weapon Involved - Fatality',
                            'No Weapon Involved - Fatality - Dispute over cash',
                            'No Weapon Involved - Fatality - Dispute over route',
                            'No Weapon Involved - Hospitalization/Ambulance',
                            'No Weapon Involved - Hospitalization/Ambulance - Dispute over cash',
                            'No Weapon Involved - Hospitalization/Ambulance - Dispute over route',
                            'No Weapon Involved - Life-Altering injuries alleged',
                            'No Weapon Involved - Life-Altering injuries alleged - Dispute over cash',
                            'No Weapon Involved - Life-Altering injuries alleged - Dispute over route',
                            'No Weapon Involved - Minor/Moderate Injury',
                            'No Weapon Involved - Minor/Moderate Injury - Dispute over cash',
                            'No Weapon Involved - Minor/Moderate Injury - Dispute over route',
                            'No Weapon Involved - No Injury',
                            'No Weapon Involved - No Injury - Dispute over cash',
                            'No Weapon Involved - No Injury - Dispute over route',
                            'Non Weapon Object Involved - Fatality',
                            'Non Weapon Object Involved - Fatality - Dispute over cash',
                            'Non Weapon Object Involved - Fatality - Dispute over route',
                            'Non Weapon Object Involved - Hospitalization/Ambulance',
                            'Non Weapon Object Involved - Hospitalization/Ambulance - Dispute over cash',
                            'Non Weapon Object Involved - Hospitalization/Ambulance - Dispute over route',
                            'Non Weapon Object Involved - Life-Altering Injuries Alleged',
                            'Non Weapon Object Involved - Life-Altering Injuries Alleged - Dispute over cash',
                            'Non Weapon Object Involved - Life-Altering Injuries Alleged - Dispute over route',
                            'Non Weapon Object Involved - Minor/Moderate Injury',
                            'Non Weapon Object Involved - Minor/Moderate Injury - Dispute over cash',
                            'Non Weapon Object Involved - Minor/Moderate Injury - Dispute over route',
                            'Non Weapon Object Involved - No Injury',
                            'Non Weapon Object Involved - No Injury - Dispute over cash',
                            'Non Weapon Object Involved - No Injury - Dispute over route',
                            'Spitting on Person',
                            'Weapon Involved - Fatality',
                            'Weapon Involved - Fatality - Dispute over cash',
                            'Weapon Involved - Fatality - Dispute over route',
                            'Weapon Involved - Hospitalization/Ambulance',
                            'Weapon Involved - Hospitalization/Ambulance - Dispute over cash',
                            'Weapon Involved - Hospitalization/Ambulance - Dispute over route',
                            'Weapon Involved - Life-Altering injuries alleged',
                            'Weapon Involved - Life-Altering injuries alleged - Dispute over cash',
                            'Weapon Involved - Life-Altering injuries alleged - Dispute over route',
                            'Weapon Involved - Minor/Moderate Injury',
                            'Weapon Involved - Minor/Moderate Injury - Dispute over cash',
                            'Weapon Involved - Minor/Moderate Injury - Dispute over route',
                            'Weapon Involved - No Injury',
                            'Weapon Involved - No Injury - Dispute over cash',
                            'Weapon Involved - No Injury - Dispute over route'))
                    OR (category = 'Potential Safety Concern' AND
                            subcategory IN ('Confinement',
                            'Non-Law Enforcement Missing Person or Abduction Inquiry'))
                    OR (category = 'Sexual Assault' AND
                            subcategory IN ('Attempted Kissing - Non-Sexual Body Part',
                            'Attempted Kissing - Sexual Body Part',
                            'Attempted Non-Consensual Sexual Penetration',
                            'Attempted Touching - Non-Sexual Body Part',
                            'Attempted Touching - Sexual Body Part',
                            'Non-Consensual Kissing - Non-Sexual Body Part',
                            'Non-Consensual Kissing - Sexual Body Part',
                            'Non-Consensual Sexual Penetration',
                            'Non-Consensual Touching - Non-Sexual Body Part',
                            'Non-Consensual Touching - Sexual Body Part'))
                    OR (category = 'Sexual Misconduct' AND
                            subcategory IN ('Comments or Gestures - Asking Personal Questions',
                            'Comments or Gestures - Comments About Appearance',
                            'Comments or Gestures - Explicit Comments',
                            'Comments or Gestures - Explicit Gestures',
                            'Comments or Gestures - Flirting',
                            'Displaying Indecent Material',
                            'Indecent Photography/Videography Without Consent',
                            'Masturbation / Indecent Exposure',
                            'Soliciting Sexual Act',
                            'Staring or Leering',
                            'Verbal Threat of Sexual Assault'))
                    OR (category = 'Theft or Robbery' AND
                            subcategory IN ('No Weapon Involved - Fatality',
                            'No Weapon Involved - Hospitalization/Ambulance',
                            'No Weapon Involved - Life-Altering Injuries Alleged',
                            'No Weapon Involved - Minor/Moderate Injury',
                            'No Weapon Involved - No Injury',
                            'Non Weapon Object Involved - Fatality',
                            'Non Weapon Object Involved - Hospitalization/Ambulance',
                            'Non Weapon Object Involved - Life-Altering Injuries Alleged',
                            'Non Weapon Object Involved - Minor/Moderate Injury',
                            'Non Weapon Object Involved - No Injury',
                            'Weapon Involved - Fatality',
                            'Weapon Involved - Hospitalization/Ambulance',
                            'Weapon Involved - Life-Altering Injuries Alleged',
                            'Weapon Involved - Minor/Moderate Injury',
                            'Weapon Involved - No Injury'))
                    OR (category = 'Verbal Altercation' AND
                            subcategory IN ('Discriminatory Remarks',
                            'Discriminatory Remarks - Dispute over cash',
                            'Discriminatory Remarks - Dispute over route',
                            'Threat of Violence with Weapon or Object',
                            'Threat of Violence with Weapon or Object - Dispute over cash',
                            'Threat of Violence with Weapon or Object - Dispute over route',
                            'Threat of Violence without Weapon',
                            'Threat of Violence without Weapon - Dispute over cash',
                            'Threat of Violence without Weapon - Dispute over route',
                            'Verbal Dispute',
                            'Verbal Dispute - Dispute over cash',
                            'Verbal Dispute - Dispute over route'))
                        )
group by 1;


---------------------------------------------------------
-- xcnp
-- This table contains claims
---------------------------------------------------------

drop table if exists secure_insurance.tmp_ah_xcnp_trips_2016_2017;
create table secure_insurance.tmp_ah_xcnp_trips_2016_2017
stored as parquet as

select
    a.trip_uuid,
    max(coalesce(cnt_xcnp_liab, 0)) as cnt_xcnp_liab,
    max(coalesce(gross_inc_loss_and_exp_liab, 0))/1000000.0 as liab_loss_dollar
from secure_insurance.claims_modeling_analytics a
where 1=1
      and CAST(loss_date AS STRING) between '${hiveconf:start_date}' and '${hiveconf:end_date}'
      and dev_month = 15
      and circumstance_index = '2'
group by trip_uuid;

---------------------------------------------------------
-- trip level combined
-- This table contains trip level information
---------------------------------------------------------
SET start_date = 2016-12-01;
SET end_date = 2017-10-31;
SET client_window = (partition by client_uuid
                     order by begintrip_timestamp_utc asc
                     rows between unbounded PRECEDING and 1 PRECEDING);

drop table if exists secure_insurance.tmp_ah_all_trips_2016_2017_v8;
create table secure_insurance.tmp_ah_all_trips_2016_2017_v8
stored as parquet as

with tmp as (
select a.uuid as trip_uuid,
       a.session_uuid,
       a.city_id,
       a.driver_uuid,
       a.client_uuid,
       a.trip_distance_miles,
       a.trip_duration_seconds,
       a.global_product_name,
       CASE WHEN a.global_product_name IN ('UberEATS Instant',
                                             'UberEATS Marketplace (delivery)',
                                             'uberRUSH',
                                             'Stunt')
            THEN 0
            ELSE 1
       END AS is_rides_trip,
       a.begintrip_timestamp_utc,
       -- session level
       g.session_distance_miles,
       g.session_duration_seconds,
       g.begintrip_timestamp_utc as beginsession_timestamp_utc,
       -- responces
       case when b.trip_uuid is not null and e.driver_rating in (1, 2, 3, 4) then 1
            else 0 end as any_feedback,
       case when e.driver_rating in (1, 2, 3, 4) then coalesce(b.dd_feedback, 0)
            else 0 end as dd_feedback,
       case when d.event_uuid is not null and d.ticket_type = 'DD' then 1 else 0 end as dact_ticket,
       case when d.event_uuid is not null and d.ticket_type = 'IPC' then 1 else 0 end as ipc_ticket,--new
       case when d.event_uuid is not null then coalesce(dd_ticket, 0) else 0 end as dd_ticket,
       case when d.event_uuid is not null then coalesce(vcc_ticket, 0) else 0 end as vcc_ticket,
       case when d.event_uuid is not null then coalesce(law_ticket, 0) else 0 end as law_ticket,
       case when d.event_uuid is not null then d.time_ticket_submission_after_request_seconds
            else null end as dd_ticket_seconds_after_trip,
       h.client_trip_number,
       h.driver_trip_number,
       e.driver_rating,
       coalesce(f.cnt_xcnp_liab, 0) as cnt_xcnp_liab_15m,
       coalesce(f.liab_loss_dollar, 0.0) as liab_loss_dollar_15m
from secure_insurance.exposure_trips a
left join secure_insurance.tmp_ah_driving_feedback_trips_2016_2017 b
on a.uuid = b.trip_uuid
left join secure_insurance.tmp_ah_driving_ticket_trips_2016_2017_all_tickets d
on a.uuid = d.trip_uuid
left join secure_insurance.exposure_rating_trips e
on a.uuid = e.trip_uuid
   and e.datestr between '${hiveconf:start_date}' and '${hiveconf:end_date}'
left join secure_insurance.tmp_ah_xcnp_trips_2016_2017 f
on a.uuid = f.trip_uuid
left join secure_insurance.exposure_sessions g
on a.session_uuid = g.session_uuid
   and g.datestr between '${hiveconf:start_date}' and '${hiveconf:end_date}'
left join dwh.fact_trip h
on a.uuid = h.uuid
   and a.datestr = h.datestr
   and h.datestr between '${hiveconf:start_date}' and '${hiveconf:end_date}'
where a.datestr between '${hiveconf:start_date}' and '${hiveconf:end_date}'
)

select tmp.*,
       avg(case when is_rides_trip = 1 then any_feedback * 1000.0
                else null end) over ${hiveconf:client_window} as avg_client_any_feedback_rate,
       avg(case when is_rides_trip = 1 then dact_ticket * 1000.0
                else null end) over ${hiveconf:client_window} as avg_client_dact_ticket_rate,
       avg(case when is_rides_trip = 1 then greatest(dact_ticket, ipc_ticket) * 1000.0
                else null end) over ${hiveconf:client_window} as avg_client_dact_ipc_ticket_rate,
       avg(case when is_rides_trip = 1 then driver_rating
                else null end) over ${hiveconf:client_window} as avg_client_rating,
       -- window for client so far
       sum(is_rides_trip) over ${hiveconf:client_window} as client_feedback_ticket_window_past_trips,
       sum(case when driver_rating is not null then is_rides_trip
                else 0 end) over ${hiveconf:client_window} as client_rating_window_past_trips
from tmp;

---------------------------------------------------------
-- This table has trip level information with client
-- credibility for their inputs (feedback, ticket, rating)
---------------------------------------------------------

-- Credibility for riders (trips > 50 for trip is_rides_trip = 1)
-- Credibility Calculations in link below:
-- https://workbench.uberinternal.com/explore/knowledge/localfile/abbas.hooshmand/Credibility.ipynb
SET mu_client_rating=4.852;
SET va_client_rating=4.712;
SET cred_coef_client_rating=client_rating_window_past_trips /
        (client_rating_window_past_trips + ${hiveconf:va_client_rating});

SET mu_client_feedback=12.689;
SET va_client_feedback=18.943;
SET cred_coef_client_feedback=client_feedback_ticket_window_past_trips /
        (client_feedback_ticket_window_past_trips + ${hiveconf:va_client_feedback});
-- Credibility for riders ticket
SET mu_client_dact_ticket=0.544;
SET va_client_dact_ticket=22.961;
SET cred_coef_client_dact_ticket=client_feedback_ticket_window_past_trips /
        (client_feedback_ticket_window_past_trips + ${hiveconf:va_client_dact_ticket});

-- Credibility for riders ticket
SET mu_client_any_ticket=0.855;
SET va_client_any_ticket=31.226;
SET cred_coef_client_any_ticket=client_feedback_ticket_window_past_trips /
        (client_feedback_ticket_window_past_trips + ${hiveconf:va_client_any_ticket});


drop table if exists secure_insurance.tmp_ah_all_trips_with_rider_cred_2016_2017_v8;
create table secure_insurance.tmp_ah_all_trips_with_rider_cred_2016_2017_v8
stored as parquet as

with clients as (
select client_uuid,
       min(client_trip_number) as min_client_trip_number
from secure_insurance.tmp_ah_all_trips_2016_2017_v8
group by 1
)

, drivers as (
select driver_uuid,
       min(driver_trip_number) as min_driver_trip_number
from secure_insurance.tmp_ah_all_trips_2016_2017_v8
group by 1
)

select a.*,
       row_number() over (partition by a.client_uuid
                          order by begintrip_timestamp_utc asc) +
       b.min_client_trip_number - 1 as client_trip_number_mod,-- dealing with null values in client_trip_number
       row_number() over (partition by a.driver_uuid
                          order by begintrip_timestamp_utc asc) +
       d.min_driver_trip_number - 1 as driver_trip_number_mod,-- dealing with null values in driver_trip_number
       coalesce((1.0 - ${hiveconf:cred_coef_client_feedback}) * ${hiveconf:mu_client_feedback} +
         ${hiveconf:cred_coef_client_feedback} * avg_client_any_feedback_rate,
         ${hiveconf:mu_client_feedback}) as rider_feedback_cred,
       coalesce((1.0 - ${hiveconf:cred_coef_client_dact_ticket}) * ${hiveconf:mu_client_dact_ticket} +
         ${hiveconf:cred_coef_client_dact_ticket} * avg_client_dact_ticket_rate,
         ${hiveconf:mu_client_dact_ticket}) as rider_dact_ticket_cred,
       coalesce((1.0 - ${hiveconf:cred_coef_client_any_ticket}) * ${hiveconf:mu_client_any_ticket} +
         ${hiveconf:cred_coef_client_any_ticket} * avg_client_dact_ipc_ticket_rate,
         ${hiveconf:mu_client_any_ticket}) as rider_any_ticket_cred,
       coalesce((1.0 - ${hiveconf:cred_coef_client_rating}) * ${hiveconf:mu_client_rating} +
         ${hiveconf:cred_coef_client_rating} * avg_client_rating,
         ${hiveconf:mu_client_rating}) as rider_rating_cred
from secure_insurance.tmp_ah_all_trips_2016_2017_v8 a
left join clients b
on a.client_uuid = b.client_uuid
left join drivers d
on a.driver_uuid = d.driver_uuid;


---------------------------------------------------------
-- This table contains trip level information
-- with the usage of rider credibility
---------------------------------------------------------

-- todo: client_trip_number
SET rating_default_cond=is_rides_trip = 1 and driver_rating is not null;
SET feedback_default_cond=is_rides_trip = 1;
SET ticket_default_cond=is_rides_trip = 1;

SET ticket_expiration_seconds=coalesce(dd_ticket_seconds_after_trip, 0) <= 604800;

SET ticket_default_timing_cond=${hiveconf:ticket_expiration_seconds} and ${hiveconf:ticket_default_cond};

-- https://workbench.uberinternal.com/explore/knowledge/localfile/abbas.hooshmand/Credibility.ipynb
SET dact_ticket_p99_cond=rider_dact_ticket_cred <= 8.5;
SET any_ticket_p99_cond=rider_any_ticket_cred <= 12.25;
SET feedback_p99_cond=rider_feedback_cred <= 87.0;
SET rating_p99_cond=rider_rating_cred >= 3.91;
-- THe above thresholds comes from the following link (all 99%p, or 1%p i case of rating)
-- https://querybuilder-ea.uberinternal.com/r/qLsXrILhd/run/aX7Dir26j
-- 4% of clients with tickets
-- https://querybuilder-ea-phx2.uberinternal.com/r/zv4SGUxk7

SET driver_window = (partition by a.driver_uuid
                     order by a.beginsession_timestamp_utc asc
                     rows between unbounded PRECEDING and 1 PRECEDING);

drop table if exists secure_insurance.tmp_ah_all_sessions_2016_2017_pre_v8;
create table secure_insurance.tmp_ah_all_sessions_2016_2017_pre_v8
stored as parquet as

with max_clients_cred as (
select client_uuid,
       max(rider_any_ticket_cred) as rider_any_ticket_max_future
from secure_insurance.tmp_ah_all_trips_with_rider_cred_2016_2017_v8
group by 1
)

select a.*,
       -- no filter
       case when ${hiveconf:rating_default_cond} then driver_rating else 0 end as rating_no_filter,
       case when ${hiveconf:rating_default_cond} then 1 else 0 end as n_rating_no_filter,
       case when ${hiveconf:feedback_default_cond} then dd_feedback else 0 end as dd_feedbacks_no_filter,
       case when ${hiveconf:feedback_default_cond} then 1 else 0 end as n_dd_feedbacks_no_filter,
       case when ${hiveconf:ticket_default_cond} then dact_ticket else 0 end as dact_tickets_no_filter,
       case when ${hiveconf:ticket_default_cond} then 1 else 0 end as n_dact_tickets_no_filter,
       -- p99 filter for riders
       case when ${hiveconf:rating_default_cond} and ${hiveconf:rating_p99_cond} then driver_rating
            else 0 end as rating_p99,
       case when ${hiveconf:rating_default_cond} and ${hiveconf:rating_p99_cond} then 1
            else 0 end as n_rating_p99,
       case when ${hiveconf:feedback_default_cond} and ${hiveconf:feedback_p99_cond} then dd_feedback
            else 0 end as dd_feedbacks_p99,
       case when ${hiveconf:feedback_default_cond} and ${hiveconf:feedback_p99_cond} then 1
            else 0 end as n_dd_feedbacks_p99,
       case when (${hiveconf:ticket_default_cond} and (vcc_ticket+law_ticket) > 0)
                 or (${hiveconf:ticket_default_timing_cond} and ${hiveconf:dact_ticket_p99_cond}) then dact_ticket
            else 0 end as dact_tickets_p99_riders_dact_tickets_used,
       case when (${hiveconf:ticket_default_cond} and (vcc_ticket+law_ticket) > 0)
                 or (${hiveconf:ticket_default_timing_cond} and ${hiveconf:dact_ticket_p99_cond}) then 1
            else 0 end as n_dact_tickets_p99_riders_dact_tickets_used,
       case when (${hiveconf:ticket_default_cond} and (vcc_ticket+law_ticket) > 0)
                 or (${hiveconf:ticket_default_timing_cond} and ${hiveconf:any_ticket_p99_cond}) then dact_ticket
            else 0 end as dact_tickets_p99_riders_any_tickets_used,
       case when (${hiveconf:ticket_default_cond} and (vcc_ticket+law_ticket) > 0)
                 or (${hiveconf:ticket_default_timing_cond} and ${hiveconf:any_ticket_p99_cond}) then 1
            else 0 end as n_dact_tickets_p99_riders_any_tickets_used
from secure_insurance.tmp_ah_all_trips_with_rider_cred_2016_2017_v8 a;

---------------------------------------------------------
-- This table has session level information
---------------------------------------------------------

drop table if exists secure_insurance.tmp_ah_all_sessions_2016_2017_v8;
create table secure_insurance.tmp_ah_all_sessions_2016_2017_v8
stored as parquet as

with tmp as (
select session_uuid,
       count(1) as num_trips,
       max(city_id) as city_id,
       max(driver_uuid) as driver_uuid,
       sum(trip_distance_miles) as sum_trip_distance_miles,
       sum(trip_duration_seconds) as sum_trip_duration_seconds,
       max(global_product_name) as global_product_name,
       max(is_rides_trip) as is_rides_trip,
       min(begintrip_timestamp_utc) as begintrip_timestamp_utc,
       -- session level
       max(session_distance_miles) as session_distance_miles,
       max(session_duration_seconds) as session_duration_seconds,
       max(beginsession_timestamp_utc) as beginsession_timestamp_utc,
       min(driver_trip_number) as min_driver_trip_number,
       -- responces
       max(cnt_xcnp_liab_15m) as cnt_xcnp_liab_15m,
       max(liab_loss_dollar_15m) as liab_loss_dollar_15m,
       -- no filter
       sum(rating_no_filter) as sum_rating_no_filter,
       sum(n_rating_no_filter) as sum_n_rating_no_filter,
       sum(dd_feedbacks_no_filter) as sum_dd_feedbacks_no_filter,
       sum(n_dd_feedbacks_no_filter) as sum_n_dd_feedbacks_no_filter,
       sum(dact_tickets_no_filter) as sum_dact_tickets_no_filter,
       sum(n_dact_tickets_no_filter) as sum_n_dact_tickets_no_filter,
       -- p99 filter for riders
       sum(rating_p99) as sum_rating_p99,
       sum(n_rating_p99) as sum_n_rating_p99,
       sum(dd_feedbacks_p99) as sum_dd_feedbacks_p99,
       sum(n_dd_feedbacks_p99) as sum_n_dd_feedbacks_p99,
       sum(dact_tickets_p99_riders_dact_tickets_used) as sum_dact_tickets_p99_riders_dact_tickets_used,
       sum(n_dact_tickets_p99_riders_dact_tickets_used) as sum_n_dact_tickets_p99_riders_dact_tickets_used,
       sum(dact_tickets_p99_riders_any_tickets_used) as sum_dact_tickets_p99_riders_any_tickets_used,
       sum(n_dact_tickets_p99_riders_any_tickets_used) as sum_n_dact_tickets_p99_riders_any_tickets_used
from secure_insurance.tmp_ah_all_sessions_2016_2017_pre_v8
group by 1
)

select a.*,
       -- no filter
       sum(a.sum_rating_no_filter) over ${hiveconf:driver_window} as window_sum_rating_no_filter,
       sum(a.sum_n_rating_no_filter) over ${hiveconf:driver_window} as window_sum_n_rating_no_filter,
       sum(a.sum_dd_feedbacks_no_filter) over ${hiveconf:driver_window} as window_sum_dd_feedbacks_no_filter,
       sum(a.sum_n_dd_feedbacks_no_filter) over ${hiveconf:driver_window} as window_sum_n_dd_feedbacks_no_filter,
       sum(a.sum_dact_tickets_no_filter) over ${hiveconf:driver_window} as window_sum_dact_tickets_no_filter,
       sum(a.sum_n_dact_tickets_no_filter) over ${hiveconf:driver_window} as window_sum_n_dact_tickets_no_filter,
       -- p99
       sum(a.sum_rating_p99) over ${hiveconf:driver_window} as window_sum_rating_p99,
       sum(a.sum_n_rating_p99) over ${hiveconf:driver_window} as window_sum_n_rating_p99,
       sum(a.sum_dd_feedbacks_p99) over ${hiveconf:driver_window} as window_sum_dd_feedbacks_p99,
       sum(a.sum_n_dd_feedbacks_p99) over ${hiveconf:driver_window} as window_sum_n_dd_feedbacks_p99,
       sum(a.sum_dact_tickets_p99_riders_dact_tickets_used) over ${hiveconf:driver_window}
          as window_sum_dact_tickets_p99_riders_dact_tickets_used,
       sum(a.sum_n_dact_tickets_p99_riders_dact_tickets_used) over ${hiveconf:driver_window}
          as window_sum_n_dact_tickets_p99_riders_dact_tickets_used,
       sum(a.sum_dact_tickets_p99_riders_any_tickets_used) over ${hiveconf:driver_window}
          as window_sum_dact_tickets_p99_riders_any_tickets_used,
       sum(a.sum_n_dact_tickets_p99_riders_any_tickets_used) over ${hiveconf:driver_window}
          as window_sum_n_dact_tickets_p99_riders_any_tickets_used
from tmp a;

---------------------------------------------------------
-- This table has session-level information with
-- credibility.
---------------------------------------------------------

-- Credibility Calculations in link below:
-- https://workbench.uberinternal.com/explore/knowledge/localfile/abbas.hooshmand/Credibility.ipynb

-- no filter
SET mu_driver_rating_no_filter=4.817;
SET va_driver_rating_no_filter=27.447;
SET cred_coef_driver_rating_no_filter=window_sum_n_rating_no_filter /
        (window_sum_n_rating_no_filter + ${hiveconf:va_driver_rating_no_filter});

SET mu_driver_feedback_no_filter=3.659;
SET va_driver_feedback_no_filter=110.874;
SET cred_coef_driver_feedbacks_no_filter=window_sum_n_dd_feedbacks_no_filter /
        (window_sum_n_dd_feedbacks_no_filter + ${hiveconf:va_driver_feedback_no_filter});

SET mu_driver_dact_tickets_no_filter=0.485;
SET va_driver_dact_tickets_no_filter=442.342;
SET cred_coef_driver_dact_tickets_no_filter=window_sum_n_dact_tickets_no_filter /
        (window_sum_n_dact_tickets_no_filter + ${hiveconf:va_driver_dact_tickets_no_filter});


-- p99
SET mu_driver_rating_p99=4.828;
SET va_driver_rating_p99=26.957;
SET cred_coef_driver_rating_p99=window_sum_n_rating_p99 /
        (window_sum_n_rating_p99 + ${hiveconf:va_driver_rating_p99});

SET mu_driver_feedback_p99=3.316;
SET va_driver_feedback_p99=109.936;
SET cred_coef_driver_feedbacks_p99=window_sum_n_dd_feedbacks_p99 /
        (window_sum_n_dd_feedbacks_p99 + ${hiveconf:va_driver_feedback_p99});

SET mu_driver_dact_tickets_p99_riders_dact_tickets=0.388;
SET va_driver_dact_tickets_p99_riders_dact_tickets=411.162;
SET cred_coef_driver_dact_tickets_p99_riders_dact_tickets_used=window_sum_n_dact_tickets_p99_riders_dact_tickets_used /
        (window_sum_n_dact_tickets_p99_riders_dact_tickets_used +
        ${hiveconf:va_driver_dact_tickets_p99_riders_dact_tickets});

SET mu_driver_dact_tickets_p99_riders_any_tickets=0.393;
SET va_driver_dact_tickets_p99_riders_any_tickets=410.561;
SET cred_coef_driver_dact_tickets_p99_riders_any_tickets_used=window_sum_n_dact_tickets_p99_riders_any_tickets_used /
        (window_sum_n_dact_tickets_p99_riders_any_tickets_used +
        ${hiveconf:va_driver_dact_tickets_p99_riders_any_tickets});


drop table if exists secure_insurance.tmp_ah_all_sessions_cred_2016_2017_v8;
create table secure_insurance.tmp_ah_all_sessions_cred_2016_2017_v8
stored as parquet as

select a.*,
       -- no filter
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_rating_no_filter}) * ${hiveconf:mu_driver_rating_no_filter} +
         ${hiveconf:cred_coef_driver_rating_no_filter} * (window_sum_rating_no_filter * 1.0 /
          window_sum_n_rating_no_filter), ${hiveconf:mu_driver_rating_no_filter}) as Double)
       as driver_rating_no_filter_cred,
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_feedbacks_no_filter}) *
         ${hiveconf:mu_driver_feedback_no_filter} +
         ${hiveconf:cred_coef_driver_feedbacks_no_filter} * (window_sum_dd_feedbacks_no_filter * 1000.0 /
          window_sum_n_dd_feedbacks_no_filter), ${hiveconf:mu_driver_feedback_no_filter}) as Double)
       as driver_feedback_no_filter_cred,
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_dact_tickets_no_filter}) *
          ${hiveconf:mu_driver_dact_tickets_no_filter} +
         ${hiveconf:cred_coef_driver_dact_tickets_no_filter} * (window_sum_dact_tickets_no_filter * 1000.0 /
          window_sum_n_dact_tickets_no_filter), ${hiveconf:mu_driver_dact_tickets_no_filter}) as Double)
       as driver_dact_ticket_no_filter_cred,
       -- p99
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_rating_p99}) * ${hiveconf:mu_driver_rating_p99} +
         ${hiveconf:cred_coef_driver_rating_p99} * (window_sum_rating_p99 * 1.0 /
          window_sum_n_rating_p99), ${hiveconf:mu_driver_rating_p99}) as Double) as driver_rating_p99_cred,
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_feedbacks_p99}) * ${hiveconf:mu_driver_feedback_p99} +
         ${hiveconf:cred_coef_driver_feedbacks_p99} * (window_sum_dd_feedbacks_p99 * 1000.0 /
          window_sum_n_dd_feedbacks_p99), ${hiveconf:mu_driver_feedback_p99}) as Double) as driver_feedback_p99_cred,
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_dact_tickets_p99_riders_dact_tickets_used}) *
         ${hiveconf:mu_driver_dact_tickets_p99_riders_dact_tickets} +
         ${hiveconf:cred_coef_driver_dact_tickets_p99_riders_dact_tickets_used} *
         (window_sum_dact_tickets_p99_riders_dact_tickets_used * 1000.0 /
          window_sum_n_dact_tickets_p99_riders_dact_tickets_used),
          ${hiveconf:mu_driver_dact_tickets_p99_riders_dact_tickets}) as Double)
       as driver_dact_ticket_p99_cred_riders_dact_tickets_used,
       CAST(coalesce((1.0 - ${hiveconf:cred_coef_driver_dact_tickets_p99_riders_any_tickets_used}) *
         ${hiveconf:mu_driver_dact_tickets_p99_riders_any_tickets} +
         ${hiveconf:cred_coef_driver_dact_tickets_p99_riders_any_tickets_used} *
         (window_sum_dact_tickets_p99_riders_any_tickets_used * 1000.0 /
          window_sum_n_dact_tickets_p99_riders_any_tickets_used),
          ${hiveconf:mu_driver_dact_tickets_p99_riders_any_tickets}) as Double)
       as driver_dact_ticket_p99_cred_riders_any_tickets_used
from secure_insurance.tmp_ah_all_sessions_2016_2017_v8 a;
