/*
 <리스트 1>은 사용자 접속기록을 관리하는 테이블입니다. 사용자가 접속할 때 마다 기록이 되기 때문에 동일 사용자가 하루에 여러번 기록될 수 있습니다. 이 기록을 토대로 일별 접속 현황 통계자료를 작성해야 합니다. 접속일자 기준으로 다음 네 가지 통계를 한 화면에 보여줘야 합니다.
 1. 접속건수 : 접속 기록을 일별로 카운트합니다.
2. 접속자수 : 동일 유저는 한번만 카운트 합니다.
3. 누적접속건수 : 현재일자까지의 누적 건수입니다.
4. 누적접속자수 : 현재일자까지의 누적 접속자수입니다.

*/


create table imsi_tb_shy4
as select '20150801' dt, 1 id from dual
union all select '20150801', 2 from dual
union all select '20150801', 1 from dual
union all select '20150802', 1 from dual
union all select '20150802', 2 from dual
union all select '20150802', 2 from dual
union all select '20150803', 3 from dual
union all select '20150804', 4 from dual
union all select '20150804', 1 from dual
union all select '20150805', 1 from dual
;

select * from imsi_tb_shy4
;
select count(distinct dt||id) as cnt from imsi_tb_shy4

;

select dt ,count(*) from imsi_tb_shy4
group by dt
;

select dt, count(distinct id ) from imsi_tb_shy4
group by dt
;

select
dt, sum(cnt)
from
(select b.dt as dt ,a.dt as r_dt, a.cnt as cnt

from (select dt ,count(*) cnt
		from imsi_tb_shy4
		group by dt) a, imsi_tb_shy4 b
where  b.dt >= a.dt
group by b.dt, a.dt, a.cnt
) tt
group by tt.dt
;

select
dt, sum(cnt)
from
(select b.dt as dt ,a.dt as r_dt, a.cnt as cnt

from (select dt ,count(distinct id) cnt
		from imsi_tb_shy4
		group by dt) a, imsi_tb_shy4 b
where  b.dt >= a.dt
group by b.dt, a.dt, a.cnt
) tt
group by tt.dt
;

select tt.dt, sum(tt.cnt)
from
(select b.dt dt, a.dt r_dt, count(distinct a.id) cnt
from
(select min(dt) dt, id
from imsi_tb_shy4
group by  id )  a, (select distinct dt
					from imsi_tb_shy4) b
where  b.dt >= a.dt
group by b.dt, a.dt
) tt
group by tt.dt
;
/*
누적 통계                      
SELECT 
 COL1
,SUM(COUNT(*) OVER(ORDER BY COL1) 
FROM TABLE
GROUP BY COL1


*/
SELECT dt
, COUNT(*) 접속건수
, COUNT(DISTINCT id) 접속자수
, SUM(COUNT(*)) OVER(ORDER BY dt) 누적접속건수
, SUM(COUNT(x)) OVER(ORDER BY dt) 누적접속자수
FROM (SELECT dt, id
, DECODE(ROW_NUMBER() OVER(PARTITION BY id ORDER BY dt), 1, 1) x
FROM imsi_tb_shy4        )
GROUP BY dt ORDER BY dt;
;

/* 
rank() over 와 ROW_NUMBER() OVER 차이
RANK()는 동일한 비교값에 같은 순번을 매긴다
ROW_NUMBER()는 동일한 비교값에도 게코드가 다르므로 다른 순번을 매긴다

*/

SELECT dt, id
, DECODE(ROW_NUMBER() OVER(PARTITION BY id ORDER BY dt), 1, 1) x
FROM imsi_tb_shy4
;

SELECT dt, id
, DECODE(rank() OVER(PARTITION BY id ORDER BY dt), 1, 1) x
FROM imsi_tb_shy4
;

select
dt
,count(*)
,count(distinct id)

from
 (select  dt, id
,decode(rank() over (partition by id order by dt asc),1,1,0) rank
from imsi_tb_shy4
 )
 group by dt
