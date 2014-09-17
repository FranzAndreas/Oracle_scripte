prompt
prompt WARNING!!! This script will query X$KSMSP, which will cause heavy shared pool latch contention 
prompt in systems under load and with large shared pool. This may even completely hang 
prompt your instance until the query has finished! You probably do not want to run this in production!
prompt
pause  Press ENTER to continue, CTRL+C to cancel...


select
	'SGA' LOC,
	ADDR,
	INDX,
	INST_ID,
	KSMCHIDX,
	KSMCHDUR,
	KSMCHCOM,
	KSMCHPTR,
	KSMCHSIZ,
	KSMCHCLS,
	KSMCHTYP,
	KSMCHPAR
from 
	x$ksmsp 
where 
	to_number(substr('&1', instr(lower('&1'), 'x')+1) ,'XXXXXXXXXXXXXXXX') 
	between 
		to_number(ksmchptr,'XXXXXXXXXXXXXXXX')
	and	to_number(ksmchptr,'XXXXXXXXXXXXXXXX') + ksmchsiz - 1
union all
select
	'UGA',
	ADDR,
	INDX,
	INST_ID,
	null,
	null,
	KSMCHCOM,
	KSMCHPTR,
	KSMCHSIZ,
	KSMCHCLS,
	KSMCHTYP,
	KSMCHPAR
from 
	x$ksmup 
where 
	to_number(substr('&1', instr(lower('&1'), 'x')+1) ,'XXXXXXXXXXXXXXXX') 
	between 
		to_number(ksmchptr,'XXXXXXXXXXXXXXXX')
	and	to_number(ksmchptr,'XXXXXXXXXXXXXXXX') + ksmchsiz - 1
union all
select
	'PGA',
	ADDR,
	INDX,
	INST_ID,
	null,
	null,
	KSMCHCOM,
	KSMCHPTR,
	KSMCHSIZ,
	KSMCHCLS,
	KSMCHTYP,
	KSMCHPAR
from 
	x$ksmpp 
where 
	to_number(substr('&1', instr(lower('&1'), 'x')+1) ,'XXXXXXXXXXXXXXXX') 
	between 
		to_number(ksmchptr,'XXXXXXXXXXXXXXXX')
	and	to_number(ksmchptr,'XXXXXXXXXXXXXXXX') + ksmchsiz - 1
/
