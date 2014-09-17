select * from (
select sql_id, round(w*100,2) pct,
nvl("'ON CPU'",0) "CPU",
nvl("'Scheduler'",0) Scheduler ,
nvl("'User I/O'",0) "User I/O" ,
nvl("'System I/O'",0) "System I/O" ,
nvl("'Concurrency'",0) Concurrency ,
nvl("'Application'",0) Application ,
nvl("'Commit'",0) Commit,
nvl("'Configuration'",0) Configuration,
nvl("'Administrative'",0) Administrative ,
nvl("'Network'",0) Network ,
nvl("'Queueing'",0) Queueing ,
nvl("'Cluster'",0) "Cluster",
nvl("'Other'",0) Other
from (
 select sql_id,
 decode(session_state,'WAITING',wait_class,'ON CPU') wait_class,
 sum(count(*)) over (partition by sql_id) / sum(count(*)) over () w,
 count(*) cnt,
 sum(count(*)) over () totalsum
 from v$active_session_history
 where sample_time > sysdate - &NUM_MIN/24/60 
 group by sql_id,
          decode(session_state,'WAITING',wait_class,'ON CPU')
 order by sql_id
)
pivot (
   sum(round(cnt/totalsum*100,2))
   for (wait_class) in
   ('Administrative','Application','Cluster','Commit','Concurrency',
    'Configuration','Network','Other','Queueing','Scheduler','System I/O',
    'User I/O','ON CPU'
   )
) where sql_id is not null order by 2 desc
) where rownum < 10;
