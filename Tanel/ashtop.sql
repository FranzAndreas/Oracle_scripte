COL ash_from_date NEW_VALUE ash_from_date
COL ash_to_date   NEW_VALUE ash_to_date

SELECT 
    regexp_replace('&3','^-([0-9]*)(.)$', ' sysdate - \1 / ', 1, 0, 'i')
        ||decode(regexp_replace('&3', '^-[0-9]*(.)$', '\1', 1, 0, 'i'),
            'd', '1', 
            'h', '24', 
            'm','24/60',
            's','24/60/60', 
            ''
          ) ash_from_date, 
    regexp_replace(regexp_replace('&4', '^now$', 'sysdate'),'^-([0-9]*)(.)$', ' sysdate - \1 / ', 1, 0, 'i')
        ||decode(regexp_replace(regexp_replace('&4', '^now$', 'sysdate'), '^-[0-9]*(.)$', '\1', 1, 0, 'i'),
            'd', '1', 
            'h', '24', 
            'm','24/60',
            's','24/60/60', 
            ''
          ) ash_to_date 
from 
    dual
/


SELECT
    &1
  , COUNT(*)                                                     "Tot_Samples"
  , SUM(CASE WHEN wait_class IS NULL          THEN 1 ELSE 0 END) "CPU"
  , SUM(CASE WHEN wait_class ='Application'   THEN 1 ELSE 0 END) "Application"
  , SUM(CASE WHEN wait_class ='Configuration' THEN 1 ELSE 0 END) "Configuration"
  , SUM(CASE WHEN wait_class ='Concurrency'   THEN 1 ELSE 0 END) "Concurrency"
  , SUM(CASE WHEN wait_class ='Commit'        THEN 1 ELSE 0 END) "Commit"
  , SUM(CASE WHEN wait_class ='Idle'          THEN 1 ELSE 0 END) "Idle"
  , SUM(CASE WHEN wait_class ='Network'       THEN 1 ELSE 0 END) "Network"
  , SUM(CASE WHEN wait_class ='User I/O'      THEN 1 ELSE 0 END) "User I/O"
  , SUM(CASE WHEN wait_class ='System I/O'    THEN 1 ELSE 0 END) "System I/O"
  , SUM(CASE WHEN wait_class ='Cluster'       THEN 1 ELSE 0 END) "Cluster"
  , SUM(CASE WHEN wait_class ='Other'         THEN 1 ELSE 0 END) "Other"
FROM
    v$active_session_history
WHERE
    &2
AND sample_time BETWEEN &ash_from_date AND &ash_to_date
GROUP BY
    &1
ORDER BY
    "Tot_Samples" DESC
   , &1
/
