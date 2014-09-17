-- xplan.sql
-- William Robertson - www.williamrobertson.net
-- Transparent "Explain Plan" utility for SQL*Plus.
--
-- Usage:
-- @xplan
-- Reports the execution plan of the current SQL buffer (i.e. the most recent SQL
-- statement to be run, edited, fetched etc (not necessarily run), and then places it
-- back in the buffer, as far as possible leaving everything the way it was.
--
-- Notes:
-- 2004/02/29: Changed to use DBMS_XPLAN.
-- 2007/03/08: Uses SYS.PLAN_TABLE$ if available (sometimes an old plan_table is still present)
-- 2007/03/15: Derives OS-specific OS commands by checking SQL*Plus executable extension in v$session.
-- 2008/01/31: Refined OS checks so don't need access to v$ tables;
--             Also now specify ".lst" extension for SPOOL commands as Windows defaults to uppercase .LST and DEL is case-sensitive.
-- 2008/02/12  Accepts optional "format" parameter for DBMS_SQL.DISPLAY_CURSOR(), e.g. @xplan all

set term off
store set sqlplus_settings.sql replace

ttitle off
set pause off
set feed off
set verify off
set timing off
set pages 999
set trimout on
set trimspool on
set long 2000
set autotrace off
set lines 150
set flagger off
set tab off
set serverout on size 10000

col QUERY_PATH format a70 hea "Query Path"
col STATEMENT_ID new_value STATEMENT_ID
col 1 new_value 1
col FORMAT_OPTIONS new_value FORMAT_OPTIONS
col PLAN_TABLE new_value PLAN_TABLE
col DELETE_COMMAND new_value DELETE_COMMAND
col LIST_COMMAND new_value LIST_COMMAND
col OPTIMIZER format a9
col BINDS_ARG new_value BINDS_ARG
def binds_arg = ''

break on report
comp sum label '' of cost on report

0 EXPLAIN PLAN SET STATEMENT_ID = '&STATEMENT_ID' INTO &PLAN_TABLE FOR

save xplan.buf repl

-- "_O_VERSION" is predefined in SQL*Plus from around 10.1 and gives more information than v$version etc
-- But just in case this is an old version of SQL*Plus, initialise it to null if it is undefined:
col dbversion new_value _o_version
SELECT '' AS dbversion FROM dual WHERE 1=2;

-- Now give _o_version a value from v$version if it's empty (i.e. if we created it empty above):
SELECT banner AS dbversion FROM v$version WHERE '&_O_VERSION' IS NULL AND banner LIKE 'Oracle Database %';

-- Define "binds_arg" variable to contain @+peeked_binds" only if database is at 10.2 or above:
-- (commenting this out on second thoughts as SQL*Plus doesn't do bind peeking, curse it)
-- SELECT '+peeked_binds' AS binds_arg
-- FROM   v$version
-- WHERE banner LIKE 'Oracle Database %' AND SUBSTR(banner,INSTR(banner,'Release') +8) >= '10.2';

SAVEPOINT xplan;

-- Dynamically set &PLAN_TABLE variable depending on whether SYS.PLAN_TABLE$ exists(new in 10g):
SELECT 1 AS seq, 'plan_table' AS plan_table FROM dual
UNION ALL
SELECT 2, LOWER(owner || '.' || table_name)
FROM   all_tables
WHERE  owner = 'SYS'
AND    table_name = 'PLAN_TABLE$'
ORDER BY seq;

-- Temp hack to allow DBA to rebuild plan table:
-- def plan_table = 'plan_table$'

-- Initialise "&1" in case no options were specified (&1 => "format" option of DBMS_XPLAN.DISPLAY_CURSOR):
SELECT dummy AS "1" FROM dual WHERE 1 = 2;

-- Generate unique statement_id for plan:
SELECT USER||TO_CHAR(SYSDATE,'ddmmyyhh24miss') statement_id
     , DECODE(TRIM('&1 &binds_arg'), NULL,NULL, ', ''' || RTRIM('&1 &binds_arg') || '''') AS format_options
FROM   dual;

-- Define OS commands for showing and deleting files:
def list_command = TYPE
def delete_command = DEL

SELECT 'cat' AS list_command
     , 'rm'  AS delete_command
FROM   dual
WHERE  SYS_CONTEXT('userenv','TERMINAL') LIKE 'pts/%';

SELECT 'TYPE' AS list_command
     , 'DEL'  AS delete_command
FROM   dual
WHERE  SYS_CONTEXT('userenv','HOST') LIKE '%\%';

-- The definitive test - check current client executable in v$session, if user has privileges to query it:
SELECT DECODE(os,'MSWIN','TYPE','cat') AS list_command
     , DECODE(os,'MSWIN','DEL','rm')   AS delete_command
FROM   ( SELECT CASE WHEN UPPER(program) LIKE '%.EXE' THEN 'MSWIN' ELSE 'UNIX' END AS os
         FROM   v$session
         WHERE  audsid = SYS_CONTEXT('userenv','sessionid') );

-- We could also:
-- *  create a file (using SPOOL) containing DEFINE statements for Windows
-- *  attempt to delete it with rm
-- *  run it
-- *  delete it using DEL
-- however OS errors tend to appear on the screen, and file creation approach is inherently messy.

-- Possibly excessively cautious in 10g with SYS.PLAN_TABLE$ as GTT:
DELETE &PLAN_TABLE WHERE statement_id = '&STATEMENT_ID';

get xplan.buf nolist

spool xplan_errors.lst
@xplan.buf
spool off

set term on

spool xplan.lst

PROMPT &_o_version

DECLARE
    dbversion varchar2(20);
    dbcompatibility varchar2(20);
BEGIN
    dbms_utility.db_version(dbversion, dbcompatibility);
    -- dbms_output.put_line('Oracle database version ' || dbversion);
    IF dbcompatibility <> dbversion THEN
        dbms_output.put_line('Compatibility is set to ' || dbcompatibility);
    END IF;
END;
/
   
set hea off

-- Oracle 9.2 onwards:
SELECT * FROM TABLE(xplan.DISPLAY('&PLAN_TABLE','&STATEMENT_ID' &format_options));

set doc off
/* Earlier Oracle versions:
SELECT SUBSTR(LPAD(' ',2*LEVEL),3)
    || operation
    || DECODE(options, NULL, NULL, ' '||options)
    || DECODE(object_name, NULL, NULL, ' '||object_name)
    || DECODE(object_type,
              NULL, NULL,
              'UNIQUE', DECODE(options,
                               'UNIQUE SCAN', NULL,
                                              ' ' || object_type),
                        ' ' || object_type)  QUERY_PATH
     , cost
FROM   plan_table
WHERE  statement_id = :statement_id
CONNECT BY PRIOR id = parent_id AND statement_id = :statement_id
START WITH parent_id IS NULL AND statement_id = :statement_id
*/

host &LIST_COMMAND xplan_errors.lst
host &DELETE_COMMAND xplan_errors.lst

spool off

set term off

set feed on hea on 
ROLLBACK TO xplan;

get xplan.buf nolist 
l1 
del 

clear breaks
undef STATEMENT_ID 
-- undef format_options
undef 1
@sqlplus_settings.sql
ho &DELETE_COMMAND sqlplus_settings.sql
ho &DELETE_COMMAND xplan.lst