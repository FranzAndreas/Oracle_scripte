
select begin_interval_time, sql_id, event, cnt from (
select begin_interval_time, sql_id, event, cnt, rank() over (partition by begin_interval_time order by total_sql desc) r, total_sql from (
select begin_interval_time, sql_id, decode(session_state,'WAITING',event,'ON CPU') event, count(*) cnt, sum(count(*)) over (partition by begin_interval_time,sql_id) total_sql
from dba_hist_active_sess_history ash, dba_hist_snapshot d 
where --program = 'xxxxxxxxx' and event = 'db file sequential read'
ash.snap_id = d.snap_id and sql_id is not null
group by begin_interval_time, sql_id, decode(session_state,'WAITING',event,'ON CPU')
having count(*) > 1
order by begin_interval_time, cnt desc
) ) where r < 10
order by begin_interval_time, r, cnt desc;
