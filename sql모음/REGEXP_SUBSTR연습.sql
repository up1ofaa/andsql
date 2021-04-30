TABLE T
AS
SELECT 1 "GB", 10 "1", 17 "2",NULL "3", 10 "4" FROM DUAL --;
UNION
SELECT 3 "GB", 12 "1", 15 "2",NULL "3", NULL "4" FROM DUAL --;
UNION
SELECT 2 "GB", 11 "1", NULL "2",11 "3", 21 "4" FROM DUAL --;
UNION
SELECT 4 "GB", 15 "1", 25 "2",15 "3", 19 "4" FROM DUAL --;
;

SELECT * FROM T;
SELECT DUMP(1,10) FROM DUAL;
DROP TABLE T;

SELECT REGEXP_SUBSTR( '가나,다라,마바,사아,자차', '[^,$]+', 1, 1) AS COL1
--		,REGEXP_SUSTR('가나,다라,마바,사아,자차','[^,]+',0,1) AS COL2
--		,REGEXP_SUSTR('가나,다라,마바,사아,자차','[^,]+',0,2) AS COL3
--		,REGEXP_SUSTR('가나,다라,마바,사아,자차','[^,]+',0,3) AS COL4
FROM DUAL;

SELECT regexp_substr('가나,다라,마바,사아','[^,$]+',1,1) as sol
from dual;

SELECT REGEXP_LIKE('가나,다라,마바,사아,자차','[^$]') as sol
from dual;

/*
이론 REGEXP는 ORACLE 10G에서만 가능

1. REGEXP_LIKE(srcstr, pattern[match_option]
-srcstr : 소스문자열, 검색하고자 하는 값
-pattern :regular expression operator, 특정 문자보다 다야한 pattern으로 검색하는 것이가능
-match_option:match를 시도할 떄의 옵션, 찾고자하는 문자의 대소문자 구분이 기본적으로 설정, 대소문자구분 필요없다면 i옵션사용

[[:digit:]] 숫자인것
[^[:digit:]]  숫자가 아닌것
[^ expression]: expression의 부정
[]: []안에 명시되는 하나의 문자라도 일치하는 것이 있으면 나타냄


*/
/*숫자나오기직전까지의 주소*/
select regexp_substr('경기 고양시 덕양구 삼원로 102,  108동 1707호 (원흥동)','[^[:digit:]]+',1,1)
from dual;


select

a.tt
from (select '1fdfd' tt
        from dual
        union
        select 'dfdfdfd' tt
        from  dual
        union
        select 'dfdfdfk'  tt
        from dual ) a
where regexp_like (a.tt, 'dfk');
  select substr('sdfdfd',0) from dual;

SELECT regexp_replace('경기 수원시 권선구 아자차 1길 535','[[:digit:]]+','') from dual;

SELECT regexp_substr('경기 수원시 권선구 아자차 1길 535','[^[:digit:]]+') from dual;
select substr('dfdfdfsa', 0,(select instr('dfdfdfsa','s') from dual)) from dual;
select substr('dfdfdfsa', 0) from dual;
SELECT regexp_substr('경기 수원시 권선구 아자차 1길 535','[^[:digit:]]+') from dual;

SELECT regexp_substr('경기 수원시 권선구 아자차 1길 535','[구]') from dual;
/*

CREATE OR REPLACE FUNCTION OPARSE.regexp_substr (
source_char IN VARCHAR2
,pattern IN VARCHAR2
,POSITION IN    PLS_INTEGER DEFAULT 0
,match_parameter IN VARCHAR2 DEFAULT NULL)
RETURN INTEGER AS

--Variables
l_source_string VARCHAR2(32767);
l_temp_string VARCHAR2(32767);
l_flags VARCHAR2(10);
l_occurrence    PLS_INTEGER;
l_end_of_pattern_pos  PLS_INTEGER;
l_string_pos    PLS_INTEGER;


BEGIN
--substr the source_char to start at the position specified
l_source_string :=SUBSTR(source_char, POSITION);
--Set up the flags argument
--Now replace the regular expression pattern globally if "g"
l_string_pos :=0;
l_occurrence :=0;

l_end_of_pattern_pos :=owa_pattern.amatch(line  => l_source_string
                                                    ,from_loc => l_string_pos
                                                    ,pat =>pattern
                                                    ,flags => match_parameter);

 l_source_string :=  SUBSTR(l_source_string,0,l_occurrence );
--Not a global replace -loop until the "occurrence" th occurrence is replaced...



    RETURN l_end_of_pattern_pos;
END regexp_substr;
/


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
union select instr('dfd9fsfd234', 0) col from dual ) a
;


select substr('경기 수원시 권선구 아자차 1길 535',0) from dual;

select regexp_instr('Techonthenet is a great resource', 't')
from dual;

/* 숫자와 문자열 위치탐색*/
select regexp_instr('TechontA112 is a atADF122 resource','[[:digit:]]+',1,2)
from dual;

select regexp_instr('TecntA112 is a atADF122 resource','[^[:digit:]]+',1,2)
from dual;


/*오라클 함수 권한 추가*/
--grant execute
--on regexp_substr       --함수명
--to opadev3             --사용자이름
--;

--함수 시노님 생성


--CREATE SYNONYM 계정명.함수명 FOR 시노님명;

--create synonym opadev.regexp_substr for regexp_substr  ;
