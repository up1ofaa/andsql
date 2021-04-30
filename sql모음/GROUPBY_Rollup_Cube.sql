/*
Rollup : 단계별 소계
Cube : 모든 경우의 수에 대한 소계
*/

-- group by만 사용할경우
select
ca02.wkot_step
,count(*)
from ca02reln ca02, ca01bond ca01
where 1=1
and ca02.wkot_step is not null
and ca01.clnt_id='001'
and ca01.end_divi='00'
and ca02.clnt_id=ca01.clnt_id
and ca02.cont_no=ca01.bond_seq
and ca02.bond_seq=ca01.bond_seq
and ca02.use_yn=' '
and ca01.use_yn=' '
group by ca02.wkot_step
;
--rollup사용한경우와 사용하지 않은 경우 비교
select
 aa.team_code
,aa.rollup_count
,bb.count
from
(select
ca01.team_code
,count(*) as rollup_count
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
group by rollup(ca01.team_code)
) aa
,(select
ca01.team_code
,count(*)   as count
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
group by ca01.team_code
) bb
where aa.team_code=bb.team_code(+)
;

--rollup 이용한 소계를 더 세분화하여 표현
select
  substr(ca01.team_code,0,1) as sub_team
 ,ca01.team_code
,count(*) as rollup_count
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
group by rollup(substr(ca01.team_code,0,1),ca01.team_code)
;

--rollup 내의 칼럼순서 중요 (큰구분별로 구분하지 않으면 소계를 구하기 어려움)
select
 ca01.team_code
 ,substr(ca01.team_code,0,1) as sub_team
,count(*) as rollup_count
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
group by rollup(ca01.team_code, substr(ca01.team_code,0,1))
;

/*
GROUPING 과 GROUPING_ID
GROUPING(칼럼)
--GROUPING 함수는 ROLLUP, CUBE에 모두 사용할 수 있다.
--GROUPING 함수는 해당 컬럼의 ROW가
  GROUP BY에 의해서 산출된 ROW인 경우에는 0을 반환하고
  ROLLUP이나 CUBE에 의해서 산출된 ROW인 경우에는 1을 반환하게 된다.
--따라서 해당 ROW가 결과집합에 의해 산출된 DATA인지
  ROLLUP이나 CUBE에 의해서 산출된 DATA인지를 알수 있도록 지원하는 함수이다.
*/

select
  substr(ca01.team_code,0,1) as sub_team
 ,ca01.team_code
 ,count(*) as rollup_count
 -- group by시 sub_team이 값이 있으면 0, 없으면 1
 ,grouping(substr(ca01.team_code,0,1)) gp_1
 -- group by시 team_code 값이 있으면 0, 없으면 1
 ,grouping(ca01.team_code)	gp_2
 -- grouping_id(칼럼1, 칼럼2) : grouping(칼럼1)||grouping(칼럼2) 의 2진수 값을 10진수로 변환
 -- ex) 11(2) => 3(10)
 ,grouping_id(substr(ca01.team_code,0,1),ca01.team_code) gp_3
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
group by rollup(substr(ca01.team_code,0,1),ca01.team_code)
;

select
  decode(grouping_id(substr(ca01.team_code,0,1), ca01.team_code),3
       ,'합계'
      ,substr(ca01.team_code,0,1))  as sub_team
 ,decode(grouping(ca01.team_code),1,'소계',ca01.team_code) as team_code
 ,count(*) as rollup_count
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
group by rollup(substr(ca01.team_code,0,1),ca01.team_code)
;

-- rollup하고 cube 비교하기
-- rollup 사용시 위탁사별 소계만 나옴
 	 select
	 ca01.clnt_id as 위탁사
	,ca01.team_code   as 팀
	,count(*) as rollup_count
	from ca01bond ca01
	where ca01.use_yn=' '
	and ca01.end_divi='00'
	and ca01.clnt_id in('001','002','003')
	group by rollup(ca01.clnt_id,ca01.team_code)
	;
-- cube 사용시 위탁사별, 팀별 소계가 각각 나옴
	 select
	 ca01.clnt_id as 위탁사
	,ca01.team_code   as 팀
	,count(*) as rollup_count
	from ca01bond ca01
	where ca01.use_yn=' '
	and ca01.end_divi='00'
	and ca01.clnt_id in('001','002','003')
	group by cube(ca01.clnt_id,ca01.team_code)
	order by ca01.clnt_id
	;
-- cube와 grouping 함께사용
 select
	decode(grouping_id(ca01.clnt_id, ca01.team_code),3,'합계'
	,decode(grouping(ca01.clnt_id),1,'소계_'||ca01.team_code, ca01.clnt_id)) as 위탁사
	,decode(grouping_id(ca01.clnt_id, ca01.team_code),3,''
	,decode(grouping(ca01.team_code),1,'소계_'||ca01.clnt_id,ca01.team_code))   as 팀
	,count(*) as rollup_count
	from ca01bond ca01
	where ca01.use_yn=' '
	and ca01.end_divi='00'
	and ca01.clnt_id in('001','002','003')
	group by cube(ca01.clnt_id,ca01.team_code)
	order by ca01.clnt_id
	;

/*
GROUPING SETS
-- GROUPING SETS함수는 GROUP BY의 확장된 형태로 하나의 GROUP BY절에 여러개의 그룹 조건을 기술할 수 있다.
-- GROUPING SETS 함수의 결과는 각 그룹 조건에 대해 별도로 GROUP BY한 결과를 UNION ALL한 결과와 동일하다.
*/

select ca01.clnt_id, null team_code, count(*)
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
and ca01.clnt_id in ('001','002','003')
group by ca01.clnt_id

union all

select null clnt_id, ca01.team_code, count(*)
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
and ca01.clnt_id in ('001','002','003')
group by ca01.team_code
;


select  ca01.clnt_id, ca01.team_code, count(*)
from ca01bond ca01
where ca01.use_yn=' '
and ca01.end_divi='00'
and ca01.clnt_id in ('001','002','003')
group by grouping sets(ca01.clnt_id, ca01.team_code)
;

-- exercise
with top as (
select '11' divi, '01' kind, 1 val from dual
union all
select '11' divi, '02' kind, 2 val from dual
union all
select '11' divi, '01' kind, 3 val from dual
union all
select '22' divi, '02' kind, 4 val from dual
union all
select '22' divi, '01' kind, 5 val from dual
union all
select '22' divi, '02' kind, 6 val from dual
union all
select '33' divi, '01' kind, 7 val from dual
union all
select '33' divi, '02' kind, 8 val from dual
union all
select '33' divi, null kind, 9 val from dual
union all
select '44' divi, '01' kind, 12 val from dual
union all
select '44' divi, null kind, 13 val from dual
)

select *
from top
;

select divi, kind, sum(val)
from top
group by divi, kind
;

select divi, kind, sum(val)
from top
group by rollup(divi,kind)
;

select divi, kind, sum(val)
from top
group by divi, rollup(kind)
;


select  divi, sum(val)
from top
group by  rollup(divi)
;

select divi, kind
,grouping(divi)
,grouping(kind)
,grouping_id(divi, kind)
,sum(val)
from top
group by rollup(divi,kind)
;

select divi, kind
,grouping(divi)
,grouping(kind)
,grouping_id(divi, kind)
,sum(val)
from top
group by cube(divi,kind)
;


select
decode(grouping_id(divi, kind),3,'합계'
		,decode(grouping(divi),1,'소계_'||kind||'_kind',divi)) divi
,decode(grouping_id(divi, kind),3,''
		,decode(grouping(kind),1,'소계_'||divi||'_divi',kind)) kind
,sum(val)
from top
group by cube(divi,kind)
;

select divi, kind, sum(val)
from top
group by grouping sets(divi, kind)
;

select decode(grouping(divi),1,'소계', divi) divi
, decode(grouping(kind),1,'소계',kind)   kind
, sum(val)
from top
group by grouping sets(divi, kind)
;
