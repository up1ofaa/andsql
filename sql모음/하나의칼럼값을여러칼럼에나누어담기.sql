/*primary_key
unique and not null

ex ) drop table emp05;
create table emp05(empno number(4) constraint emp05_empno_pk  primary key,
ename varchar2(10) constraint emp05_ename_nn not null, job varchar(9), deptno number(2));

75개의 상품이 있는데, 현재는 한개의 칼럼에 75개의 상품이 쭉나열
=>
1번 칼럼에 25개
2번 칼럼에 25개
3번 칼럼에 25개
.
.
.
이런식으로 채워야할텐데
*/


select
*
from imsi_tb_shy1
;

select
 max(onecol), max(twocol), max(thrcol), max(forcol)
from (	select mod(rownum,25) gp
				,decode(mod(rownum,4),1,col1) onecol      -- rownum이 4로 나누어서 나머지 1인값을 1칼람에
				,decode(mod(rownum,4),2,col1) twocol
				,decode(mod(rownum,4),3,col1) thrcol
				,decode(mod(rownum,4),0,col1) forcol
			from imsi_tb_shy1
)
group by gp
;   





