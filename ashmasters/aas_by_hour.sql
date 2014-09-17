select mtime, to_char(sum(c1)/min(delta_time),'9999.99') AAS_WAIT, to_char(sum(c2)/min(delta_time),'9999.99') AAS_CPU, to_char(sum(cnt)/min(delta_time),'9999.99') AAS, min(delta_time*10) Sample_DTime  from (
  select min(begin_interval_time) mtime, decode(session_state,'WAITING',count(*),0) c1, decode(session_state,'ON CPU',count(*),0) c2, count(*) cnt, (trunc(sysdate) + (max(sample_time)-min(sample_time)) - trunc(sysdate) )* 24 * 360 delta_time
   from dba_hist_active_sess_history ash, dba_hist_snapshot s where s.snap_id = ash.snap_id and BEGIN_INTERVAL_TIME > sysdate - &days_before and to_char(BEGIN_INTERVAL_TIME,'HH24:MI') in ('&trunchhmm')
   group by s.snap_id, session_state
    )
    group by mtime
   order by mtime
/
