set linesize 132;
set pagesize 1000;
set long 50;
set echo on;

break on "TBL SPACE" on "TOTAL BYTES";

/* *************************************************** */
/* block-size                                          */
/* *************************************************** */
column db_block_size new_value BLOCK_SIZE
select to_char(value, '9999') db_block_size
       from v$parameter
       where name = 'db_block_size';


/* *************************************************** */
/* date & user_id                                      */
/* *************************************************** */
column today new_value dba_date
select to_char(sysdate, 'mm/dd/yy hh:miam') today
       from dual;

break on instance
column instance new_value instance_name
select substr(name,1,4) instance
      from v$database;

clear breaks
set termout on

set pagesize 60 linesize 132 verify off
set space 2
ttitle left 'Date: ' format a18 dba_date -
       center 'Space Report - ' format a4 instance_name -
       right 'Page: ' format 999 sql.pno skip 2

set echo off;

set echo on;


/* *************************************************** */
/* tablespace usage via the dba_data_files             */
/* *************************************************** */
set echo off;

select  substr(D.tablespace_name, 1, 12) "TBL SPACE",
   substr(to_char(sum(D.bytes), '999,999,999,999'), 1, 16) "TOTAL BYTES",
   substr(to_char(sum(D.bytes)/1024/1024, '999,999.9'), 1, 10) "TOT MBYTES",
   substr(to_char(sum(D.bytes)/(Z.VALUE), '99,999,999'), 1, 11) "BLOCKS"
from    sys.dba_data_files D,
        v$parameter        Z
where Z.name = 'db_block_size'
group by D.tablespace_name, Z.value;

set echo on;


/* *************************************************** */
/*  show tablespace usage                              */
/* *************************************************** */
set echo off;

select  distinct substr(tablespace_name, 1, 12)      "TBL SPACE",
  substr(to_char(sum(blocks), '999,999,999'), 1, 12)              "TOT BLKS",
     substr(to_char(sum(bytes), '999,999,999,999'), 1, 16)           "TOT BYTES"
from    sys.dba_free_space
group by
 tablespace_name;

set echo on;


/* *************************************************** */
/*  show tablespace usage                              */
/* *************************************************** */
set echo off;

break on "TBL SPACE";

select  substr(tablespace_name,1,12)                           "TBL SPACE",
      substr(to_char(file_id, '99'), 1, 4)                  "ID",
    substr(to_char(count(*), '9,999'), 1, 6)              "PCS",
   substr(to_char(max(blocks), '9,999,999'), 1, 10)      "MAX BLKS",
      substr(to_char(min(blocks), '9,999,999'), 1, 10)      "MIN BLKS",
      substr(to_char(avg(blocks), '9,999,999.9'), 1, 12)    "AVG BLKS",
      substr(to_char(sum(blocks), '9,999,999'), 1,10)       "SUM BLKS",
      substr(to_char(sum(bytes), '99,999,999,999'), 1, 15)  "SUM BYTES"
from
  sys.dba_free_space
group by
    tablespace_name,file_id
order by 1, 4;

set echo on;


/* *************************************************** */
/*  show tablespace usage                              */
/* *************************************************** */
set echo off;

select
     distinct substr(tablespace_name,1,12)   "TBL SPACE",
    substr(to_char(sum(blocks), '999,999,999'), 1, 12)         "SUM BLKS",
 substr(to_char(sum(bytes)/(1024*1024), '999,999.999'), 1, 16) "SUM MBYTES"
from
     sys.dba_free_space
group by
     tablespace_name;

set echo on;
/* *************************************************** */
/*  show tablespace segments - order by segment        */
/* *************************************************** */
set echo off;

break on "SEGMENT" on "TYPE";

select substr(segment_name, 1, 20)                          "SEGMENT",
       substr(segment_type,1,7)                             "TYPE",
       substr(tablespace_name,1,8)                          "TBL SPACE",
       substr(to_char(sum(bytes)/(1024*1024), '999,999.999'), 1, 11)
                                                            "SUM Mb",
      /* substr(to_char(sum(blocks), '999,999'), 1, 8)         "SUM BLKS", */
       substr(to_char(extents, '999'), 1, 4)                 "EXTENTS",
       substr(to_char((initial_extent/(1024*1024)), '99,999.999'), 1, 10)
                                                             "INI (Mb)",
       substr(to_char((next_extent/(1024*1024)), '999.999'), 1, 8) "NXT (Mb)"
from    user_segments
group by segment_name,
         segment_type,
         tablespace_name,
         bytes,
         blocks,
         extents,
         initial_extent,
         next_extent
order by 1, 2;

set echo on;


/* *************************************************** */
/*  show tablespace segments - order by tablespace     */
/* *************************************************** */
set echo off;

break on "TBL SPACE" on "SEGMENT" on "TYPE";

select substr(tablespace_name,1,12)                           "TBL SPACE",
       substr(segment_name, 1, 20)                            "SEGMENT",
    /* substr(segment_type,1,7)                               "TYPE",  */
       substr(to_char(sum(bytes)/(1024*1024), '999,999.999'), 1, 12)
                                                              "SUM Mb",
    /* substr(to_char(sum(blocks), '9,999,999'), 1, 10)       "SUM BLKS", */
       substr(to_char(extents, '999'), 1, 4)                  "EXTS",
       substr(to_char(initial_extent/(1024*1024), '999.999'), 1, 8)
                                                              "INI Mb",
       substr(to_char(next_extent/(1024*1024), '999.999'), 1, 8)
                                                              "NXT Mb"
from    user_segments
group by segment_name,
         segment_type,
         tablespace_name,
         bytes,
         blocks,
         extents,
         initial_extent,
         next_extent
order by 1, 2;

set echo on;


/* *************************************************** */
/*  show tablespace segments - order by bytes          */
/* *************************************************** */
set echo off;

break on "SUM BYTES" on "SEGMENT" on "TYPE";

select substr(to_char(sum(bytes)/(1024*1024), '999,999.999'), 1, 11)
                                                              "SUM Mb",
       substr(segment_name, 1, 20)                            "SEGMENT",
       substr(tablespace_name,1,12)                           "TBL SPACE",
       /*substr(to_char(sum(blocks), '9,999,999'), 1, 10)     "SUM BLKS",*/
       substr(to_char(extents, '999'), 1, 4)                  "EXTS",
       substr(to_char(initial_extent/(1024*1024), '9,999.999'), 1, 10)
                                                              "INI Mb",
       substr(to_char(next_extent/(1024*1024), '999.999'), 1, 8)
                                                              "NXT Mb"
from    user_segments
group by segment_name,
         segment_type,
         tablespace_name,
         bytes,
         blocks,
         extents,
         initial_extent,
         next_extent
order by 1, 2;

set echo on;


/* *************************************************** */
/*  show size of database                              */
/* *************************************************** */
set echo off;

select  substr(to_char(sum(bytes)/1024/1024, '999,999,999.99'), 1, 15)  "TOT MBYTES",
        substr(to_char(sum(bytes)/1024/1024/1024, '999,999.99'), 1, 11) "TOT GBYTES"
from    sys.dba_data_files;

undefine BLOCK_SIZE;
set echo off;

set long 80;


 - - - - - - - - - - - - - - - -  Code ends here  - - - - - - - - - - - - - - - -