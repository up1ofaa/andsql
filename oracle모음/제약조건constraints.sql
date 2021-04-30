/*

create table emp708
empno number(20),
ename varchar2(40),
sal number(20)
         

*/
-- 테이블 생성할 권한이 없음
-- ora-01031: insufficient privileges
-- allen 유저에게 테이블 생성권한이 없다는 에러
-- error at line 1:       
-- ora-01950:no privileges on tablespace 'SYSTEM'
-- grant create table to allen;
-- ora-01950: no prrivileges on tablespace 'SYSTEM'
-- grant unlimites tablespace to allen    

/*
jack

create user jack indentifiedby tiger;
grant create session to jack;
grant createtable t jack;
grant unlimited tablespace to jack;

create table emp700(
	deptno number(10),
	enmae varchar2(20),
	sal number(10)
);	

*/

/*
create table emp507(
	empno number(10),
	ename varchar2(10),
	sal number(10),
	hiredate date
);
*/