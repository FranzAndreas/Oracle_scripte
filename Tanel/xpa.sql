prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SID &3.... (11.2+)
set termout off

spool &SQLPATH/tmp/xprof_&_i_inst..html

@@xprof ALL ACTIVE SESSION_ID &1

spool off

host &_start &SQLPATH/tmp/xprof_&_i_inst..html
set termout on
