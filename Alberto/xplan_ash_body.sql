--------------------------------------------------------------------------------
-- Author:      Alberto Dell'Era
-- Copyright:   (c) 2008-2013 Alberto Dell'Era http://www.adellera.it
--------------------------------------------------------------------------------

&COMM_IF_LT_10G. procedure ash_info_initialize( p_inst_id int ) 
&COMM_IF_LT_10G. is
&COMM_IF_LT_10G.   l_code varchar2(100);
&COMM_IF_LT_10G.   l_ash_info ash_info_t;
&COMM_IF_LT_10G. begin
&COMM_IF_LT_10G.   if m_ash_over_thr_initialized then
&COMM_IF_LT_10G.     return;
&COMM_IF_LT_10G.   end if;
&COMM_IF_LT_10G.   m_ash_over_thr_initialized := true;
   
&COMM_IF_LT_10G.   for r in (select /*+ xplan_exec_marker */ sql_id, sql_child_number, 
&COMM_IF_LT_10G.                    min(sample_time) as sample_time_min, max(sample_time) as sample_time_max, count(*) as cnt   
&COMM_IF_LT_10G.               from sys.gv_$active_session_history 
&COMM_IF_LT_10G.              where inst_id = p_inst_id 
&COMM_IF_LT_10G.                and sql_id is not null
&COMM_IF_LT_10G.                and sql_child_number >= 0 
&COMM_IF_LT_10G.                -- optimizations for targeted searches 
&COMM_IF_LT_10G.                and (m_action_like     is null or lower(action  ) like lower(m_action_like) escape '\')
&COMM_IF_LT_10G.                and (m_module_like     is null or lower(module  ) like lower(m_module_like) escape '\')
&COMM_IF_LT_10G.                and (m_sql_id          is null or sql_id           = m_sql_id)
&COMM_IF_LT_10G.                and (m_parsing_user_id is null or user_id          = m_parsing_user_id)
&COMM_IF_LT_10G.                and (m_child_number    is null or sql_child_number = m_child_number)
&COMM_IF_LT_10G.                -- end of optimizations for targeted searches
&COMM_IF_LT_10G.              group by sql_id, sql_child_number
&COMM_IF_LT_10G.              having count(*) >= m_ash_cnt_thr
&COMM_IF_LT_10G.              order by sql_id, sql_child_number)  
&COMM_IF_LT_10G.   loop
&COMM_IF_LT_10G.     l_code := r.sql_id||'.'||r.sql_child_number;
&COMM_IF_LT_10G.     l_ash_info.sample_time_min := r.sample_time_min;
&COMM_IF_LT_10G.     l_ash_info.sample_time_max := r.sample_time_max;
&COMM_IF_LT_10G.     l_ash_info.cnt := r.cnt;
&COMM_IF_LT_10G.     m_ash_over_thr(l_code) := l_ash_info;
&COMM_IF_LT_10G.   end loop;
  
&COMM_IF_LT_10G.   -- -- debug print
&COMM_IF_LT_10G.   -- l_code := m_ash_over_thr.first;
&COMM_IF_LT_10G.   -- while l_code is not null loop
&COMM_IF_LT_10G.   --   print( ':: '||l_code||' '||m_ash_over_thr(l_code).cnt||' '||m_ash_over_thr(l_code).sample_time_min||' - '||m_ash_over_thr(l_code).sample_time_max );
&COMM_IF_LT_10G.   --   l_code := m_ash_over_thr.next(l_code);
&COMM_IF_LT_10G.   -- end loop;
&COMM_IF_LT_10G. end ash_info_initialize;
                       
procedure ash_print_stmt_profile (
  p_inst_id          sys.gv_$sql.inst_id%type,
  p_sql_id           varchar2, 
  p_child_number     sys.gv_$sql.child_number%type,
  p_first_load_time  date,
  p_last_load_time   date,
  p_last_active_time date
)
is
  &COMM_IF_LT_10G. l_sample_time_min timestamp(3);
  &COMM_IF_LT_10G. l_sample_time_max timestamp(3);
  &COMM_IF_LT_10G. l_prof scf_state_t;
  &COMM_IF_LT_11G. l_prof2 scf_state_t;
  &COMM_IF_LT_10G. l_code varchar2(100);  
  &COMM_IF_LT_10G. l_ash_info ash_info_t;
  &COMM_IF_LT_10G. l_prev_event sys.gv_$active_session_history.event%type;
  &COMM_IF_LT_11G. l_prev_line int;
begin
  if :OPT_ASH_PROFILE_MINS = 0 then
    return;                                
  end if;
                                  
  &COMM_IF_GT_9I.  print ('gv$active_session_history does not exist before 10g.');
             
  &COMM_IF_LT_10G. l_sample_time_min := greatest (p_first_load_time, nvl(p_last_active_time,systimestamp) - (:OPT_ASH_PROFILE_MINS / 1440));
  &COMM_IF_LT_10G. l_sample_time_max := nvl(p_last_active_time,systimestamp);
  &COMM_IF_LT_10G. print( l_sample_time_min||' '||l_sample_time_max);
  
  &COMM_IF_LT_10G. ash_info_initialize(p_inst_id);
  
  -- return if no enough samples exist in child cursor activity interval
  &COMM_IF_LT_10G. l_code := p_sql_id||'.'||p_child_number;
  &COMM_IF_LT_10G. if m_ash_over_thr.exists( l_code ) then
  &COMM_IF_LT_10G.   l_ash_info := m_ash_over_thr ( l_code );
  &COMM_IF_LT_10G.   if not (l_sample_time_min between l_ash_info.sample_time_min  and l_ash_info.sample_time_max or
  &COMM_IF_LT_10G.           l_sample_time_max between l_ash_info.sample_time_min  and l_ash_info.sample_time_max) then
  &COMM_IF_LT_10G.     print ('no sample found in v$ash for activity interval');
  &COMM_IF_LT_10G.     return;
  &COMM_IF_LT_10G.   end if;        
  &COMM_IF_LT_10G. else
  &COMM_IF_LT_10G.   print ('sample count zero or too low ( < '||m_ash_cnt_thr||' ) in v$ash');
  &COMM_IF_LT_10G.   return;
  &COMM_IF_LT_10G. end if;
  
  -- display ASH profile (event,object)
  &COMM_IF_LT_10G. l_prev_event := 'x';
  &COMM_IF_LT_10G. for p in (with ewb as (
  &COMM_IF_LT_10G.             select name
  &COMM_IF_LT_10G.               from sys.v_$event_name e
  &COMM_IF_LT_10G.              where e.wait_class in ('Application', 'Cluster', 'Concurrency', 'User I/O')
  &COMM_IF_LT_10G.           ), bas as (
	&COMM_IF_LT_10G. 						 select /*+ ordered use_hash(ewb o) */ /* xplan_exec_marker */  
	&COMM_IF_LT_10G.                    -- keep aligned with other profiles using event, current_obj#
	&COMM_IF_LT_10G. 										decode(a.session_state, 'WAITING', a.event, 'ON CPU', 'cpu/runqueue', '**error**') as event,
	&COMM_IF_LT_10G. 										decode(a.session_state, 'WAITING', decode(ewb.name, null, null, nvl(o.object_name, '#'||a.current_obj#) ), null) as object_name
	&COMM_IF_LT_10G. 							 from sys.gv_$active_session_history a, ewb, sys.dba_objects o
	&COMM_IF_LT_10G. 							where a.inst_id             = p_inst_id
	&COMM_IF_LT_10G. 								and a.sql_id              = p_sql_id
	&COMM_IF_LT_10G. 								and a.sql_child_number    = p_child_number
	&COMM_IF_LT_10G. 								and a.sample_time between l_sample_time_min and l_sample_time_max   
	&COMM_IF_LT_10G.                and a.event = ewb.name(+)
	&COMM_IF_LT_10G.                -- it costs too much: and (o.object_type not like 'JAVA%' and o.object_type not in('SYNONYM', 'TYPE', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY'))
	&COMM_IF_LT_10G.                and o.object_id(+) is not null
	&COMM_IF_LT_10G.                and a.current_obj# = o.object_id(+) -- checked this mapping, even for partitioned objects
	&COMM_IF_LT_10G. 					), gby as (
	&COMM_IF_LT_10G. 						select event, 
	&COMM_IF_LT_10G. 									 object_name,
	&COMM_IF_LT_10G. 									 count(*) as cnt 
	&COMM_IF_LT_10G. 							 from bas
	&COMM_IF_LT_10G. 							group by event, object_name
	&COMM_IF_LT_10G. 					)
	&COMM_IF_LT_10G. 					select event, object_name, 
	&COMM_IF_LT_10G. 					       sum(cnt) over(partition by event) as cnt_event,
	&COMM_IF_LT_10G. 								 100 * sum(cnt) over(partition by event) / sum(cnt) over() as perc_event,
	&COMM_IF_LT_10G. 								 cnt,
	&COMM_IF_LT_10G. 								 100 * cnt / sum(cnt) over(partition by event) as perc_in_event
	&COMM_IF_LT_10G. 						from gby 
	&COMM_IF_LT_10G. 						order by cnt_event desc, event, cnt desc
	&COMM_IF_LT_10G. 					)
  &COMM_IF_LT_10G. loop
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, 'ash event', case when p.event != l_prev_event then p.event      end);
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, 'cnt'      , case when p.event != l_prev_event then p.cnt_event  end);
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, '%'        , case when p.event != l_prev_event then p.perc_event end);  
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, 'object'   , p.object_name );
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, 'cnt2'     , p.cnt);
  &COMM_IF_LT_10G.   scf_add_elem (l_prof, '%/event'  , p.perc_in_event);  
  &COMM_IF_LT_10G.   l_prev_event := p.event;
  &COMM_IF_LT_10G. end loop;
  
  -- display ASH profile (plan line, event, object)
  &COMM_IF_LT_11G. l_prev_event := 'x';
  &COMM_IF_LT_11G. l_prev_line := -11;
  &COMM_IF_LT_11G. for p in (with ewb as (
  &COMM_IF_LT_11G.             select name
  &COMM_IF_LT_11G.               from sys.v_$event_name e
  &COMM_IF_LT_11G.              where e.wait_class in ('Application', 'Cluster', 'Concurrency', 'User I/O')
  &COMM_IF_LT_11G.           ), bas as (
	&COMM_IF_LT_11G. 						 select /*+ ordered use_hash(ewb o) */ /* xplan_exec_marker */  
	&COMM_IF_LT_11G.                    -- keep aligned with other profiles using event, current_obj#
	&COMM_IF_LT_11G. 										decode(a.session_state, 'WAITING', a.event, 'ON CPU', 'cpu/runqueue', '**error**') as event,
	&COMM_IF_LT_11G. 										decode(a.session_state, 'WAITING', decode(ewb.name, null, null, nvl(o.object_name, '#'||a.current_obj#) ), null) as object_name,
	&COMM_IF_LT_11G.                    sql_plan_line_id
	&COMM_IF_LT_11G. 							 from sys.gv_$active_session_history a, ewb, sys.dba_objects o
	&COMM_IF_LT_11G. 							where a.inst_id             = p_inst_id
	&COMM_IF_LT_11G. 								and a.sql_id              = p_sql_id
	&COMM_IF_LT_11G. 								and a.sql_child_number    = p_child_number
	&COMM_IF_LT_11G. 								and a.sample_time between l_sample_time_min and l_sample_time_max   
	&COMM_IF_LT_11G                 and a.event = ewb.name(+)
	&COMM_IF_LT_11G                 -- it costs too much: and (o.object_type not like 'JAVA%' and o.object_type not in('SYNONYM', 'TYPE', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY'))
	&COMM_IF_LT_11G                 and o.object_id(+) is not null
	&COMM_IF_LT_11G.                and a.current_obj# = o.object_id(+) -- checked this mapping, even for partitioned objects
	&COMM_IF_LT_11G. 					), gby as (
	&COMM_IF_LT_11G. 						select sql_plan_line_id,
	&COMM_IF_LT_11G.                   event, 
	&COMM_IF_LT_11G. 									 object_name,
	&COMM_IF_LT_11G. 									 count(*) as cnt                                                  
	&COMM_IF_LT_11G. 							 from bas
	&COMM_IF_LT_11G. 							group by sql_plan_line_id, event, object_name
	&COMM_IF_LT_11G. 					)
	&COMM_IF_LT_11G. 					select sql_plan_line_id, event, object_name, 
	&COMM_IF_LT_11G. 					       sum(cnt) over(partition by sql_plan_line_id) as cnt_line,
	&COMM_IF_LT_11G. 								 100 * sum(cnt) over(partition by sql_plan_line_id) / sum(cnt) over() as perc_line,
	&COMM_IF_LT_11G. 					       sum(cnt) over(partition by sql_plan_line_id, event) as cnt_event,
	&COMM_IF_LT_11G. 								 100 * sum(cnt) over(partition by sql_plan_line_id, event) / sum(cnt) over(partition by sql_plan_line_id) as perc_event_in_line,
	&COMM_IF_LT_11G. 								 cnt,
	&COMM_IF_LT_11G. 								 100 * cnt / sum(cnt) over(partition by sql_plan_line_id, event) as perc_in_event
	&COMM_IF_LT_11G. 						from gby 
	&COMM_IF_LT_11G. 						order by cnt_line desc, sql_plan_line_id, cnt_event desc, event, cnt desc
	&COMM_IF_LT_11G. 					)              
  &COMM_IF_LT_11G. loop
  &COMM_IF_LT_11G.   --print(p.sql_plan_line_id||' '||p.cnt_line||' '||lpad(p.event,22)||' '||p.cnt_event||' '||lpad(nvl(get_cache_obj_name(p.current_obj#),' '),5)||' '||p.cnt);
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, 'ash plan line', case when p.sql_plan_line_id != l_prev_line then p.sql_plan_line_id  end);
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, 'cnt'          , case when p.sql_plan_line_id != l_prev_line then p.cnt_line          end);
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, '%'            , case when p.sql_plan_line_id != l_prev_line then p.perc_line         end);  
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, 'event'        , case when p.sql_plan_line_id != l_prev_line or p.event != l_prev_event then p.event              end);
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, 'cnt2'         , case when p.sql_plan_line_id != l_prev_line or p.event != l_prev_event then p.cnt_event          end);
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, '%/line'       , case when p.sql_plan_line_id != l_prev_line or p.event != l_prev_event then p.perc_event_in_line end);  
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, 'object'       , p.object_name );
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, 'cnt3'         , p.cnt);
  &COMM_IF_LT_11G.   scf_add_elem (l_prof2, '%/event'      , p.perc_in_event);  
  &COMM_IF_LT_11G.   l_prev_event := p.event;
  &COMM_IF_LT_11G.   l_prev_line := p.sql_plan_line_id;
  &COMM_IF_LT_11G. end loop;
  
  &COMM_IF_LT_10G. scf_print_output (l_prof , 'no profile info found in v$ash.', 'no profile info found in v$ash.');
  &COMM_IF_LT_11G. scf_print_output (l_prof2, 'no profile info found in v$ash.', 'no profile info found in v$ash.');
end ash_print_stmt_profile;
  