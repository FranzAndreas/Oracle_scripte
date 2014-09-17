COL evh_event HEAD WAIT_EVENT for A50 TRUNCATE
COL evh_graph HEAD "Awesome|Graphic" JUST CENTER FOR A12
COL pct_evt_time HEAD "% Event|Time"
COL evh_est_total_ms HEAD "Estimated|Total ms"
COL evh_millisec HEAD "Wait time|bucket ms+"
COL evh_event HEAD "Wait Event"
COL evh_sample_count HEAD "Num ASH|Samples"

BREAK ON evh_event SKIP 1

SELECT 
    event evh_event
  , TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) evh_millisec
  , COUNT(*)  evh_sample_count
  , TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) * COUNT(*) evh_est_total_ms
  , ROUND ( 100 * RATIO_TO_REPORT( TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) * COUNT(*) ) OVER (PARTITION BY event) , 1 ) pct_evt_time
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT( TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) * COUNT(*) ) OVER (PARTITION BY event)), '#'),' '), 10)||'|' evh_graph
FROM 
    V$ACTIVE_SESSION_HISTORY 
WHERE 
    regexp_like(event, '&1') 
AND time_waited > 0 
GROUP BY 
    event
  , TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) -- millisec
ORDER BY 1, 2
/

