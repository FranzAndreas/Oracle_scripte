SET ECHO off
REM NAME:   TFSDBSPA.SQL
REM USAGE:"@path/tfsdbspa"
REM ------------------------------------------------------------------------
REM REQUIREMENTS:
REM    SELECT on SYS.TS$, SYS.USER$, SYS.SEG$
REM ------------------------------------------------------------------------
REM AUTHOR:
REM    G. Godart-Brown
REM    Copyright 1991, Oracle Corporation
REM ------------------------------------------------------------------------
REM PURPOSE:
REM    Report how much space each user is consuming in the database.
REM ------------------------------------------------------------------------
REM DISCLAIMER:
REM    This script is provided for educational purposes only. It is NOT
REM    supported by Oracle World Wide Technical Support.
REM    The script has been tested and appears to work as intended.
REM    You should always run new scripts on a test instance initially.
REM ------------------------------------------------------------------------
REM Main text of script follows:

SET ECHO OFF
set newpage 0
ttitle center 'Database Usage by user and Tablespace'-
right 'Page:' format 999 sql.pno skip skip
break on owner skip 2
col K format 999,999,999 heading 'Size K'
col ow format a24 heading 'Owner'
col ta format a30 heading 'Tablespace'
spool tfsdbspa.lst
set feedback off
set feedback 6
  SELECT us.name ow,
         ts.name ta,
         round(SUM (seg.blocks * ts.blocksize) /1073741824, 2) GB
    FROM sys.ts$ ts, sys.user$ us, sys.seg$ seg
   WHERE seg.user# = us.user# AND ts.ts# = seg.ts#
   AND us.name not in ('SYS','SYSTEM','PERFSTAT','DBSNMP','XDB')
   GROUP BY ROLLUP(us.name, ts.name);
/
prompt End of Report
spool off
ttitle off
clear breaks
clear columns
clear computes
set verify on