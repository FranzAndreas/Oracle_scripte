--FUNCTION GET_SQL_HASH RETURNS NUMBER
-- Argument Name                  Type                    In/Out Default?
-- ------------------------------ ----------------------- ------ --------
-- NAME                           VARCHAR2                IN
-- HASH                           RAW                     OUT
-- PRE10IHASH                     NUMBER                  OUT

VAR md5hash VARCHAR2(100)
VAR pre10hash NUMBER
VAR hash NUMBER

EXEC :hash := DBMS_UTILITY.GET_SQL_HASH('&1', :md5hash, :hash);

print hash pre10hash md5hash

PROMPT INCORRECT OUTPUT - IGNORE ME (FOR NOW) !!!