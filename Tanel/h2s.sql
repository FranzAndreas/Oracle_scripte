-- http://www.williamrobertson.net/documents/one-row.html


--SELECT
--     LTRIM(MAX(SYS_CONNECT_BY_PATH(c,','))
--     KEEP (DENSE_RANK LAST ORDER BY curr),',') AS concatenated
--FROM (
    SELECT 
        CHR(TO_NUMBER(SUBSTR(hex,((level-1)*2)+1,2), 'XX')) c
--      , ROW_NUMBER() OVER (ORDER BY TRUNC((ROWNUM-1)/4)*4+4-MOD(ROWNUM-1,4)) AS curr
--      , ROW_NUMBER() OVER (ORDER BY TRUNC((ROWNUM-1)/4)*4+4-MOD(ROWNUM-1,4)) -1 AS prev
    FROM (
        SELECT 
             UPPER(REPLACE(TRANSLATE('&1',',',' '), ' ', '')) hex 
        FROM dual
    )
    CONNECT BY
        SUBSTR(hex,(level-1)*2,2) IS NOT NULL
    -- OR SUBSTR(hex,(level-1)*2,2) != '00'
    ORDER BY
        TRUNC((ROWNUM-1)/4)*4+4-MOD(ROWNUM-1,4)
--)
--CONNECT BY prev = PRIOR curr AND curr < 10
--START WITH curr = 1
/
