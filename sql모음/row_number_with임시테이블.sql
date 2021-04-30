with tt as
(select '15' op from dual
  union all
 select '15' op from dual
  union all
 select '15' op from dual
  union all
 select '10' op from dual
  union all
 select '10' op from dual
  union all
 select '7' op from dual
  union all
 select '32' op from dual
  union all
 select '7' op from dual
  union all
 select '4' op from dual
 )

--select row_number() over(order by to_number(op) desc) rn, op from tt;

select rank() over(order by to_number(op) desc) rn, op from tt;

/*
row_number over() 와 rank over()
차이점
: rank() over는 같은 등수의 다른 레코드에 동일한 등수로 매기지만
  row_number() over는 같은 등수라도 다른레코드에 다른 수번을 매긴다
*/
/*
with 절 부분은 oracle temporary tablespace( 임시테이블스페이스 영역)에
테이블명 job_maxsal로 임시저장
with절의 장점: 두번 이상 반복되고 있는 쿼리가 있는 sql의 성능을 높일 수 있음
*/
/*
with절을 이용한 튜닝
with job_maxsal as
(  	select job, max(sal) 최대값
	from emp
	group by job
)
select job, 최대값
from job_maxsal
where 최대값 > (select avg(최대값)
				from job_maxsal)
;					

*/        

with imsi_tb_shy15 as
( select   su02.clnt_id
		  ,su02.cont_no
		  ,su02.bond_seq
		  ,su02.dlng_ymd
		  ,su02.get_type
		  ,rank() over(partition by su02.clnt_id, su02.cont_no, su02.bond_seq
		  				order by decode(get_type,'02',1,'01',2,3) asc, su02.dlng_ymd desc, su02.clnt_txid asc) get_rank
	from su02resu su02, m_st01base@anddw_link st01
	where su02.use_yn=' '
--	and su02.recv_ymd between '20170101' and '20170630'
	and st01.stdd_yymm='201701'
	and su02.clnt_id=st01.clnt_id
	and su02.cont_no=st01.cont_no
	and su02.bond_seq=st01.bond_seq
	and su02.clnt_id in ('002')
	and st01.mort_kind='30'
)
select st01.clnt_id
	   ,st01.cont_no
	   ,st01.bond_seq
	   ,a.get_type
       ,sum(su02.get_pamt)
       ,sum(su02.get_int)
from imsi_tb_shy15 a
,m_st01base@anddw_link st01
,su02resu su02
where st01.stdd_yymm='201701'
and st01.clnt_id in ('002')
and st01.mort_kind='30'
and st01.clnt_id=su02.clnt_id
and st01.cont_no=su02.cont_no
and st01.bond_Seq=su02.bond_Seq
and st01.clnt_id=a.clnt_id(+)
and st01.cont_no=a.cont_no(+)
and st01.bond_seq=a.bond_seq(+)
and a.get_rank(+)=1
group by st01.clnt_id, st01.cont_no, st01.bond_seq , a.get_type
;

/*
문제1 :
select d.loc, sum(e.sal)
from emp e, dept d
where e.deptno=d.deptno
group by d.loc having sum(e.sal) > (select avg(sum(e.sal))*0.2
									from emp e, dept d
									where e.deptno =d.deptno
									group by d.loc
								);
답 1:
with imsi_tb_shyxx as
(select avg(sum(e.sal))*0.2  as col
			from emp e, dept d
			where e.deptno=d.deptno
			group by d.loc
)
select d.loc, sum(e.sal)
from emp e, dept d
where e.deptno=d.deptno
group by d.loc having sum(e.sal) > (select col from imsi_tb_shyxx)
;		

효율답1 :  
with imsi_tb_shyxx as
(select d.loc, sum(e.sal) as total
 from emp e, dept d
 where e.deptno=d.deptno
 group by d.loc )
 select a.loc, a.total
 from imsi_tb_shyxx a
 where a.total > (select avg(totla)* 0.2 from imsi_tb_shyxx)
 ; 

문제2 ;
직업, 직업별 인원수를 출력하는데 직업별 인원수의 평균값보다 더 큰것만 출력
with job_tb as 
(select
job, count(*) cnt
from emp
group by job)
select
job, cnt
from job_tb
where cnt > (select avg(cnt) from job_tb)
;


*/