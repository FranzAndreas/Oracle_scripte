--------------------------------------------------------------------------------
--
-- File name:   xmsh (eXplain from Memory with Statistics lookup by Hash value)
--
-- Purpose:     Explain a SQL statements execution plan with execution 
--              profile directly from library cache
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       1) alter session set statistics_level = all;
--              2) Run the statement you want to explain
--              3) @xmsh <hash_value> <child#>
--          
-- Other:       You can add a GATHER_PLAN_STATISTICS hint to the statement instead 
--              if you dont want to use "alter session set statistics_level" 
--              for some reason (this hint works on Oracle 10.2 and higher)
--
--------------------------------------------------------------------------------

prompt xb: eXplain Better (hash=&1 child=&2)

set verify off heading off feedback off pagesize 5000 tab off

set lines 999

column xms_child_number     heading "Ch|ld" format 99
break on xms_child_number   skip 1

column xms_id                                       heading Op|ID format 999
column xms_parent_id                                heading Par.|ID format a5
column xms_id2                                      heading Op|ID format a6
column xms_pred                                     heading Pred|#Col format a5
column xms_pos                                      heading Lvl|Pos for 99999
column xms_optimizer                                heading Optimizer|Mode format a10
column xms_plan_step                                heading Operation for a55
--column xms_plan_line                                heading "Row Source" for a70
column xms_plan_line                                heading "Row Source" for a55
column xms_qblock_name                              heading "Query Block|name" for a20
column xms_object_name                              heading Object|Name for a30
column xms_opt_cost                                 heading Optimizer|Cost for 99999999999
column xms_opt_card                                 heading "Estimated|output rows" for 999999999999
column xms_opt_bytes                                heading "Estimated|output bytes" for 999999999999
column xms_predicate_info                           heading "Predicate Information (identified by operation id):" format a100 word_wrap
column xms_cpu_cost                                 heading CPU|Cost for 9999999
column xms_io_cost                                  heading IO|Cost for 9999999

column xms_last_output_rows                         heading "Real #rows|returned" for 999999999
column xms_last_starts                              heading "Rowsource|starts" for 999999999
column xms_last_rows_start                          heading "#Rows ret/|per start" for 999999999
column xms_last_cr_buffer_gets                      heading "Consistent|gets" for 999999999
column xms_last_cr_buffer_gets_row                  heading "Consistent|gets/row" for 999999999
column xms_last_cu_buffer_gets                      heading "Current|gets" for 999999999
column xms_last_cu_buffer_gets_row                  heading "Current|gets/row" for 999999999
column xms_last_disk_reads                          heading "Physical|reads" for 999999999
column xms_last_disk_writes                         heading "Physical|writes" for 999999999
column xms_last_elapsed_time_ms                     heading "ms spent in|operation" for 9,999,999.99
column xms_last_memory_used                         heading "Memory|used (kB)" for 9,999,999.99
column xms_last_execution                           heading "Workarea|Passes" for 9,999,999.99


--select
--  'Warning: statistics_level is not set to ALL!'||chr(10)||
--  'Run: alter session set statistics_level=all before executing your query...' warning
--from
--  v$parameter
--where
--  name = 'statistics_level'
--and   lower(value) != 'all'
--/

select  --+ ordered use_nl(mys ses) use_nl(mys sql)
    'SQL hash value: '  xms_sql_hash_value_text,
    sql.hash_value      xms_hash_value,
    '   Cursor address: '   xms_cursor_address_text,
    sql.address     xms_sql_address,
    '   |   Statement first parsed at: '|| sql.first_load_time ||'  |  '||
    round( (sysdate - to_date(sql.first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*86400 ) || ' seconds ago' xms_seconds_ago
from
    v$sql       sql,
    all_users   usr
where
    sql.parsing_user_id = usr.user_id
and sql.hash_value in (&1)
--and  sql.hash_value = &1
and to_char(sql.child_number) like '&2'
order by
    sql.hash_value asc,
    sql.child_number asc
/

set heading on

set pagesize 30

select  
    p.child_number                                     xms_child_number,
    CASE WHEN p.filter_predicates IS NOT NULL THEN 'F' ELSE ' ' END ||
    CASE WHEN p.access_predicates IS NOT NULL THEN 'A' ELSE ' ' END ||
    CASE p.search_columns WHEN 0 THEN NULL ELSE '#'||TO_CHAR(p.search_columns) END   xms_pred,
    p.id                                                               xms_id,
--    nvl2(p.parent_id, trim(to_char(p.parent_id, '9999')), ' root')||'.'||trim(p.position)                    xms_uniq_step,
    nvl2(p.parent_id, to_char(p.parent_id, '9999'), ' root')                                   xms_parent_id,
--    LPAD(' ',p.depth*1,' ')|| to_char(p.position, '999') xms_pos,
    p.position xms_pos,
--    LPAD(' ',p.depth*1,' ')||''||to_char(p.position, '999') || '...' || p.operation || ' ' || p.options ||' '
    LPAD(' ',p.depth*1,' ')|| p.operation || ' ' || p.options ||' '
         ||nvl2(p.object_name, '('||p.object_name||')', null)
         ||nvl2(p.object_node, ' ['||p.object_node||']', null)
        -- ||nvl2(p.qblock_name, ' @ '||p.qblock_name, null)  
                                                                       xms_plan_line, 
    p.qblock_name                                                      xms_qblock_name,
--    p.object_name                                                      xms_object_name,
--  LPAD(' ',p.depth*1,' ')|| p.operation || ' ' || p.options          xms_plan_step, 
--  p.object_name                                                      xms_object_name,
--  p.qblock_name                                                      xms_qblock_name,
--    p.other,
--    p.other_tag,
--    p.distribution,
--  p.optimizer                                                        xms_optimizer,
--  p.object#,
--    p.object_instance,
    p.object_type,
--   p.other_tag,
--   p.distribution,
-- DEV
--    round (lag(ps.last_elapsed_time/1000,2,1) over (
--                                           order by nvl2(p.parent_id, (to_char(p.parent_id, '9999')), '      ')||'.'||trim(p.position)
--                                        )) - round(ps.last_elapsed_time/1000,2)  xms_last_elapsed_time_d,
    round(ps.last_elapsed_time/1000,2)                                  xms_last_elapsed_time_ms,
    p.cardinality                                                      xms_opt_card,
    ps.last_output_rows                                                 xms_last_output_rows,
    ps.last_starts                                                      xms_last_starts,
    ps.last_output_rows / DECODE(ps.last_starts,0,1,ps.last_starts)       xms_last_rows_start,
    ps.last_cr_buffer_gets                                              xms_last_cr_buffer_gets,
    ps.last_cr_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xms_last_cr_buffer_gets_row,
    ps.last_cu_buffer_gets                                              xms_last_cu_buffer_gets,
    ps.last_cu_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xms_last_cu_buffer_gets_row,
    ps.last_disk_reads                                                  xms_last_disk_reads,
    ps.last_disk_writes                                                 xms_last_disk_writes,
    ps.last_memory_used/1024                                            xms_last_memory_used,
    ps.last_execution                                                   xms_last_execution,
    p.cost                                                             xms_opt_cost
--  p.bytes                                                            xms_opt_bytes,
--  p.cpu_cost                                                         xms_cpu_cost,
--  p.io_cost                                                          xms_io_cost,
--  p.other_tag,
--  p.other,
--  p.access_predicates,
--  p.filter_predicates,
from 
    v$sql_plan p
  , v$sql_plan_statistics_all ps
where
    p.address           =  ps.address          (+)          
and p.hash_value        =  ps.hash_value       (+)                  
and p.sql_id            =  ps.sql_id           (+)     
and p.plan_hash_value   =  ps.plan_hash_value  (+)              
and p.child_number      =  ps.child_number     (+)
and p.id                =  ps.id               (+) 
and p.hash_value = &1
and to_char(p.child_number) like '&2'  -- to_char is just used for convenient filtering using % for all children
order by
    p.hash_value asc,
    p.address asc,
    p.child_number asc,
--    nvl2(p.parent_id, (to_char(p.parent_id, '9999')), '      ')||'.'||trim(p.position)
    p.id asc    
/

prompt

set pagesize 5000

select
    xms_child_number,
    xms_id2,
    xms_predicate_info 
from (
    select
        hash_value                  xms_hash_value,
        child_number                xms_child_number,
        lpad(id, 5, ' ')            xms_id2,
        ' - access('|| substr(access_predicates,1,3989) || ')' xms_predicate_info
    from
        v$sql_plan
    where
        hash_value in (&1)
    and to_char(child_number) like '&2'
    and access_predicates is not null
    union all
    select
        hash_value                  xms_hash_value,
        child_number                xms_child_number,
        lpad(id, 5, ' ') xms_id2,
        ' - filter('|| substr(filter_predicates,1,3989) || ')' xms_predicate_info
    from
        v$sql_plan
    where
        hash_value in (&1)
--      hash_value = &1
    and to_char(child_number) like '&2'
    and filter_predicates is not null
)
order by
    xms_hash_value asc,
    xms_child_number asc,
    xms_id2 asc,
    xms_predicate_info asc
/


prompt

set feedback on
