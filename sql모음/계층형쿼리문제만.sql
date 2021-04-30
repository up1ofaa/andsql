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


/*
문제3)
경우의 수 만들기
A, B, C => A, B, C, AB, AC, ABC, BC

*/



--기본적으로 레벨은 행의 갯수만큼 만들어짐
-- 부등호 조건(prior 칼럼1 < 칼럼1)을 이용한 계층 전개
-- 계층전개 조건이 반드시 이퀄(=)조건일 필요는 없다. 이퀄일경우 무한루프발생(에러)

/*
 문제4) 순서까지 고려한 모든 경우의 수
 --부등호(!=) 사용시 순환구조 발생(예: A-B-C-A-...)
 --NOCYCLE 사용으로 에러 방지(예: A-B-C(여기까지만))

*/