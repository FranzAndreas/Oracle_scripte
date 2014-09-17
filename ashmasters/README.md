    see http://ashmasters.com for information on
    Oracle Active Session History (ASH)

queries contained in repository

* ash_bbw.sql - buffer busy wait analysis
* ash_graph_ash.sql - basic ASH load chart in ASCII art
* ash_graph_ash_histash.sql - ASH load chart from DBA_HIST_ACTIVE_SESS_HISTORY only
* ash_graph_histash_by_dbid.sql - ASH load chart from DBA_HIST_ACTIVE_SESS_HISTORY only, input DBID
* ash_graph_histash_by_dbid_program.sql - ASH load chart from DBA_HIST_ACTIVE_SESS_HISTORY only, input DBID and PROGRAM
* ash_graph_histash_by_dbid_sqlid.sql - ASH load chart from DBA_HIST_ACTIVE_SESS_HISTORY only, input DBID and a SQL_ID
* ash_io_sizes.sql - I/O sizes from ASH
* ash_sql_elapsed.sql - use ASH to find longest running SQL
* ash_sql_elapsed_hist.sql - use ASH to find longest running SQL, give histogram of execution times
* ash_sql_elapsed_hist_longestid.sql - use ASH to find longest running SQL, give histogram of execution times and execution id of longest running query
* ash_top_procedure.sql - top procedures and who they call
* ash_top_session.sql - top SESSION from ASH ordered by time broke into wait, I/O and CPU time
* ash_top_sql.sql - top SQL from ASH ordered by time broke into wait, I/O and CPU time
* latency_eventmetric.sql - wait event latency from V$EVENTMETRIC, ie last 60 seconds
* latency_system_event.sql - wait event latency from DBA_HIST_SYSTEM_EVENT 
* latency_waitclassmetric.sql - User I/O  latency from V$WAITCLASSMETRIC, ie  over last 60 seconds

* load_awr - physical and logical reads per sec from AWR with snapshot time
* top10_sql_with_events_from_AWR.sql - top 10 SQL queries with events per AWR snapshot
* topsql - top 10 sql per last N minutes from ASH
* aas_by_hour - display AAS (based on ASH) for number of days at specific time
* aas_15min - display AAS (based on AWR) for all AWR snapshots calculated per 15 min spilt with split between CPU and WAIT 
* event_histograms_delta_from_AWR.sql - event histograms deltas between AWR snapshots

* topaas - display OEM like graph based on sampling and v$session view - NO DIAGNOSTIC PACK required
