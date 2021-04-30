/*
윈도우 함수란
	- 분석함수 중에서 윈도우절(WINDOWING절)을 사용하는 함수를 윈도우함수라고 한다.
	- 윈도우절을 사용하면 PARTITION BY절에 명시된 구룹을 좀 더 세부적으로 그룹핑 할 수 있다.
	- 윈도우절은 분석함수중에서 일부(AVG, COUNT, SUM, MAX, MIN)만 사용 할 수 있다.
*/

/*
윈도우절 Syntax
	윈도우 함수 OVER(
					PARTITION BY절
					ORDER BY절 [ASC|DESC]
					ROWS|RANGE
					BETWEEN UNBOUNDED PRECEDING | n PRECEDING | CURRENT ROW
						AND UNBOUNDED FOLLOWING | n FOLLOWING | CURRENT ROW
					)
*/
--ROWS: 물리적인 ROW단위로 행집합을 지정한다.
--RANGE: 논리적인 상대번지로 행집합을 지정한다.
--BETWEEN ~ AND 절: 윈도우의 시작과 끝 위치를 지정한다.
--UNBOUNDED PRECEDING : PARTITION의 첫 번째 로우에서 윈도우가 시작한다.
--UNBOUNDED FOLLOWING : PARTITION의 마지막 로우에서 윈도우가 시작한다.
--CURRENT ROW: 윈도우의 시작이나 끝 위치가 현재 로우이다.

WITH EMP AS (
SELECT '7782' EMPNO, 'clark' ENAME, '10' DEPTNO, 2450 SAL FROM DUAL
UNION ALL
SELECT '7839' EMPNO, 'king' ENAME, '10' DEPTNO, 5000 SAL FROM DUAL
UNION ALL
SELECT '7934' EMPNO, 'miller' ENAME, '10' DEPTNO, 1300 SAL FROM DUAL
UNION ALL
SELECT '7369' EMPNO, 'smith' ENAME, '20' DEPTNO, 800 SAL FROM DUAL
UNION ALL
SELECT '7566' EMPNO, 'jones' ENAME, '20' DEPTNO, 2975 SAL FROM DUAL
UNION ALL
SELECT '7788' EMPNO, 'scott' ENAME, '20' DEPTNO, 3000 SAL FROM DUAL
UNION ALL
SELECT '7876' EMPNO, 'adams' ENAME, '20' DEPTNO, 1100 SAL FROM DUAL
UNION ALL
SELECT '7902' EMPNO, 'ford' ENAME, '20' DEPTNO, 3000 SAL FROM DUAL
UNION ALL
SELECT '7499' EMPNO, 'allen' ENAME, '30' DEPTNO, 1600 SAL FROM DUAL
UNION ALL
SELECT '7521' EMPNO, 'ward' ENAME, '30' DEPTNO, 1250 SAL FROM DUAL
UNION ALL
SELECT '7654' EMPNO, 'martin' ENAME, '30' DEPTNO, 1250 SAL FROM DUAL
UNION ALL
SELECT '7698' EMPNO, 'blake' ENAME, '30' DEPTNO, 2850 SAL FROM DUAL
UNION ALL
SELECT '7844' EMPNO, 'turner' ENAME, '30' DEPTNO, 1500 SAL FROM DUAL
UNION ALL
SELECT '7900' EMPNO, 'james' ENAME, '30' DEPTNO, 900 SAL FROM DUAL
)

select empno, ename, deptno, sal
,sum(sal) over(partition by deptno       -- 부서별
				order by empno           -- 사원번호순
				rows 1 preceding) pre_sum -- 이전 급여와 row(rows 1 preceding) 현재 row의 합계를 출력하는 예제
,sum(sal) over(order by deptno, empno
				rows between unbounded preceding
						and	 unbounded following) sal1
,sum(sal) over(order by deptno, empno
				rows between unbounded preceding
						 and unbounded following) sal2
,sum(sal) over(order by deptno, empno
				rows between current row
				and unbounded following) sal3
from emp
;

/*
RANGE 사용예제
월별 금액릭스트를 출력하고 , 직전 3개월 합계(AMT_PRE3)와
이후 3개월 합계(AMT_FOL3)를 함께 표시하는 예제이다.
*/
WITH test AS(
SELECT '200801' yyyymm, 100 amt FROM dual
UNION ALL
SELECT '200802', 200 FROM dual
UNION ALL
SELECT '200803', 300 FROM dual
UNION ALL
SELECT '200804', 400 FROM dual
UNION ALL
SELECT '200805', 500 FROM dual
UNION ALL
SELECT '200806', 600 FROM dual
UNION ALL
SELECT '200808', 800 FROM dual
UNION ALL
SELECT '200809', 900 FROM dual
UNION ALL
SELECT '200810', 100 FROM dual
UNION ALL
SELECT '200811', 200 FROM dual
UNION ALL
SELECT '200812', 300 FROM dual)

SELECT yyyymm
		,amt
		,sum(amt) over(order by to_date(yyyymm,'yyyymm')
				  range between interval '3' month preceding
				  			and interval '1' month preceding) amt_pre3    -- 직전 3개월 합계
		,sum(amt) over(order by to_date(yyyymm,'yyyymm')
				  range between interval '1' month following
				  			and interval '3' month following) amt_fol3    -- 이후 3개월 합계
FROM test ;
