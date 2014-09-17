col "phy read / sec" format 9999999.99
col "log read / sec" format 9999999.99
col BEGIN_INTERVAL_TIME format a40
select begin_interval_time, pr/sec "phy read / sec", lr/sec "log read / sec" from
(
   select begin_interval_time, snap_id,
   (cast(min(begin_interval_time) as date) - cast((lag(min(begin_interval_time)) over (order by snap_id)) as date))*24*60*60 sec,
   sum(pr) pr, sum(lr) lr
   from
           (
                   select s.snap_id, begin_interval_time, decode(stat_name, 'physical reads', delta, 0) pr, decode(stat_name, 'physical reads', 0, delta ) lr
                   from (select snap_id, INSTANCE_NUMBER, stat_name, value, value - lag(value) over (partition by stat_name order by snap_id) delta
                           from (select STAT_NAME, value ,  snap_id, INSTANCE_NUMBER
                                     from dba_hist_sysstat where stat_name in ('physical reads','db block gets','consistent gets')
                                     and INSTANCE_NUMBER = 1 order by snap_id)) s,
                                     dba_hist_snapshot ss where s.snap_id = ss.snap_id and s.instance_number = ss.instance_number)
           group by begin_interval_time, snap_id order by snap_id)
order by begin_interval_time;