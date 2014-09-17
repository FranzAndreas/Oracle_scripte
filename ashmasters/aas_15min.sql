select mtime, round(sum(c1),2) AAS_WAIT, round(sum(c2),2) AAS_CPU, round(sum(cnt),2) AAS  from (
 select to_char(sample_time,'YYYY-MM-DD HH24') mtime, decode(session_state,'WAITING',count(*),0)/360 c1, decode(session_state,'ON CPU',count(*),0)/360 c2, count(*)/360 cnt 
 from dba_hist_active_sess_history
 group by  to_char(sample_time,'YYYY-MM-DD HH24'), session_state
 )
 group by mtime
 order by mtime;
