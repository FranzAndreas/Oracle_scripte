-- Compare Optimizer Features Enable Parameter values
-- By Tanel Poder ( http://www.tanelpoder.com )
--   Requires opt_param_matrix table to be created (using tools/optimizer/optimizer_features_matrix.sql)
--   Requires Oracle 11g due PIVOT clause (but you can rewrite this SQL in earlier versions)`

prompt Compare Optimizer_Features_Enable Parameter differences
prompt for values &1 and &2

select * from (
    select * 
    from opt_param_matrix 
    pivot( 
        max(substr(value,1,20)) 
        for opt_features_enabled in ('&1','&2')
    ) 
    where "'&1'" != "'&2'"
) 
order by parameter
/

