prompt Gather Table Statistics for table &1....
exec dbms_stats.gather_table_stats(user, upper('&1'), null, method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE REPEAT', cascade=>true);

