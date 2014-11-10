SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

set termout on
accept psqlid prompt 'Enter the sql_id: '

define p_sql_id = '&psqlid'

SPOOL D:\work\scripte\oracle\sql_monitor_reports\report_sql_monitor.htm

SELECT DBMS_SQLTUNE.report_sql_monitor(
  sql_id       => '&p_sql_id',
  type         => 'HTML') AS report
FROM dual;


SPOOL OFF


