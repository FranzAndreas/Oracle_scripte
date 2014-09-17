prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID &1.... (11.2+)
set termout off

spool &SQLPATH/tmp/xprof_&_i_inst..html

@@xprof ALL HTML SQL_ID "'&1'"

spool off

host &_start &SQLPATH/tmp/xprof_&_i_inst..html
set termout on
