COL px_qcsid HEAD QC_SID FOR A13

SELECT 
    pxs.qcsid||','||pxs.qcserial# px_qcsid
  , ses.username
  , ses.sql_id
  , pxs.degree
  , pxs.req_degree
  , count(*) slaves
FROM 
    gv$px_session pxs
  , gv$session    ses
  , gv$px_process p
WHERE
    ses.sid     = pxs.sid
AND ses.serial# = pxs.serial#
AND p.sid     = pxs.sid
AND pxs.inst_id = ses.inst_id
AND ses.inst_id = p.inst_id
--
AND pxs.req_degree IS NOT NULL -- qc
GROUP BY
    pxs.qcsid||','||pxs.qcserial#
  , ses.username
  , ses.sql_id
  , pxs.qcserial#
  , pxs.degree
  , pxs.req_degree
/
