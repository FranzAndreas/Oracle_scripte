col tabpart_high_value head HIGH_VALUE_RAW for a32

select
    table_owner        
  , table_name         
  , partition_position pos
  , composite          
  , partition_name     
  , subpartition_count 
  , high_value         tabpart_high_value
  , high_value_length  
From
    dba_tab_partitions
where
    upper(table_name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND table_owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
/
