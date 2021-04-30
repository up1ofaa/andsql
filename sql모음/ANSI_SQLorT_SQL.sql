

/*
표준조인(standard join)
standard sql 개요
ANSI/ISO 표존 SQL에서 규정한
INNER JOIN , NATURAL JOIN, USING조건절, ON조건절
, CROSS JOIN ,OUTER JOIN 문법을 통해
사용자는 테이블간의  JOIN조건을 FROM 절에서 명시적으로 정의할수 있다
SQL - 관계형 데이터베이스를 유일하게 접속할수 있는 언어
*/
--STANDARD JOIN기능 추가(CROSS, OUTER JOIN등 새로운 FROM절 기능들)
--SCALAR SUBQUERY, TOP-N QUERY 등의 새로운 SUBSQUERY기능들
--ROLLUP, CUBE, CROUPING SETS 등의 새로운리포트기능
--WINDOW FUNCTION 같은 새로운 개념의 분석기능들
--1) UNION
--2) INTERSECT
--3) EXCEPT (ORACLE MINUS)
--4) PRODUCT(CROSS JOIN)


/*
SQL문

*/

--1) INNER JOIN
SELECT *
FROM IMSI_TB_SHY1 IMSI1 INNER JOIN IMSI_TB_SHY2 IMSI2 -- INNER 생략가능
ON IMSI1.COL1=IMSI2.COL1

;
--2) NATURAL JOIN
--두 테이블 간의 동일한 이름을 갖는 모든 칼럼들에 대해 EQUI(=)JOIN 수행
SELECT *
FROM IMSI_TB_SHY1 IMSI1 NATURAL JOIN IMSI_TB_SHY2 IMSI2
;

--3) USING 조건절
--FROM 절의  USING 조건절을 이용하면 같은 이름을 가진 칼럼들 주에서 원하는 칼럼에 대해서만
--선택적으로 EQUI JOIN을 할 수있다.
--USING 절 안에 포함되는 칼럼에 ALIAS를 지정하면 오류가 발생
SELECT *
FROM IMSI_TB_SHY1 IMSI1 JOIN IMSI_TB_SHY2 IMSI2 USING (COL1)
;
--4) ON 조건절
-- JOIN서술부(ON조건절)와 비 JOIN서술부(WHERE 조건절)을 분리하여
--,칼럼명 다르더라도 JOIN조건 사용할수 있음
SELECT *
FROM IMSI_TB_SHY1 IMSI1 JOIN IMSI_TB_SHY2 IMSI2
ON IMSI1.COL1=IMSI2.COL1
;

SELECT
 *
FROM LC10WOKA L1 JOIN LC10WOKC L3
ON L1.CUST_SSNO=L3.CUST_SSNO
WHERE L1.STDD_YMD LIKE '20190124'||'%'
;

--5) CROSS JOIN
-- 테이블 간 JOIN 조건이 없는 경우 생길 수 있는 모든 데이터의 조합
-- m 행 테이블 a, n행 테이블 b => a cross join b = m*n 행개의 테이블
-- x 열 테이블a, y열 테이블 b => a cross join b =x+y 열개의 테이블
select
*
from
(select '1'  col1, '2'  col2, '3' col3
 from dual) a
cross join
(select '4'  col4, '5'  col5, '6' col6, '7' col7
 from dual) b
;

select
*
from
(select '11'  col1, '21'  col2, '31' col3
 from dual
	union
 select '12'  col1, '22'  col2, '32' col3
 from dual
		) a
cross join
(select '41'  col1, '51'  col5, '61' col6, '71' col7
 from dual
	union
 select '42'  col1, '52'  col5, '62' col6, '72' col7
 from dual
 	union
 select '43'  col1, '53'  col5, '63' col6, '73' col7
 from dual
) b
;

--6) LEFT OUTER JOIN
select
*
from
(select '11'  col1, '21'  col2, '31' col3
 from dual
	union
 select '12'  col1, '22'  col2, '32' col3
 from dual
		) a
left outer join
(select '11'  col1, '51'  col5, '61' col6, '71' col7
 from dual
	union
 select '22'  col1, '52'  col5, '62' col6, '72' col7
 from dual
 	union
 select '43'  col1, '53'  col5, '63' col6, '73' col7
 from dual
) b
on a.col1=b.col1
;

select
*
from
(select '11'  col1, '21'  col2, '31' col3
 from dual
	union
 select '12'  col1, '22'  col2, '32' col3
 from dual
		) a
right outer join
(select '11'  col1, '51'  col5, '61' col6, '71' col7
 from dual
	union
 select '12'  col1, '52'  col5, '62' col6, '72' col7
 from dual
 	union
 select '43'  col1, '53'  col5, '63' col6, '73' col7
 from dual
) b
on a.col1=b.col1
;

select
*
from
(select '11'  col1, '21'  col2, '31' col3
 from dual
	union
 select '12'  col1, '22'  col2, '32' col3
 from dual
		) a
full outer join
(select '11'  col1, '51'  col5, '61' col6, '71' col7
 from dual
	union
 select '22'  col1, '52'  col5, '62' col6, '72' col7
 from dual
 	union
 select '43'  col1, '53'  col5, '63' col6, '73' col7
 from dual
) b
on a.col1=b.col1
;


-- 다음중 결과값이 다른 쿼리는?   답은 1번, T1 기준으로 모든 조건이 OUTER
WITH T1  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL UNION ALL
SELECT '4' id,'40' col1,'400' col2 FROM DUAL UNION ALL
SELECT '5' id,'50' col1,'500' col2 FROM DUAL
)
, T2  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL
)

/*-- 1번쿼리 */
SELECT *
  FROM T1 a LEFT OUTER JOIN T2 b
    ON a.id = b.id
   AND a.id IN (1,2)
   AND b.col1 = 10
   ;

-----------------------------
WITH T1  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL UNION ALL
SELECT '4' id,'40' col1,'400' col2 FROM DUAL UNION ALL
SELECT '5' id,'50' col1,'500' col2 FROM DUAL
)
, T2  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL
)

/*-- 2번쿼리*/
SELECT *
  FROM T1 a LEFT OUTER JOIN T2 b
    ON a.id = b.id
  WHERE a.id IN (1,2)
    AND b.col1 = 10
    ;
-----------------------------
WITH T1  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL UNION ALL
SELECT '4' id,'40' col1,'400' col2 FROM DUAL UNION ALL
SELECT '5' id,'50' col1,'500' col2 FROM DUAL
)
, T2  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL
)

/*-- 3번쿼리*/
SELECT *
  FROM T1 a LEFT OUTER JOIN T2 b
    ON a.id = b.id
   AND a.id IN (1,2)
 WHERE b.col1 = 10
 ;
-----------------------------
WITH T1  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL UNION ALL
SELECT '4' id,'40' col1,'400' col2 FROM DUAL UNION ALL
SELECT '5' id,'50' col1,'500' col2 FROM DUAL
)
, T2  AS (
SELECT '1' id,'10' col1,'100' col2 FROM DUAL UNION ALL
SELECT '2' id,'20' col1,'200' col2 FROM DUAL UNION ALL
SELECT '3' id,'30' col1,'300' col2 FROM DUAL
)

/*-- 4번 쿼리  */
SELECT  *
  FROM T1 a , T2 b
WHERE a.id = b.id(+)
  AND a.id in (1,2)
  AND b.col1 = 10
  ;
