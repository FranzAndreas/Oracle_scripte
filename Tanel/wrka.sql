prompt Show Active workarea memory usage for where &1....

select * 
from 
    v$sql_workarea_active 
where 
    &1
order by
    sid
  , sql_hash_value
  , operation_id
/
