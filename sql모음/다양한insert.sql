/*
where절
with check option
col3 입력하는데 '박정순'만 입력할수 있도록, 그외에는 에러

*/
--insert into (select col1, col2, col3
--			 from imsi_tb_shy1
--			 where col3 = '박정순' with check option
--			 )
--		values ('&case_no'
--				,'&loan_no'
--				,'&cust_name')

;
/*
where절
with check option
col3 입력하는데 0~9000 사이의 데이터만 입력가능
*/
--insert into (select col1, col2, col3
--			 from imsi_tb_shy1
--			 where col3 between 0 and 9000 with check option
--			 )
--	   values('&case_no'
--	   		, '&loan_no'
--	   		, '&cust_name')
--;


select
*
from imsi_tb_shy1
;

/*
imsi_tb_shy1테이블과 똑같은 구조를 갖는 테이블 생성

create table imsi_tb_shy12
	select *
		from imsi_tb_shy1
		where col3='박정순';
*/

/*

insert into imsi_tb_shy12(col1, col2, col3)
	select col1, col2, col3 from imsi_tb_shy1 where col3='박정순' ;
*/
  

/*
insert ALL
	WHEN col3 >= 50000 then
		into imsi_tb_shy2(col1, col2, col3)
		values( col1, col2, col3)
	WHEN col3 < 50000 then 
	    into imsi_tb_shy3(col1, col2, col3)
	    values( col1, col2, col3)	
select *
	from (select col1, col2, col3, col3*0.4, col3*0.1,
				avg(col3) over (partition by col1)
		  from imsi_tb_shy1) 
;		   		 		


*/


/*   

보정필요
insert all
	into imsi_tb_shy2 values(col1, col2, cm)
	into imsi_tb_shy2 values(col1, col2, mm)
	into imsi_tb_shy2 values(col1, col2, nm)
select col1, col2, col3, col3*0.1 cm, col3*0.01 mm, col3*0.05 nm
from imsi_tb_shy1
;	


*/