--
-- Copyright (c) 1988, 2004, Oracle Corporation.  All Rights Reserved.
--
-- NAME
--   glogin.sql
--
-- DESCRIPTION
--   SQL*Plus global login "site profile" file
--
--   Add any SQL*Plus commands here that are to be executed when a
--   user starts SQL*Plus, or uses the SQL*Plus CONNECT command
--
-- USAGE
--   This script is automatically run
--

-- Used by Trusted Oracle
COLUMN ROWLABEL FORMAT A15

-- Used for the SHOW ERRORS command
COLUMN LINE/COL FORMAT A8
COLUMN ERROR    FORMAT A65  WORD_WRAPPED

-- Used for the SHOW SGA command
COLUMN name_col_plus_show_sga FORMAT a24
COLUMN units_col_plus_show_sga FORMAT a15
-- Defaults for SHOW PARAMETERS
COLUMN name_col_plus_show_param FORMAT a36 HEADING NAME
COLUMN value_col_plus_show_param FORMAT a30 HEADING VALUE

-- Defaults for SHOW RECYCLEBIN
COLUMN origname_plus_show_recyc   FORMAT a16 HEADING 'ORIGINAL NAME'
COLUMN objectname_plus_show_recyc FORMAT a30 HEADING 'RECYCLEBIN NAME'
COLUMN objtype_plus_show_recyc    FORMAT a12 HEADING 'OBJECT TYPE'
COLUMN droptime_plus_show_recyc   FORMAT a19 HEADING 'DROP TIME'

-- Defaults for SET AUTOTRACE EXPLAIN report
-- These column definitions are only used when SQL*Plus
-- is connected to Oracle 9.2 or earlier.
COLUMN id_plus_exp FORMAT 990 HEADING i
COLUMN parent_id_plus_exp FORMAT 990 HEADING p
COLUMN plan_plus_exp FORMAT a60
COLUMN object_node_plus_exp FORMAT a8
COLUMN other_tag_plus_exp FORMAT a29
COLUMN other_plus_exp FORMAT a44

-- Default for XQUERY
COLUMN result_plus_xquery HEADING 'Result Sequence'

set termout off

col dbname new_value prompt_dbname
select substr(global_name,1,instr(global_name,'.')-1) dbname
from global_name;
set sqlprompt "_USER'@'&&prompt_dbname> " 

-- set title of CMD
col mysid new_value mysid
alter session set NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI:SS';

set serveroutput on
set verify off
set linesize 400                                                           
set pagesize 1115
set tab off

#DEFINE _EDITOR = vim
col STANDBY_DEST format a12
col ARCHIVED    format a8
col FAL         format a3


REM ********************
REM   v$logfile
REM ********************
REM GROUP#                           NUMBER
REM STATUS                           VARCHAR2(7)
REM TYPE                             VARCHAR2(7)
REM MEMBER                           VARCHAR2(513)
col IS_RECOVERY_DEST_FILE format a21


REM **********************
REM   V$ARCHIVE_DEST
REM **********************
col DEST_NAME    format a19 
col STATUS   format a9  
col TARGET   format a7 
col DESTINATION format a20  
col TRANSMIT_MODE  format a13 
col AFFIRM         format a6  
col DB_UNIQUE_NAME  format a14


REM **********************
REM   V$DATABASE
REM **********************
col DBID                         format     NUMBER
col NAME                         format a9
col RESETLOGS_CHANGE#            format     NUMBER
col RESETLOGS_TIME               format     DATE
col PROTECTION_MODE              format a20
col PROTECTION_LEVEL             format a20
col REMOTE_ARCHIVE               format a14
col DATABASE_ROLE                format a16
col ARCHIVELOG_CHANGE#           format     NUMBER
col GUARD_STATUS                 format a12
col FORCE_LOGGING                format a13

REM **********************
REM DBA_COMMON_AUDIT_TRAIL
REM **********************
col AUDIT_TYPE format a18
col DB_USER    format a7
col USERHOST   format a32
col OBJECT_SCHEMA format a13
col OBJECT_NAME   format a11
col SQL_TEXT      format a30

REM **************
REM all_sequences
REM **************
col SEQUENCE_OWNER format a14
col SEQUENCE_NAME  format a25
col CYCLE_FLAG     format a10
col ORDER_FLAG     format a10

REM *****************
REM v$parameter
REM ***************** 
col name             format a36
col value            format a30
col isdefault        format a9
col isses_modifiable format a16
col issys_modifiable format a16

REM *****************
REM v$sql
REM *****************
col sql_text format a100

REM *****************
REM v$session
REM *****************
col machine format a22

REM *****************
REM user_tables
REM *****************
col table_name format a30

REM *****************
REM Dictionary
REM *****************
col comments  format a120

REM **************************
REM     Tabelle employees
REM **************************
col first_name   format a11
col last_name    format a11
col email        format a8
col phone_number format a18
col hire_date    format a15

COL owner            format a8
COL search_condition format a30
COL column_name      format a15
COL constraint_name  format a20
COL data_default     format a13
COL text             format a55
COL view_name        format a20
COL index_name       format a22
COL object_name      format a22
COL object_type      format a22
COL trigger_name     format a10
COL table_owner      format a11
COL triggering_event format a10
COL trigger_type     format a16
COL grantee          format a10
COL grantor          format a10
COL role             format a25
COL username         format a20
col kommentar        format a20
-- col name             format a66
col large_pool_size  format a15
col file_name        format a66
col tablespace_name  format a15
col segment_name     format a30
col member           format a60
col description      format a35
col trigger_body     format a35
col parameter        format a35
col data_default     format a20
col resource_name    format a30
col limit            format a20
col profile          format a20
col attribute        format a15
col char_value       format a15
col member           format a50
col host_name        format a20
col "%"              format 990.99 justify right
col AVERAGE_WAIT     format 9999990.00
col account_status       format a10
col default_tablespace   format a20
col temporary_tablespace format a20
col password         format a17
col modus            format a5
col operation        format a30
col options          format a15
col index_free_percentage format 90.99

col os_username      format a20
col terminal         format a20
col obj_name         format a20
col action_time      format a20
col action_name      format a20

col event            format a30
col p1text           format a20
col sid              format 999
col what             format a30

col department_name  format a20
col property_value   format a30
col property_name    format a30
col statistics_name  format a30
col activation_level format a20
col optimizer        format a10
col program          format a30
col instance_name    format a20
col status           format a20
col type             format a20
col namespace        format a20
col osuser           format a20 
col logon_time       format a20
col deferrable       format a15
col deferred         format a15
col r_owner          format a15
col tablespace       format a20
col datafile         format a50
set termout on

