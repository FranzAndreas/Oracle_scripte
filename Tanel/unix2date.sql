SELECT 
    to_char(to_date('01011970','ddmmyyyy') + 1/24/60/60 * &1, 'dd-Mon-yyyy hh24:mi:ss') "DATE"
FrOM DUAL
/

