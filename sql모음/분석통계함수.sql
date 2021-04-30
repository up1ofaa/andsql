/* 분석함수
  --테이블에 있는 데이터를 특정 용도로 분석하여 결과를 반환하는 함수
  --복잡한 계산을 단순하게 처리해주는 함수
  -- select 절에서 수행됨
  	 from, where, group by 절에서 사용불가
  	 order by 구분에서 사용가능	*/
-- 집계함수 vs 분석함수
-- 집계함수는 그룹별 최대, 최소, 함계, 평균, 건수 등을 구할 때 사용되며, 그룹별 1개의 행을 반환한다
-- 분석함수는 그룹단위로 값을 계산한다는 점에서 집계함수와 유사하지만,
-- 그룹마다가 아니라 결과 set의 각 행마다 집계결과를 보여준다.
-- 분석함수는 쉽계 생각하여 그룹별 계산결과를 각행마다 보여주는것

SELECT   deptno
		,empno
		,sal
		,sum(sal) over(partition by deptno) s_sal
from emp;


select
clnt_id
--,substr(stdd_ymd,1,4)
--,dlng_amt
,sum(dlng_amt) over(partition by clnt_id) 위탁사합계
from wp01woab
where 1=1
and clnt_id ='003'
and stdd_ymd like '2016'||'%'
--group by clnt_id, substr(stdd_ymd,1,4)
;

select
clnt_id
,substr(stdd_ymd,1,8)
,dlng_amt
,sum(dlng_amt) over(partition by clnt_id) 위탁사합계
,sum(dlng_amt) over(partition by clnt_id, substr(stdd_ymd,1,8)) 위탁사별일자별합계
from wp01woab
where 1=1
and clnt_id ='003'
and stdd_ymd like '201611'||'%'
--group by clnt_id, substr(stdd_ymd,1,6)
;


/*연체건수 비교하기*/

SELECT
*
FROM
( SELECT
  CUST_ID
 ,COUNT(DECODE(RGST_CODE,'1',RGST_CODE)) AS ONE_CNT
 ,COUNT(DECODE(RGST_CODE,'4',RGST_CODE)) AS FOR_CNT
 FROM CM62EWSN
 WHERE USE_YN=' '
 AND TO_CHAR(INPT_DATE,'YYYYMMDD') LIKE '2016111%'
 GROUP BY CUST_ID
 )TT
WHERE TT.ONE_CNT >=1
AND TT.FOR_CNT >=1
 ;


SELECT
  CUST_ID
 ,COUNT(DECODE(RGST_CODE,'1',RGST_CODE)) AS ONE_CNT
 ,COUNT(DECODE(RGST_CODE,'4',RGST_CODE)) AS FOR_CNT
 FROM CM62EWSN
 WHERE USE_YN=' '
 AND TO_CHAR(INPT_DATE,'YYYYMMDD') LIKE '2016111%'
 AND CUST_ID='26502200222'
 GROUP BY CUST_ID
;

SELECT
  CUST_ID
 ,sum(decode(rgst_code,'1',1,'4',1,0)) over(partition by cust_id) as tot_cnt
 ,sum(decode(rgst_code,'1',1,0)) over(partition by cust_id) as one_cnt
 ,sum(decode(rgst_code,'4',1,0)) over(partition by cust_id) as for_cnt
 FROM CM62EWSN
 WHERE USE_YN=' '
 AND TO_CHAR(INPT_DATE,'YYYYMMDD') LIKE '2016111%'
 AND CUST_ID='26502200222'
;

/*
Syntax
	SELECT ANALYTIC_FUNCTION(arguments)
			OVER( [PARTITION BY 칼럼list]
				  [ORDER BY 칼럼list]
				  [WINDOWING 절 (Rows|Range Between)]
				)
	FROM 테이블 명;
-- ANALYTIC_FUNCTION: 분석함수명
-- OVER : 분석함수임을 나타내는 키워드
-- PARTITION BY : 계산 대상 그룹을 정한다.
-- ORDER BY : 대상 그룹에 대한 정렬을 수행한다.
-- WINDOWING 절 : 분석함수의 계산 대상 범위를 지정한다.
			ORDER BY 절에 종속적이다
			기본생략구문: 정렬된 결과의 처음부터 현재행까지
			[RANKGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
*/

/*
분석함수의 종류
-- 순위함수 : RANK, DENSE_RANK, ROW_NUMBER, NTILE
-- 집계함수 : SUM, MIN, MAX, AVG, COUNT
-- 기타함수 : LEAD, LAG, FIRST_VALUE, LAST_VALUE, RATIO_TO REPORT
*/


/*
1) 순위함수
-- RANK함수는 순위를 부여하는 함수로 동일순위 처리가 가능하다
	(중복 순위 다음 순서 건너뜀- 1,2,2,4)
-- DENSE_RANK 함수는 RANK함수와 같은 역할을 하지만 동일 등수가 순위에 영향이 없다
    (중복순위 없이 유일값- 1,2,2,3)
-- ROW_NUMBER 함수는 특정 순위로 일련번호를 제공하는 함수로 동일순위 처리가 불가능하다.
	(중복순위 없이 유일값- 1,2,3,4)
-- 순위 함수 사용시 ORDER BY 절은 필수로 입력해야한다.
-- WINDOWING 절은 사용 할 수 없다.
*/

WITH EMP AS (
SELECT '10' DEPTNO , '7839' EMPNO, 5000 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7788' EMPNO, 3000 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7902' EMPNO, 3000 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7566' EMPNO, 2975 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7698' EMPNO, 2850 SAL FROM DUAL
UNION ALL
SELECT '10' DEPTNO , '7782' EMPNO, 2450 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7499' EMPNO, 1600 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7844' EMPNO, 1500 SAL FROM DUAL
UNION ALL
SELECT '10' DEPTNO , '7934' EMPNO, 1300 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7521' EMPNO, 1250 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7654' EMPNO, 1250 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7876' EMPNO, 1100 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7900' EMPNO, 950 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7369' EMPNO, 800 SAL FROM DUAL
)

SELECT DEPTNO, EMPNO , SAL
,RANK() OVER (ORDER BY SAL DESC) AS RK
,DENSE_RANK() OVER(ORDER BY SAL DESC) AS DR
,ROW_NUMBER() OVER(ORDER BY SAL DESC) AS RW
,NTILE(2) OVER(ORDER BY EMPNO ASC) AS NT2
,NTILE(3) OVER(ORDER BY EMPNO ASC) AS NT3
,NTILE(4) OVER(ORDER BY EMPNO ASC) AS NT4
FROM EMP
ORDER BY EMPNO ASC
;

/*
NTILE 함수는 쿼리의 결과를 N개의 그룹으로 분류하는 기능을 제공
그룹요소가 14개인 테이블을 4개의 그룹으로 나눌때
14/4=3, MOD(14,4)=2 이므로 처음 그룹2개는 4개의 요소, 나머지그룹 2개는 3개의 요소로 구성한다

*/

/*
2) 집계함수  : SUM, MIN, MAX, AVG, COUNT등의 함수도 분석함수로 사용
분석함수 OVER절 안에서 ORDER BY절을 사용하면
ORDER BY 절의 칼럼을 기준으로 누적되어 계산된다
*/

WITH EMP AS (
SELECT '10' DEPTNO , '7839' EMPNO, 5000 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7788' EMPNO, 3000 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7902' EMPNO, 3000 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7566' EMPNO, 2975 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7698' EMPNO, 2850 SAL FROM DUAL
UNION ALL
SELECT '10' DEPTNO , '7782' EMPNO, 2450 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7499' EMPNO, 1600 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7844' EMPNO, 1500 SAL FROM DUAL
UNION ALL
SELECT '10' DEPTNO , '7934' EMPNO, 1300 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7521' EMPNO, 1250 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7654' EMPNO, 1250 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7876' EMPNO, 1100 SAL FROM DUAL
UNION ALL
SELECT '30' DEPTNO , '7900' EMPNO, 950 SAL FROM DUAL
UNION ALL
SELECT '20' DEPTNO , '7369' EMPNO, 800 SAL FROM DUAL
)

select  deptno, empno, sal
		,sum(sal) over() all_sum
		,sum(sal) over(partition by deptno) dept_sum
		,sum(sal) over(partition by deptno order by empno) accu_sum
from emp
order by deptno, empno
;

/*
3) 기타함수 : LEAD, LAG
-- SYNTAX : LAG(인자1, 인자2, 인자3) OVER(PARTITION BY 칼럼1, ORDER BY 칼럼2)
-- 인자1은 구분별 순위에따른 행에서 반환하고자 하는 값
-- 인자2는 지금 순위에 몇번째 앞선 순위인지, 생략시에 1
-- 인자3은 반환값이 null일시에 대체할 값, 생략시에 null

-- LAG는 현재 순위에 앞선 값을 반환, LEAD는 현재 순위 이후의 값을 반환
*/

WITH SAMPLE AS (
SELECT 10 S_COL, 14 E_COL FROM DUAL
UNION ALL
SELECT 15 S_COL, 11 E_COL FROM DUAL
UNION ALL
SELECT 16 S_COL, 21 E_COL FROM DUAL
UNION ALL
SELECT 17 S_COL, 22 E_COL FROM DUAL
UNION ALL
SELECT 17 S_COL, 23 E_COL FROM DUAL
UNION ALL
SELECT 18 S_COL, 30 E_COL FROM DUAL
UNION ALL
SELECT 20 S_COL, 35 E_COL FROM DUAL
)

SELECT S_COL, E_COL
		,LAG(S_COL) OVER(ORDER BY S_COL, E_COL)
		,LEAD(S_COL) OVER(ORDER BY S_COL, E_COL)
FROM SAMPLE
;

--10, 14, 0, 15
--15, 11, 10, 16
--16, 21, 15, 17
--17, 22, 16, 17
--17, 23, 17, 18
--18, 30, 17, 20
--20, 35, 18, 0
