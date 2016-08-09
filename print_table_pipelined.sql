CREATE OR REPLACE type printTblScalar
AS
  object
  (
    cname  VARCHAR2(30),
    cvalue VARCHAR2(4000) )

;

CREATE OR REPLACE type printTblTable
AS
  TABLE OF printTblScalar
;

CREATE OR REPLACE FUNCTION print_table_pipelined(
  p_query    IN VARCHAR2,
  p_date_fmt IN VARCHAR2 DEFAULT 'dd-mon-yyyy hh24:mi:ss' )
RETURN printTblTable authid current_user PIPELINED
IS
  pragma autonomous_transaction;
  l_theCursor   INTEGER DEFAULT dbms_sql.open_cursor;
  l_columnValue VARCHAR2(4000);
  l_status      INTEGER;
  l_descTbl dbms_sql.desc_tab2;
  l_colCnt   NUMBER;
  l_cs       VARCHAR2(255);
  l_date_fmt VARCHAR2(255);
  -- small inline procedure to restore the sessions state
  -- we may have modified the cursor sharing and nls date format
  -- session variables, this just restores them
  PROCEDURE restore
  IS
  BEGIN
    IF ( upper(l_cs) NOT IN ( 'FORCE','SIMILAR' )) THEN
      EXECUTE immediate 'alter session set cursor_sharing=exact';
    END IF;
    IF ( p_date_fmt IS NOT NULL ) THEN
      EXECUTE immediate 'alter session set nls_date_format=''' || l_date_fmt || '''';
    END IF;
    dbms_sql.close_cursor(l_theCursor);
  END restore;
BEGIN
  -- I like to see the dates print out with times, by default, the
  -- format mask I use includes that.  In order to be "friendly"
  -- we save the date current sessions date format and then use
  -- the one with the date and time.  Passing in NULL will cause
  -- this routine just to use the current date format
  IF ( p_date_fmt IS NOT NULL ) THEN
    SELECT sys_context( 'userenv', 'nls_date_format' ) INTO l_date_fmt FROM dual;
    EXECUTE immediate 'alter session set nls_date_format=''' || p_date_fmt || '''';
  END IF;
  -- to be bind variable friendly on this ad-hoc queries, we
  -- look to see if cursor sharing is already set to FORCE or
  -- similar, if not, set it so when we parse -- literals
  -- are replaced with binds
  IF ( dbms_utility.get_parameter_value ( 'cursor_sharing', l_status, l_cs ) = 1 ) THEN
    IF ( upper(l_cs) NOT IN ('FORCE','SIMILAR')) THEN
      EXECUTE immediate 'alter session set cursor_sharing=force';
    END IF;
  END IF;
  -- parse and describe the query sent to us.  we need
  -- to know the number of columns and their names.
  dbms_sql.parse( l_theCursor, p_query, dbms_sql.native );
  dbms_sql.describe_columns2 ( l_theCursor, l_colCnt, l_descTbl );
  -- define all columns to be cast to varchar2's, we
  -- are just printing them out
  FOR i IN 1 .. l_colCnt
  LOOP
    IF ( l_descTbl(i).col_type NOT IN ( 113 ) ) THEN
      dbms_sql.define_column (l_theCursor, i, l_columnValue, 4000);
    END IF;
  END LOOP;
  -- execute the query, so we can fetch
  l_status := dbms_sql.execute(l_theCursor);
  -- loop and print out each column on a separate line
  -- bear in mind that dbms_output only prints 255 characters/line
  -- so we'll only see the first 200 characters by my design...
  WHILE ( dbms_sql.fetch_rows(l_theCursor) > 0 )
  LOOP
    FOR i IN 1 .. l_colCnt
    LOOP
      IF ( l_descTbl(i).col_type NOT IN ( 113 ) ) THEN
        dbms_sql.column_value ( l_theCursor, i, l_columnValue );
        pipe row( printTblScalar( l_descTbl(i).col_name, SUBSTR(l_columnValue,1,4000) ) );
      END IF;
    END LOOP;
    pipe row( printTblScalar( rpad('-',10,'-'), NULL ) );
  END LOOP;
  -- now, restore the session state, no matter what
  restore;
  RETURN;
EXCEPTION
WHEN OTHERS THEN
  restore;
  raise;
END;
