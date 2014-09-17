select begin_interval_time, 
ms1 - lag(ms1) over (order by begin_interval_time) ms1,
ms2 - lag(ms2) over (order by begin_interval_time) ms2,
ms4 - lag(ms4) over (order by begin_interval_time) ms4,
ms8 - lag(ms8) over (order by begin_interval_time) ms8,
ms16 - lag(ms16) over (order by begin_interval_time) ms16,
ms32 - lag(ms32) over (order by begin_interval_time) ms32,
ms64 - lag(ms64) over (order by begin_interval_time) ms64,
ms128 - lag(ms128) over (order by begin_interval_time) ms128,
ms256 - lag(ms256) over (order by begin_interval_time) ms256,
ms512 - lag(ms512) over (order by begin_interval_time) ms512,
ms1024 - lag(ms1024) over (order by begin_interval_time) ms1024,
ms2048 - lag(ms2048) over (order by begin_interval_time) ms2048
from (
select begin_interval_time, 
max(ms1) ms1, 
max(ms2) ms2, 
max(ms4) ms4, 
max(ms8) ms8, 
max(ms16) ms16, 
max(ms32) ms32, 
max(ms64) ms64, 
max(ms128) ms128, 
max(ms256) ms256, 
max(ms512) ms512, 
max(ms1024) ms1024, 
max(ms2048) ms2048
from ( 
select s.begin_interval_time,
decode (a.wait_time_milli,1,wait_count,0) ms1,
decode (a.wait_time_milli,2,wait_count,0) ms2,
decode (a.wait_time_milli,4,wait_count,0) ms4,
decode (a.wait_time_milli,8,wait_count,0) ms8,
decode (a.wait_time_milli,16,wait_count,0) ms16,
decode (a.wait_time_milli,32,wait_count,0) ms32,
decode (a.wait_time_milli,64,wait_count,0) ms64,
decode (a.wait_time_milli,128,wait_count,0) ms128,
decode (a.wait_time_milli,256,wait_count,0) ms256,
decode (a.wait_time_milli,512,wait_count,0) ms512,
decode (a.wait_time_milli,1024,wait_count,0) ms1024,
decode (a.wait_time_milli,2048,wait_count,0) ms2048
from DBA_HIST_EVENT_HISTOGRAM a, dba_hist_snapshot s
where a.snap_id = s.snap_id and a.event_name like '%&event_name%'
)
group by begin_interval_time
order by begin_interval_time
)