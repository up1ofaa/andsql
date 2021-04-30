/*
INSTR
1) Description
The Oracle/PLSQL INSTR Function returns the location of a substring in a string

2) Syntax
The syntax for the INSTR function in Oracle/PLSQL is:

INSTR(string, substring, start_position, nth_appearnce)
string : the string to search. string can be CHAR, VARCHAR2, NCHAR, NVARCHAR2 ,CLOB
substring : the substring to search for in string. substring can be CHAR, VARCHAR2, NCHAR, NVARCHAR2, CLOB,or NCLOB
start_position :optional. the position in string where the search will start.
if omited, it defaults to 1. the first position in the string is 1.
if the start_posistion is negative, the INSTR function count back start_posisiton number of characters from end of string
and then searches toward the beginning of string
nth_appearance
optional. the nth appearance of substring. if omitted , it defaults to 1.




*/


select min(a.col)
from ( select instr('dfd9fsfd234', 1) col from dual
union select instr('dfd9fsfd234', 2) col from dual
union select instr('dfd9fsfd234', 3) col from dual
union select instr('dfd9fsfd234', 4) col from dual
union select instr('dfd9fsfd234', 5) col from dual
union select instr('dfd9fsfd234', 6) col from dual
union select instr('dfd9fsfd234', 7) col from dual
union select instr('dfd9fsfd234', 8) col from dual
union select instr('dfd9fsfd234', 9) col from dual
union select instr('dfd9fsfd234', '0') col from dual ) a
where a.col<>0
;

select instr('dfd9fsfd234', '0') col from dual   ;
select instr('경기 수원시 권선구 아자차 1길 535', '구 ') col from dual;


select 1
from dual
where '경기 수원시 권선구 아자차 1길 535' like '%'||'구 '||'%'
or '경기 수원시 권선 아자차 1길 535' like '%'||'읍 '||'%'
or '경기 수원시 권선 아자차 1길 535' like '%'||'군 '||'%'
or '경기 수원시 권선 아자차 1길 535' like '%'||'동 '||'%'
;


 select min(a.col)
                from ( select instr('경기 수원시 권선구 아자차 1길 535', '구 ') col from dual
                    union select instr('경기 수원시 권선구 아자차 1길 535', '읍 ') col from dual
                    union select instr('경기 수원시 권선구 아자차 1길 535', '군 ') col from dual
                    union select instr('경기 수원시 권선구 아자차 1길 535', '동 ') col from dual
                    ) a
                where a.col<>0
                ;
SELECT SUBSTR('경기 수원시 권선구 아자차 1길 535',0,9) FROM DUAL;


select instr('tech on the net','e') from dual;
select instr('tech on the net','e',1,1) from dual;
select instr('tech on the net','e',1,2) from dual;
select instr('tech on the net','e',1,3) from dual;
select instr('tech on the net','e',-3,1) from dual;
select instr('tech on the net','e',-1,1) from dual;


select instr('경기 수원시 권선 아자차 1길 535', '동 ', 1,1) from dual;
select instr('경기 수원시 권선 아자차 1길 535', '선', 1,1) from dual;


 select substr('경기 수원시 권선 아자차 1길 535' , length('경기 수원시 권선 아자차 1길 535')-2, length('경기 수원시 권선 아자차 1길 535'))
  -- into last_char
   from dual;
select max(a.col)
                from ( select instr('경기 수원시 권선 아자차 1길 535', '구 ') col from dual union
                    select instr('경기 수원시 권선 아자차 1길 535', '읍 ') col from dual
                    union select instr('경기 수원시 권선 아자차 1길 535', '면 ') col from dual
                    union select instr('경기 수원시 권선 아자차 1길 535', '동 ') col from dual
                    ) a
                --where a.col<>0
                ;
                  
                
                
select regexp_substr(TRIM(COL1),'[^[:digit:]]+',1,1) as 숫자가아닌값첫번째
		,substr(regexp_substr(TRIM(COL1),'[[:digit:]]+',1),0,1)   as 숫자인값
		,INSTR(TRIM(COL1), substr(regexp_substr(TRIM(COL1),'[[:digit:]]+',1),0,1)) as 처음숫자값위치
		,substr( trim(col1), INSTR(TRIM(COL1), substr(regexp_substr(TRIM(COL1),'[[:digit:]]+',1),0,1)) ) as 첫숫자위치에서의값
from IMSI_TB_SHY1;                