SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF

DEF from_time="2010-11-03 14:16:00"
DEF to_time="2010-11-03 14:30:00"
DEF cols=session_state,event

PROMPT FROM_TIME=&from_time TO_TIME=&to_time

SELECT * FROM (
  SELECT
        &cols
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
    FROM
        -- active_session_history_bak
        v$active_session_history
        -- dba_hist_active_sess_history
    WHERE
        sample_time BETWEEN TIMESTAMP'&from_time' AND TIMESTAMP'&to_time'
    GROUP BY
        &cols
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

DEF cols=session_state,event,p1,p2
/

DEF cols=session_state,event,sql_id
/

