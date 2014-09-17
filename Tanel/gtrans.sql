prompt Show global transactions from X$K2GTE2...


select
    gt.k2gtitid_ora
  , s.username
  , s.sid||','||s.serial# sid_serial
  , s.machine
  , s.process remote_spid
from
     x$k2gte2 gt
   , v$session s
where
    gt.k2gtdses = s.saddr
/

