--ORACLE 버젼확인하기
select *
from v$version;


-- ORACLE 제공 기본 함수
--(1) DECODE
DECODE(A,B,C,D,E,F)
    IF(A==B) PRINT("C")
    ELSE IF(A==D) PRINT("E")
    ELSE PRINT("F")
-- 만일 본래값이 문자이고, 최종 ELSE 값을 지정 안할경우 값이 NULL 로지정
-- EX)
	;
	SELECT DECODE('K','1','1','2','2') FROM DUAL;  --''
	SELECT DECODE('K','1','1','2','2',' ') FROM DUAL; --' '
	SELECT DECODE(1,1,1,2,2) FROM DUAL;--'1'

--(2) CASE
CASE WHEN THEN END:
	TYPE1 : CASE 비교당할것 WHEN 비교할것 THEN 출력될 것 END
	TYPE2 : CASE WHEN 비교수식(TRUE OR FALSE) THEN 출력될 것 END

--(3) NVL
NVL(컬럼, 숫자): 컬럼의 값이 NULL일 경우,해당 숫자로 치환
NVL(컬럼, '문자'): 컬럼 값이 NULL인 경우 해당 문자로 치환
NVL(컬럼, SYSDATE): 컬럼 값이 NULL인 경우 현재 시간으로 치환
NVL2(컬럼, A, B) :컬럼 값이 NULL이 아닐 경우 A, NULL일 경우 B로 치환

--(4) EXIST
SELECT column1 FROM t1 WHERE EXISTS(SELECT * FROM t2);
t2가 존재한다면 t1을 SELECT하게 된다.

--(5) SUBSTR
SELECT SUBSTR('PARKJUNHYUN', 2) FROM DUAL ;--=> ARKJUNGYUN  2번째위치에서 끝까지
SELECT SUBSTR('PARKJUNHYUN', 2, 3) FROM DUAL ;--=>ARK  2번째 위치에서 3자까지
SELECT SUBSTR('박준현천재', -3, 2) FROM DUAL ;--=> 현천    자를 위치가 음수이므로 우측을 기준으로 잘라 2자까지

--(6) SYSTIMESTAMP, SYSDATE / TO_CHAR ,EXTRACT
SELECT SYSTIMESTAMP FROM DUAL;
SELECT TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSXFF') FROM DUAL;
SELECT SYSDATE FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24MISS') FROM DUAL;
-- 요일구하기(1=일 ~7=토)
SELECT TO_CHAR(SYSDATE, 'D') FROM DUAL -- 3
-- 요일구하기(한글로 출력)
SELECT TO_CHAR(SYSDATE. 'DY') FROM DUAL --화
--발췌하기
select
systimestamp
, extract(year from systimestamp) as year
,lpad(extract(month from systimestamp),2,0) as month
,lpad(extract(day from systimestamp),2,0)   as day
,lpad(extract(hour from systimestamp),2,0)  as hour
,lpad(EXTRACT(HOUR from CAST(systimestamp AS TIMESTAMP)),2,0) as hour2
,lpad(extract(minute from systimestamp),2,0) as minute
,extract(second from systimestamp) as second
from dual
;

--(7) ORDER BY DESC(ASC) / LIMIT
-- 1, 이름, 제목
-- 2, 이름, 제목
-- 3, 이름, 제목
-- 4, 이름, 제목
-- 5, 이름, 제목
--=> 결과
SELECT NUM, NAME, TITLE FROM T1 ORDER BY NUM DESC LIMIT 2, 3;
--=> NUM값이 큰 수부터 거꾸로 출력하라는 뜻, 2번째부터  3개의 자료라는 뜻
-- 5,이름, 제목
-- 4,이름, 제목
-- 2,이름, 제목

/* NULL 값도 옵션을 넣어서 정렬할수 있다.
 NULL 값이 있는 COLUMN의 ORDER BY
 NULL 값이 있는 COLUMN을 ORDRY BY 할 경우 기본적으로 ASC(오름차순)일 경우  NULL 값은 아래 쪽에 DESC(내림차순)일 경우
 NULL값은 위 쪽에 정렬 되는 것
 정렬시 NULL값의 정렬 위치를 NULLS FIRST/ NULLS LAST 옵션을 통해 지정할 수 있다.

 EX) ,RANK() OVER(PARTITION BY  CUST_ID ORDER BY END_DIVI DESC NULLS FIRST ,PROP_TYPE, RGST_DIVI, PROP_SEQ  ) "MJ_RANK"
    END_DIVI 가  NULL값이 우선으로 정렬되는 순위함수에 적용됨

*/


--(8) GROUP BY 칼람, 칼람, 칼람 HAVING COUNT(*) >3 / HAVING SUM(칼람) >100
SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ
FROM WP01WOAA WP01
WHERE 1=1
AND ROWNUM <100
GROUP BY WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ
HAVING COUNT(*) >1  ;
-- PK인 CLNT_ID, CUST_ID, SEQ가 동일하고 나머지 PK(LOAN_NO)가 1개이상 존재하는 테이블이 조회됨

--(9) DESC   테이블 칼럼 확인
desc ca73tact
;

--(10) REPLACE 교체
UPDATE  IMSI_TB_SHY1
SET COL1 = REPLACE(COL1,'-','');
-- EX)881122-1232111   =>  8811221232111


--(11) IN => 다건 OR 처리    (최대 100건)
--AND CA02.CUST_ID = COMM_FUNC.F_GET_CUST_ID('1', IMSI.COL1)
SELECT IMSI.COL1 * FROM IMSI_TB_SHY1 IMSI -- =>  4210242235110, 4703142246918
--AND CA02.CUST_ID IN ( COMM_FUNC.F_GET_CUST_ID( '1', '4210242235110'), COMM_FUNC.F_GET_CUST_ID( '1', '4703142246918'))
--AND  ( CA02.CUST_ID= COMM_FUNC.F_GET_CUST_ID( '1', '4210242235110') OR   CA02.CUST_ID=COMM_FUNC.F_GET_CUST_ID( '1', '4703142246918') )


--(12) ALTER  => 테이블 칼럼 추가 변경 , COMMENT   =>  테이블 칼럼에 대한 설명  (추가시 반드시 코멘트 달것)
ALTER TABLE CE01CLOG ADD (RECV_RATE NUMBER(5) );
COMMENT ON COLUMN CE01CLOG.RECV_RATE IS	'수납금리';
-- TOAD에서 SCHEMAR BROWSER -TABLE선택 -우클릭- ALTER TABLE로도 수정가능하나, 운영계 변경시 쿼리작업이 필요하므로 위와 같이 작업할것
-- CREATE , ALTER, DROP 등은 따로 COMMIT이 필요하지 않음


--(13) DB LINK    :다른 데이터베이스의 테이블에 접근하는 방법
-- DB종류 : NEW_OPARSE (운영계), ANDDBDEV (개발계) , AND_DW (월마감,데이터웨어하우스)
-- 테이블명@링크명
-- EX) SELECT max(SU02.RECV_YMD)  FROM SU02RESU@opa_link  SU02        => opa_link의 링크명을 갖고 있는 DB접근
-- 링크명 확인하는방법 => TOAD에서 SCHEMAR BROWSER에서 DB Link에서 링크명 확인가능
-- 운영계에서 월마감db 접근하기 @anddw_link , 월마감db에서 운영계 접근하기 @opa_link
-- anddw db에서도 공통함수를 아래와 같이 사용할수 있다.
-- , COMM_FUNC.F_GET_CLNT_NAME@opa_link(CA07.CLNT_ID)


--(14) 합집합 : UNION ALL => 교집합 부분 2번 출력  / UNION => 교집합 부분 1번 출력
SELECT RECV_RATE
FROM CE01CLOG
WHERE ADMN_YYMM = '201509'
AND CLNT_ID = '001'
AND LOAN_NO = '9719068210020'
UNION
SELECT RECV_RATE
FROM M_SS01BASE@ANDDW_LINK
WHERE STDD_YYMM = '201509'
AND LOAN_NO = '9719068210020'
-- => 결과값 : 1 record

SELECT RECV_RATE
FROM CE01CLOG
WHERE ADMN_YYMM = '201509'
AND CLNT_ID = '001'
AND LOAN_NO = '9719068210020'
UNION ALL
SELECT RECV_RATE
FROM M_SS01BASE@ANDDW_LINK
WHERE STDD_YYMM = '201509'
AND LOAN_NO = '9719068210020'
-- => 결과값 : 2 record  (중복된 레코드)

--(15) WHERE EXIST (SELECT * FROM)
-- EXIST안의 레코드값이 존재하면 출력하라는 조건
SELECT /*+ HASH(ca07)*/
 COMM_FUNC.F_GET_CLNT_NAME(CA07.CLNT_ID) AS 위탁사
,CA02.CLNT_ID||'-'||CA02.CONT_NO||'-'||CA02.BOND_SEQ AS 채권번호
,CA01.LOAN_NO AS 대출번호
,COMM_FUNC.F_GET_TEAM_NAME('1', CA01.TEAM_CODE)                 AS 담당부서
,COMM_FUNC.F_GET_STAF_NAME('1', CA01.STAF_ID)                   AS 담당자명
,CA01.STAF_ID AS 담당자사번
,CASE WHEN (
			(SELECT COUNT(*)FROM LO03LEGL LO03, LO02DEBT LO02
			WHERE LO02.CUST_ID=CA02.CUST_ID
			AND LO02.CLNT_ID=CA02.CLNT_ID
			AND LO03.RQST_NO=LO02.RQST_NO
			AND LO03.USE_YN=' '
			AND LO02.USE_YN=' '
			  )  >0
			)
			THEN 'Y'
			ELSE 'N'
			END AS 법조치유무
,CA07.MEMO     AS SMS문구내용
,CA07.CNSL_DTTM AS SMS발송일시
,CA02.CUST_ID AS 고객번호
,CA02.CLNT_ID AS 위탁사코드
FROM CA01BOND CA01, CA02RELN CA02, CA07CNSL CA07
WHERE 1=1
AND CA02.CUST_ID=CA07.CUST_ID
AND CA02.CLNT_ID=CA07.CLNT_ID

AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND CA07.USE_YN=' '

AND CA07.CNSL_DIVI = '04'
AND (CA07.MEMO LIKE '%법적조치%'  OR CA07.MEMO LIKE '%소송%' OR CA07.MEMO LIKE '%강제집행%' OR CA07.MEMO LIKE '%유체%'
     )
AND CA07.CNSL_DTTM BETWEEN '20120201000000' AND '20150909999999'
AND NOT EXISTS (SELECT 1 FROM LO03LEGL LO03, LO02DEBT LO02
				 WHERE LO02.CUST_ID=CA02.CUST_ID
			       AND LO02.CLNT_ID=CA02.CLNT_ID
			       AND LO03.RQST_NO=LO02.RQST_NO
			       AND LO03.USE_YN=' '
			       AND LO02.USE_YN=' '
			    )
ORDER BY CNSL_DTTM DESC;


--(16) 날짜 비교 TO_DATE
--  EX ) 파산면책 종결일자 산출기간  2012.02.01 ~ 2015.09.09
-- 종결일자 칼람이 END_DATE가 날짜타입(SYSDATE, SYSTIMESTAMPS)형식이면
-- WP10.END_DATE BETWEEN TO_DATE('20120201','YYYYMMDD') AND TO_DATE('20150909' , 'YYYYMMDD')+ 0.99999;
-- 뒤에 +0.99999를 포함하므로써 2015.09.09에 해당하는 데이터도 산출할 수 있다.
SELECT TO_DATE('20150909' , 'YYYYMMDD')+ 0.99999  FROM DUAL;


--char형식을 날짜 형식으로 변환
select
INPT_TMSP--,TO_DATE(INPT_TMSP)
, SUBSTR(INPT_TMSP,0,14)
,TO_DATE(SUBSTR(INPT_TMSP,0,8),'YYYYMMDD')
,TO_DATE(SUBSTR(INPT_TMSP,0,14),'YYYYMMDD hh24:mi:ss')
--, TO_DATE(SUBSTR(INPT_TMSP,0,14),'YYYYMMDD hh24')--chng_pgm_id
from ca16memo
where clnt_id='003'
and inpt_tmsp like '2018071'||'%'
AND INPT_STAF='90000'


--(17) COUNT(*), GROUP BY
--   SELECT A , B , COUNT(*)
--     FROM TABLE
--   WHERE 1=1
--   GROUPT BY A, B
--  각 조건에 맞는 건수를 구할수 있다

SELECT  COMM_FUNC.F_GET_TEAM_NAME('1', CA01.TEAM_CODE)							AS 지점
       ,COMM_FUNC.F_GET_STAF_NAME('1', CA01.STAF_ID)                			AS 주담당자
       ,CASE WHEN CA07.CNSL_RESL IN ('06','07','08','09') THEN '통화실패'
             ELSE COMM_FUNC.F_GET_CODE_NAME('CNSL_RESL',CA07.CNSL_RESL) END     AS 상담결과
       ,COUNT(*) 																AS 건수

  FROM CA01BOND CA01
  	  ,CA02RELN CA02
      ,CA07CNSL CA07
 WHERE 1=1
   AND CA01.CLNT_ID = CA02.CLNT_ID
   AND CA01.CONT_NO = CA02.CONT_NO
   AND CA01.BOND_SEQ= CA02.BOND_SEQ

   AND CA02.CLNT_ID = CA07.CLNT_ID
   AND CA02.CUST_ID = CA07.CUST_ID

   AND CA01.CLNT_ID IN ('001','002','003')	-- 삼성,교보,한화
   AND CNSL_DTTM LIKE '201508%'
   AND CA01.TEAM_CODE='2033'     -- 강남지점
   AND CA01.END_DIVI='00'        -- 진행
   AND CA07.CNSL_RESL IN ('01','02','04','06','07','08','09','17') -- 01:변제약속 02:변제거부 04:재통화 06: 통화중 07:부재중 08: 통화정지 09: 결번  17:CRP상담

   AND CA01.USE_YN=' '
   AND CA02.USE_YN=' '
   AND CA07.USE_YN=' '
  GROUP BY
        COMM_FUNC.F_GET_TEAM_NAME('1', CA01.TEAM_CODE)
       ,COMM_FUNC.F_GET_STAF_NAME('1', CA01.STAF_ID)
       ,CASE WHEN CA07.CNSL_RESL IN ('06','07','08','09') THEN '통화실패'
             ELSE COMM_FUNC.F_GET_CODE_NAME('CNSL_RESL',CA07.CNSL_RESL) END
 ;

-- 18) ROUND(COLUMN_NAME, 소숫점 개수), 반올림
SELECT ROUND( 15.89, 0) FROM DUAL;    => 16
SELECT ROUND( 15.84952, 2) FROM DUAL; => 15.85

-- 19) 숫자로 비교하기 TO_NUMGER(칼람)
-- 칼럼의 데이터타입이 VARCHAR2(2)임
 DESC CE01CLOG;
 SELECT * FROM CE01CLOG WHERE TO_NUMBER(HSJ_CB_GRDE) BETWEEN 1 AND 5;
 SELECT * FROM CE01CLOG WHERE TO_NUMBER(HSJ_CB_GRDE) BETWEEN '1' AND '5';
 SELECT * FROM CE01CLOG WHERE HSJ_CB_GRDE BETWEEN '1' AND '5';     -- 10 도 산출된다


 -- 20) GROUP BY 통계
--   SELECT A , B , COUNT(*), CASE WHEN THEN END, SUM, SUM(CASE WHEN THEN END)
--     FROM TABLE
--   WHERE 1=1
--   GROUP BY A, B
--  각 조건에 맞는 건수를 구할수 있다
--  SELECT절과 GROUP절에 동일한 칼람으로 맞추되, COUNT(*), CASE, SUM등은 GROUP 절에 오지 않아도 된다.

-- 21) Outer join
-- 두 테이블의 데이터양이 차이가 많이 날때 사용 (inner join을 사용하면 정확한 검색이 어려움)
-- 일치하는 데이터가 없는 쪽에 (+)를 붙인다.=> 빈 행이 추가됨
--
outer조인
(1) A=B key 조인
A와 B의 공통 칼럼만 추출
(2) A=B(+) outer조인
A 칼럼 추출
(3) join칼럼뿐만 아니라 조건칼럼에도 (+)삽입
ex2)의 잘못된 outer조인임
ex3)의 올바른 outer조인의 예

ex1) 1023건
select *
  from ca01bond c01
 where c01.clnt_id = '001'
   and c01.cont_no = '05101'
   and c01.use_yn  = ' '
;
ex2) 209건
select c01.clnt_id
	  ,m.clnt_id
  from m_st01base@anddw_link M
      ,ca01bond c01
 where c01.clnt_id = '001'
   and c01.cont_no = '05101'
   and c01.use_yn  = ' '

   and M.stdd_yymm = '201508'
   and M.clnt_id   = '001'

   and c01.clnt_id=M.clnt_id(+)
   and c01.cont_no=M.cont_no(+)
   and c01.bond_seq=M.bond_seq(+)

ex3) 1023건
select c01.clnt_id
	  ,m.clnt_id
  from m_st01base@anddw_link M
      ,ca01bond c01
 where c01.clnt_id = '001'
   and c01.cont_no = '05101'
   and c01.use_yn  = ' '

   and M.stdd_yymm(+) = '201508'-- m_st01base의 pk로 만일 지정하지 않으면 월별에 해당하는 같은 채권번호가 모두 나오기 때문에
   and M.clnt_id(+)   = '001'

   and c01.clnt_id=M.clnt_id(+)
   and c01.cont_no=M.cont_no(+)
   and c01.bond_seq=M.bond_seq(+)

ex4) 151,773건
-- m_st01base의 pk로 만일 지정하지 않으면 월별에 해당하는 같은 채권번호가 모두 나오기 때문에
-- stdd_yymm의 조건을 주지 않으면 같은 채권의 8월,7월, 6월 등이 해당하는 데이터가 모두 나오기 때문임
select *
  from  m_st01base@anddw_link
where  clnt_id = '001'
   and cont_no = '05101'
   and bond_seq = 4

      ;
-- 22) Group by HAVING : 같은 LOAN_NO의 레코드갯수가 2개이상인 채권조회할때
    SELECT
    LOAN_NO
    FROM CA01BOND
    WHERE 1=1
    AND USE_YN=' '
    GROUP BY LOAN_NO HAVING COUNT(*) >1
    ;

-- 23) DISTINCT 통계: 중복건수 제외한 건  (월별 각각 진행 건수)  , 조건은 팀별
SELECT
DISTINCT '&STDD_YYMM' 											AS 기준년월
,COMM_FUNC.F_GET_TEAM_NAME('1', M01.TEAM_CODE)                  AS 주담당부서
,COUNT(DISTINCT M01.CLNT_ID||M01.CONT_NO||M01.BOND_SEQ)		 	AS 관리채권건수
,COUNT(DISTINCT M01.LOAN_NO)									AS 관리대출건수
,COUNT(DISTINCT CA02.CUST_ID) 									AS 관리관계인수
FROM  m_sT01base@anddw_link M01 , CA02RELN CA02
WHERE 1=1
AND  M01.STDD_YYMM='&STDD_YYMM'
AND M01.CLNT_ID=CA02.CLNT_ID
AND M01.CONT_NO=CA02.CONT_NO
AND M01.BOND_SEQ=CA02.BOND_SEQ
AND CA02.USE_YN=' '
GROUP BY M01.TEAM_CODE


--  24) 날짜함수
(1) SYSDATE
 SELECT SYSDATE+1 FORM DUAL  : 현재 날짜에 하루를 더해주는 예제
(2) MONTHS_BETWEEN   : 두 날짜가 몇 개월인지를 반환
 SELECT MONTHS_BETWEEN(SYSDATE,HIREDATE) FROM EMPLOYEE
(3) ADD_MONTHS
 SELECT ENAME, HIREDATE, ADD_MONTHS(HIREDATE,6) FROM EMPLOYEE  : HIREDATE에 6개월을 더해준 날짜 출력
 to_char(add_months(to_date(&p_inpt_date,'yyyymmdd'),-1),'yyyymm') : 전달
(4) NEXT_DAY
 SELECT SYSDATE, NEXT_DAY(SYSDATE,'일요일')FROM DUAL   : 현재날짜에서 일요일이 몇일인지를 반환
(5) LAST_DAY
 SELECT HIREDATE, LAST_DAY(HIREDATE) FROM EMPLOYEE     : 해당하는 달의 마지막날짜(28,29,30,31)을 반환해준다
(6) ROUND         : 인자로 받은 날짜를 특정기준으로 반올림
 SELECT ROUND(SYSDATE-HIREDATE) FROM EMPLOYEE
(7) TRUNC		: 인자로 받은 날짜를 특정 기준으로 버림
 SELECT TRUNC(SYSDATE-HIREDATE) FROM EMPLOYEE
(8)
SYSDATE + (INTERVAL '1' YEAR)        --1년 더하기
SYSDATE + (INTERVAL '1' MONTH)       --1개월 더하기
SYSDATE + (INTERVAL '1' DAY)         --1일 더하기
SYSDATE + (INTERVAL '1' HOUR)        --1시간 더하기
SYSDATE + (INTERVAL '1' MINUTE)      --1분 더하기
SYSDATE + (INTERVAL '1' SECOND)      --1초 더하기
SYSDATE + (INTERVAL '02:10' HOUR TO MINUTE)   --2시간10분 더하기
SYSDATE + (INTERVAL '01:30' MINUTE TO SECOND) --1분30초 더하기
--년을 더하고 빼기
SELECT SYSDATE - (INTERVAL '2' YEAR) MINUS_YEAR
        , SYSDATE + (INTERVAL '2' YEAR) ADD_YEAR
  FROM DUAL
-- EX)
SELECT TO_CHAR((TO_DATE('20150501', 'YYYYMMDD') + (INTERVAL '2' YEAR) ), 'YYYYMMDD')
  FROM DUAL
SELECT TO_CHAR((TO_DATE('20150501', 'YYYYMMDD') - (INTERVAL '2' DAY) ), 'YYYYMMDD')
  FROM DUAL

  -- 전월 자료산출시
  select
  to_char(add_months(to_date('20181031','yyyymmdd'),-1),'yyyymm')
  from dual

  ; --에러없음

  select
  TO_CHAR(to_date('20181031','yyyymmdd') - (INTERVAL '1' MONTH),'YYYYMM')
  from dual
	;	--에러남


-- 25) 올림함수 CEIL
SELECT CEIL(MONTHS_BETWEEN(TO_DATE('&STDD_YYMM'||'01','YYYYMMDD'), TO_DATE('20151130','YYYYMMDD')))+1
FROM DUAL;

-- 26) 여러칼럼 한번에 조건주기(SELECT)
SELECT *
FROM CA02RELN
WHERE (CLNT_ID, CONT_NO, BOND_SEQ) IN (	SELECT CLNT_ID, CONT_NO, BOND_SEQ
										FROM CA01BOND
										WHERE LOAN_NO = '104002143011');

-- 27) 조회한 항목 한꺼번에 입력하기, 복사 (INSERT) : 대신 칼럼, 항복 갯수가 일치해야한다
INSERT INTO CA01BOND
SELECT * FROM YA01TEMP
WHERE CUST_ID = '26803270139';

-- 28) 부서별 평균값 구하기
  SELECT TEAM_CODE, TEAM_NAME
	 	 , ROUND(AVG(INCE),2)
	 	 , SUM(INCE)
  		 , COUNT(*)
  		 , SUM(INCE)/ COUNT(*)
	FROM (   --(1)
			SELECT       X.TEAM_CODE
				       , X.TEAM_NAME
				       , (  X.CHNG_BDBT_RECV_PAMT * Y.RECV_RATE6
				      	 +  X.FEE_RECV_INCE_AMT
				      	 + CASE WHEN X.B >200 THEN X.B ELSE  200 END ) AS INCE
			FROM  X, Y        -- 이때 X, Y 조인없이 각각의 값을 자져올수 있다.(Y테이블의 레코드는 한줄)
			WHERE 1=1
			ORDER BY X.CHNG_BDBT_RECV_PAMT DESC
			)
	GROUP BY TEAM_CODE, TEAM_NAME          ;

-- 29) 공백제거 TRIM , REPLACE
SELECT RTRIM('    ABCDE FG   ') FROM DUAL ; -- '    ABCDE FG'
SELECT LTRIM('    ABCDE FG   ') FROM DUAL ; -- 'ABCDE FG   '
SELECT  TRIM('    ABCDE FG   ') FROM DUAL ; -- 'ABCDE FG'
--  값에 들어간 엔터값을 공백으로 처리하는 문구
SELECT replace('  KK  ADF
             D D F F  F F  ',chr(13)||chr(10),' ')        			FROM DUAL ; --'  KK  ADF              D D F F  F F  '
SELECT replace(replace(replace('  KK  ADF
             D D F F  F F  ',chr(13),' '),chr(10),' '),chr(9),' ')  FROM DUAL ; --'  KK  ADF              D D F F  F F  '
SELECT replace(replace(replace('  KK  ADF
             D D F F  F F  ',chr(13),' '),chr(32),' '),chr(9),' ')  FROM DUAL ; --'  KK  ADF              D D F F  F F  '
SELECT replace(replace(replace('  KK  ADF
             D D F F  F F  ',chr(13),' '),chr(0) ,' '),chr(9),' ')  FROM DUAL ; --'  KK  ADF
--             D D F F  F F  '
-- 지워지지 않는 공백제거
SELECT replace(to_single_byte('  KK  ADF
             D D F F  F F  '),' ','')     							FROM DUAL ; --'KKADF
--DDFFFF'

--CHR(9) : 탭문자
--CHR(10) : 줄바꿈(라인피드)
--CHR(13) : 행의 처음(캐리지리턴)
--CHR(38) : &
--CHR(39) : '(따옴표)
--CHR(44) : 쉼표



-- 30) 교집합과 차집합
--(30-1) INTERSECT는 두행의 집합중 공통된 행을 반환한다 (교집합)
SELECT CODE_VAL FROM CM02CODE WHERE CODE_ID='SS_ITEM_CODE'
INTERSECT
SELECT COL2 FROM IMSI_TB_SHY2
;

SELECT CODE_VAL FROM CM02CODE WHERE CODE_ID='SS_ITEM_CODE'
AND CODE_VAL IN (SELECT COL2 FROM IMSI_TB_SHY2)
;


--(30-2) MINUS는 첫번쨰 SELECT문에 의해 반환되는 행 중에서
-- 두번째 SELECT문에 의해 반환되는 행에 존재하지 않는 행들을 반환한다.
SELECT CODE_VAL FROM CM02CODE WHERE CODE_ID='SS_ITEM_CODE'
MINUS
SELECT COL2 FROM IMSI_TB_SHY2;


SELECT CODE_VAL FROM CM02CODE WHERE CODE_ID='SS_ITEM_CODE'
AND CODE_VAL NOT IN (SELECT COL2 FROM IMSI_TB_SHY2)
;

-- 31) DUMP : DUMP는 바이트 크기와 해당데이터 타입 코드를 반환
SELECT END_DATE, DUMP(END_DATE, 10) "10진수"
FROM CA01BOND
WHERE USE_YN=' '
AND END_DATE=TO_DATE('20160302','YYYYMMDD')
AND ROWNUM=1;

-- 03/02/2016 00:00:00	Typ=12 Len=7: 120,116,3,2,1,1,1
--Typ datatype
--1   varchar2(size)[byte/char]
--1   nvarchar2(size)
--2   number(p,s)
--8   long
--12  date
--23  raw(size)
--24  long raw
--69  rowid
--96  char(size)[byte/char]
--112 clob
--112 nclob
--113 blob
--114 bfile
--180 timestamp
--181 timestamp with time zone
--182 interval year to month
--183 interval da to second
--208 urowid(size)
--231 timestamp with local time zone

--32) GREATEST , LEAST : 가장 큰 칼럼, 가장 작은 칼럼
SELECT
RQST_YMD, CPLT_LAST_YMD, LAST_RECV_YMD,
GREATEST(RQST_YMD, CPLT_LAST_YMD, LAST_RECV_YMD),
LEAST(RQST_YMD, CPLT_LAST_YMD, LAST_RECV_YMD)
FROM CA01BOND
WHERE USE_YN=' ' AND CLNT_ID='001' AND CONT_NO='16011' AND BOND_SEQ='1'
;


--33) USERENV  , UID, USER
SELECT  USERENV('ENTRYID')    -- 사용가능한 Auditing entry Identifier를 반환
--		, USERENV('LABEL')    -- 현재 세션의 label을 반환
		, USERENV('LANGUAGE') -- 현재 세션에서 사융중인 언어와 테리토리 값으 반환
		, USERENV('SESSIONID')-- Auditing(감사), SeSSION id를 반환
		, USERENV('TERMINAL') -- 현재 세션 터미널의 OS ID를 반환
FROM DUAL;

SELECT 	  USER --현재 오라클 사용자
		, UID  --햔재사용자의 유일한 ID번호
FROM DUAL;


--34) VSIZE
SELECT END_DATE, VSIZE(END_DATE), CUST_NAME, VSIZE(CUST_NAME)
FROM CA01BOND
WHERE USE_YN=' '
AND END_DATE=TO_DATE('20160302','YYYYMMDD')
AND ROWNUM=1;
--해당문자의 BYTE 수를 반환, 해당 문자가 NULL이면 NULL값 반환

--35) LPAD , RPAD : 앞이나 뒤에 공란, 0을 채울수 있음
--LAPD: PADDING(채우기), 블랭크나 의미가 없는 기호를 부가하여 고정길이하는것
--LAPD(끝에채울값, 총자릿수, 앞에연속적으로 채울값)
--세번째 인자가 없으면 공란으로 채운다
SELECT LPAD('A',2) FROM DUAL;-- _A
SELECT LPAD('A',3,'B') FROM DUAL; -- BBA
SELECT LPAD('AA',3,'B') FROM DUAL; -- BBA
SELECT LPAD(25,5,0) FROM DUAL; --

--36) COALESCE
-- COALESCE(expr1, expr2, expr3, ...)
-- expr1이 NULL이 아니면 expr1 값을 그렇지 않으면 COALESCE(expr2, expr3, ...) 값을 반환
-- COMM      COALSESCE(COMM, 1)
--				1
--	300			300
--	500			500
--				1
--	1400		1400
--	0			0     

--37) CAST
-- CAST, CONVERT 함수 => 타입변환
-- CAST(expression as TYPE)

select cast(cont_no as integer)
from ca01bond
where use_yn=' '
and end_divi='00'
and clnt_id='003'
and rownum<100;

select inpt_tmsp
,cast(inpt_tmsp as timestamp)
,chng_date
,cast(chng_date as timestamp)
,cast(chng_date as date)
,cast(inpt_tmsp as float)

from ca16memo
where chng_date is not null
and rownum<100;

