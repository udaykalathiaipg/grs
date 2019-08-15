SELECT sys_agency_code, sys_client_code, sys_campaign_id, sys_placement_id, sys_creative_id, unity_client_id, entity_id, entity_type, attribute_name, attribute_value, attribute_isvalid, process_timestamp, "time"
FROM gr2_core_initiative.symphony_attributes;



select s.sys_agency_code, s.sys_client_code, s.sys_placement_id, s.attribute_name, s.attribute_value, d.placement_name
from gr2_core_initiative.symphony_attributes s
join gr2_core_initiative.dcm_dim_placements d on s.sys_placement_id = d.sys_placement_id
where entity_type = 'placement'
;


select attribute_name, count(*)
from gr2_core_initiative.symphony_attributes
where entity_type = 'placement'
group by attribute_name
order by count(*) desc
;

create or replace view gr2_custom_initiative.dim_dcm_placement_taxonomy as 
with taxonomy as
(
select s.sys_agency_code, s.sys_client_code, s.sys_placement_id
,trim(max(case when attribute_name = 'Delivery Location' then s.attribute_value end)) as delivery_location
,trim(max(case when attribute_name in ('Objective','Media Objective') then s.attribute_value end)) as objective
,trim(max(case when attribute_name in ('Package or Placement','Placement/Package') then s.attribute_value end)) as package_or_placement
,trim(max(case when attribute_name = 'Placement Serving Type' then s.attribute_value end)) as serving_type
,trim(max(case when attribute_name = 'Ad Environment' then s.attribute_value end)) as ad_environment
,trim(max(case when attribute_name = 'Tactic / Targeting Type' then s.attribute_value end)) as tactic_targeting_type
,trim(max(case when attribute_name in ('Ad Size','Creative Size / Video Length') then s.attribute_value end)) as ad_size
,trim(max(case when attribute_name = 'Prisma ID' then s.attribute_value end)) as prisma_id
,trim(max(case when attribute_name in ('Unit Type','Creative Format') then s.attribute_value end)) as unit_type
,trim(max(case when attribute_name in ('Video Skippable / Non-Skippable','Video Skip/NonSkip') then s.attribute_value end)) as video_skippable
,trim(max(case when attribute_name = 'Free Form Field' then s.attribute_value end)) as free_form
,trim(max(case when attribute_name = 'Creative Identifier' then s.attribute_value end)) as creative_identifier
,trim(max(case when attribute_name = 'Video Length' then s.attribute_value end)) as video_length
,trim(max(case when attribute_name = 'Messaging Type' then s.attribute_value end)) as messaging_type
,trim(max(case when attribute_name = 'Year' then s.attribute_value end)) as placement_year
,trim(max(case when attribute_name = 'Product' then s.attribute_value end)) as product
,trim(max(case when attribute_name in ('Buy/Rate Type','Rate Type','Buy Type') then s.attribute_value end)) as buy_rate_type
,trim(max(case when attribute_name = 'Market' then s.attribute_value end)) as market
,trim(max(case when attribute_name = 'Format' then s.attribute_value end)) as placement_format
,trim(max(case when attribute_name in ('Device', 'Device Type') then s.attribute_value end)) as device_type
,trim(max(case when attribute_name = 'Segment / Audience' then s.attribute_value end)) as segment_audience
,trim(max(case when attribute_name in ('Site Name', 'Site') then s.attribute_value end)) as site_name
,trim(max(case when attribute_name = 'Site / Publisher Type' then s.attribute_value end)) as site_publisher_type
,trim(max(case when attribute_name = 'Demo' then s.attribute_value end)) as demo
,trim(max(case when attribute_name = 'Country' then s.attribute_value end)) as country
,trim(max(case when attribute_name = 'Language' then s.attribute_value end)) as language_placement
,trim(max(case when attribute_name = 'Video/Audio Type' then s.attribute_value end)) as av_type
,trim(max(case when attribute_name = 'Data Partner' then s.attribute_value end)) as data_partner
,trim(max(case when attribute_name = 'Merck Brand' then s.attribute_value end)) as merck_brand
,trim(max(case when attribute_name = 'User Targeting' then s.attribute_value end)) as user_targeting
,trim(max(case when attribute_name = 'Campaign Identifier' then s.attribute_value end)) as campaign_identifier
from gr2_core_initiative.symphony_attributes s
join gr2_core_initiative.dcm_dim_placements d on s.sys_placement_id = d.sys_placement_id and s.sys_client_code = d.sys_client_code
where entity_type = 'placement'
group by s.sys_agency_code, s.sys_client_code, s.sys_placement_id
)
SELECT sys_agency_code
, sys_client_code
, sys_placement_id
, delivery_location
, objective
, package_or_placement
, serving_type
, ad_environment
, tactic_targeting_type
, ad_size
, prisma_id
, unit_type
, video_skippable
, free_form
, creative_identifier
, video_length
, messaging_type
, placement_year
, product
, case when buy_rate_type = 'Dynamic CPM' then 'dCPM'
	   when buy_rate_type in ('Cost Per Mile','Cost Per Thousand Impression (CPM)','Cost Per Thousand Views') then 'CPM'
	   when buy_rate_type in ( 'cpv', 'Cost Per Video View') then 'CPV'
	   when buy_rate_type = 'cpv' then 'CPV'
	   when buy_rate_type = 'av' then 'AV'
	   when buy_rate_type in ('cpcv','Cost Per Completed View') then 'CPCV'
	   when buy_rate_type = 'Cost Per Click (CPC)' then 'CPC'
	   when buy_rate_type = 'Cost Per Viewable Impressions' then 'CPvM'
	   when buy_rate_type = 'Cost Per Engagement' then 'CPE'
	   else buy_rate_type
 end as buy_rate_type
, market
, placement_format
, device_type
, segment_audience
, site_name
, site_publisher_type
, demo
, country
, language_placement
, av_type
, data_partner
, merck_brand
, user_targeting
, campaign_identifier
FROM taxonomy; 

--check for dups
select sys_client_code, sys_placement_id, count(*)
from gr2_custom_initiative.dim_dcm_placement_taxonomy
group by sys_client_code, sys_placement_id
having count(*) > 1
;

select * from gr2_custom_initiative.dim_dcm_placement_taxonomy;

--8,320
select count(*) from gr2_custom_initiative.dim_dcm_placement_taxonomy;

--8,320
select count(*) from (select distinct d.sys_client_code, d.sys_placement_id 
						from gr2_core_initiative.symphony_attributes s
						join gr2_core_initiative.dcm_dim_placements d on s.sys_placement_id = d.sys_placement_id and s.sys_client_code = d.sys_client_code
						where entity_type = 'placement');



select sys_client_code, sys_placement_id
from gr2_core_initiative.symphony_attributes
except
select sys_client_code, sys_placement_id
from gr2_core_initiative.dcm_dim_placements


select *
from gr2_core_initiative.ias_dim_placements
where sys_placement_id = 'IAS_946b87784bf9a60dd80ad6f95961ffcbe7b26ff7'
