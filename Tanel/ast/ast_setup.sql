DEF datafile_dir=/export/home/oracle/oradata/SOL102

CREATE TABLESPACE ast DATAFILE '&datafile_dir/ast.01.dbf' SIZE 200M AUTOEXTEND ON;

CREATE USER ast IDENTIFIED BY ast DEFAULT TABLESPACE ast TEMPORARY TABLESPACE temp;

ALTER USER ast QUOTA UNLIMITED ON ast;

GRANT CREATE SESSION TO ast;
GRANT CONNECT, RESOURCE TO ast;
GRANT SELECT ANY DICTIONARY TO ast;

GRANT EXECUTE ON DBMS_LOCK TO ast;
GRANT EXECUTE ON DBMS_MONITOR  TO ast;

GRANT EXECUTE ON DBMS_SQLTUNE TO ast;
GRANT EXECUTE ON DBMS_WORKLOAD_REPOSITORY TO ast;

-- for testing
GRANT DBA TO ast;

