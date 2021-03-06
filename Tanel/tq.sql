prompt Show PX Table Queue statistics from last Parallel Execution in this session...

col tq_tq head "TQ_ID|(DFO,SET)" for a10
col tq_flow_dir head "TQ_FLOW|DIRECTION" for a9

break on tq_tq on dfo_number skip 1 on tq_id skip 1

select 
    ':TQ'||trim(to_char(t.dfo_number))||trim(to_char(t.tq_id,'0999')) tq_tq
  , DECODE(replace(SERVER_TYPE,chr(0),''),'Producer', 'Produced', 'Consumer', 'Consumed', SERVER_TYPE) tq_flow_dir
  , NUM_ROWS     
  , BYTES        
--  , OPEN_TIME    
--  , AVG_LATENCY  
  , WAITS        
  , TIMEOUTS     
  , PROCESS      
  , INSTANCE    
  , DFO_NUMBER
  , TQ_ID 
from 
    v$pq_tqstat t
order by 
    dfo_number, tq_id,server_type  desc
/

