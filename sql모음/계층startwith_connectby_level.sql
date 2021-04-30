/*임시테이블 반들기, 임시테이블 이후 바로 테이블을 사용하는 쿼리가 나와야함*/
with tt as
( select '7369' empno, 'smith' ename, '7902' mgr, 'employee' job   from dual
  union all
 select '7566' empno, 'jones' ename, '7839' mgr, 'employee' job   from dual
  union all
 select '7788' empno, 'scott' ename, '7566' mgr, 'employee' job   from dual
  union all
 select '7902' empno, 'ford' ename, '7566' mgr , 'employee' job  from dual
  union all
 select '7876' empno, 'adams' ename, '7788' mgr, 'employee' job  from dual
  union all
 select '7839' empno, 'king' ename, '' mgr , 'president' job from dual
 )

/*
syntax :  top down 구조
select level, col1, col2, col3...
from table
where 조건
start with col1='1'  -최상위노드값을 나타내는 조건
connect by prior 하위칼럼=상위칼럼

실행순서
start with => connect by => where

SYS_CONNECT_BY_PATH
계층구조 쿼리에서 현재 로우까지의 PATH정보를 쉽게 얻어 올 수 있다.

*/

-- select level,empno, ename, mgr  , SYS_CONNECT_BY_PATH(ename,'/') "PATH"
-- from tt
-- where job='employee'
-- start with job='president'
-- -- start with ename='jones'
-- connect by prior empno=mgr   --top down 구조일경우 prior 하위=상위
---- order siblings by ename
-- ;


/*
syntax :  bottom up 구조
select level, col1, col2, col3...
from table
where 조건
start with col1='1'  -최하위노드값을 나타내는 조건
connect by prior 상위칼럼=하위칼럼

*/


 select level, empno, ename, mgr
,connect_by_root empno "root empno"   --connect_by_root :계층구조 쿼리에서 level이 0인 최상위 로우정보를 얻어옴
,connect_by_isleaf "leaf" --connect_by_isleaf : 계층구조 쿼리에서 로우의 최하위 레벨 여부를 반환한다.
						  --최하위 레벨이면 1, 아니면 0
,sys_connect_by_path(ename, '/') "path" --계층구조 쿼리에서 현재 로우까지의 path정보를 쉽게 얻어옴
 from tt
 start with ename='smith'
 connect by prior mgr=empno   --buttom up 구조일경우 prior 상위=하위
-- order by ename ;
 order siblings by ename
 ;

 --level : 계층구조 쿼리에서 수행결과의 Depth를 표현하는 칼럼 (계층순위)
 --order siblings by : 계층구조 쿼리에서 편하게 정렬작업 가능
 --계층형쿼리 실행순서 : 1) start with 2) connect by  3)where
 --prior 연산자 : 상위행의 컬람임을 나타낸다. connect by 절에서 상하위간의 관계를 기술할때 사용
 --connect_by_root :계층구조 쿼리에서 level이 0인 최상위 로우정보를 얻어옴
 --connect_by_isleaf : 계층구조 쿼리에서 로우의 최하위 레벨 여부를 반환한다.
 --						최하위 레벨이면 1, 아니면 0
 --sys_connect_by_path : 계층구조 쿼리에서 현재 로우까지의 path정보를 쉽게 얻어옴
/*

문제1 )  lv에따른 sal누계 , lv 높을수록(낮은숫자) 하위레벨까지 누계
		sum_sal 항목으로 산출할것

empno	lv	ename	sal		mgno     acuu_sum
7839	1	king	5000             5000+2975+3000+1100+3000+800
7566	2	jones	2975	7839     2975+3000+1100+3000+800
7788	3	scott	3000	7566	 3000+1100
7876	4	adams	1100	7788     1100
7902	3	ford	3000	7566	 3000+800
7369	4	smith	800		7902     800
*/

with  tt as (
select '7839' empno, 'king'  ename, 5000 sal, '' mgno from dual
union
select '7566' empno, 'jones' ename, 2975 sal, '7839' mgno from dual
union
select '7788' empno, 'scott' ename, 3000 sal, '7566' mgno from dual
union
select '7876' empno, 'adams' ename, 1100 sal, '7788' mgno from dual
union
select '7902' empno, 'ford'  ename, 3000 sal, '7566' mgno from dual
union
select '7369' empno, 'smith' ename,  800 sal, '7902' mgno from dual
)

select
b.*
,(select sum(case when a.sum_sal like '%'||b.ename||'%'
			 then nvl(a.sal,0) else 0 end)
	from
	(select empno , level lv , ename , sal, mgno
		,connect_by_root ename root_nm
		,connect_by_isleaf leaf
		,sys_connect_by_path(ename,',') sum_sal
		from tt
		start with ename ='king'
		connect by prior empno=mgno
	) a
	) accu_sum
from
(select empno, level lv, ename, sal, mgno
	from tt
	start with ename='king'
	connect by prior empno=mgno
) b
where 1=1
;

select a.empno
	  ,level lv
	  ,a.ename
	  ,a.sal
	  ,a.mgno
	  ,(select sum(b.sal)
	  		from tt b
	  		start with b.ename=a.ename
	  		connect by prior b.empno=b.mgno
	  ) acc_sum
from tt a
start with ename='king'
connect by prior empno=mgno

;

/*
문제2 )
CONNECT BY LEVEL을 이용한 테스트 샘플데이터 ,
rownum 계층 번호 부터하는 항목
1
2
3
4
5
6
7
8
9
10
*/

SELECT LEVEL
FROM DUAL
CONNECT BY LEVEL <=10
;

with emp_sample as
(select
	level empno
	,'salesman_'||chr(65+mod((level+9),10)) job
	,sysdate+mod((level+9),10) hiredate
	,mod((level+4),5)*10+10 deptno
from dual
connect by level <100
)
select *
from emp_sample
;
/*
문제3)
경우의 수 만들기
A, B, C => A, B, C, AB, AC, ABC, BC

*/
with pp as
( select 'a' ob from dual
union
  select 'b' ob from dual
union
  select 'c' ob from dual
)

select
level
,sys_connect_by_path(ob,'-')
,substr(sys_connect_by_path(ob,'-'),2) code
from pp
connect by prior ob < ob
order by level, ob
;
--기본적으로 레벨은 행의 갯수만큼 만들어짐
-- 부등호 조건(prior 칼럼1 < 칼럼1)을 이용한 계층 전개
-- 계층전개 조건이 반드시 이퀄(=)조건일 필요는 없다. 이퀄일경우 무한루프발생(에러)

/*
 문제4) 순서까지 고려한 모든 경우의 수
 --부등호(!=) 사용시 순환구조 발생(예: A-B-C-A-...)
 --NOCYCLE 사용으로 에러 방지(예: A-B-C(여기까지만))

*/

with pp as
( select 'a' ob from dual
union
  select 'b' ob from dual
union
  select 'c' ob from dual
)

select substr(sys_connect_by_path(ob,'-'),2) code
from pp
connect by nocycle prior ob!=ob
order by level, code
;
