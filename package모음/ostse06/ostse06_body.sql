CREATE OR REPLACE PACKAGE BODY OPARSE.OSTSE06
--------------------------------------------------------------------------------
-- package 기능 : 매출현황(탭1) 일보 조회 
-- 작성일자     : (2021.03.18)
-- 작성자       : 성화연
--------------------------------------------------------------------------------
-- 수정일자     :
-- 수정자       :
-- 수정내용     :
--------------------------------------------------------------------------------

IS

--------------------------------------------------------------------
-- 매출현황(탭1) 일보 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s001  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , day_list              OUT     rtn_rctype

       , p_stdd_ymd            IN      VARCHAR2
       , p_befo_term_divi      IN      VARCHAR2
    )
    IS

    v_ymd           varchar2(8); 
    v_befo_ymd      varchar2(8);          
    v_dd            varchar2(6);    
    v_befo_yymm     varchar2(6);
    v_befo_yymm3    varchar2(6);
    v_befo_yymm6    varchar2(6);

    BEGIN
    
    select
         (select max(stdd_ymd)
            from oparse.cm09cald
            where stdd_ymd <= a.stdd_ymd
            and hday_yn='N' )  ymd
        ,(select max(stdd_ymd)
            from oparse.cm09cald
            where stdd_ymd < (select max(stdd_ymd)
                                from oparse.cm09cald
                                where stdd_ymd <= a.stdd_ymd
                                and hday_yn='N' )
            and hday_yn='N'

                )             befo_ymd       
    into
         v_ymd
        ,v_befo_ymd
    from (select p_stdd_ymd stdd_ymd
            from dual
        ) a
     ;  
    
    select   (select clog_dd
                from anddw.d_ad02clog@anddw_link
                where clog_ymd =v_ymd
                and rownum =1 )
             ,to_char(add_months(to_date( v_ymd,'yyyymmdd'),-1),'yyyymm')
             ,to_char(add_months(to_date( v_ymd,'yyyymmdd'),-3),'yyyymm')       
             ,to_char(add_months(to_date( v_ymd,'yyyymmdd'),-6),'yyyymm')     
    into v_dd
        ,v_befo_yymm
        ,v_befo_yymm3
        ,v_befo_yymm6
    from dual;    
        
    
        OPEN day_list  FOR
        select  rownum                                                    as rowno          --순번
                ,nvl(v_ymd,'' )                                           as clog_ymd       --기준일자
                ,nvl(v_dd,'')                                             as clog_dd        --기준일
                ,tt.hdqt_code                                             as hdqt_code      --본부코드
                ,decode(tt.hdqt_code ,'2000','고객사업본부','8000','채권사업본부'
                        ,'5000','전략사업본부','9000','SA사업본부'
                        ,'8002','공공사업부','1000','경영지원팀' )        as hdqt_name      --본부명  
                ,nvl(tt.dept_code,'9999')                                 as dept_code      --부서코드
                ,case when tt.dept_code is null then '소계'
                      when tt.dept_code='1010' then '경영지원팀'
                      else oparse.COMM_FUNC.F_GET_TEAM_NAME('1',tt.dept_code)   
                      end                                                 as dept_name      --부서명
                ,round(tt.mang_plan,0)                                    as mang_plan      --목표
                ,round(tt.prre_clog,0)                                    as prre_clog      --실적
                ,round(tt.befo_month_gap,0)                               as befo_month_gap --전월비
                ,round(tt.befo_day_gap,0)                                 as befo_day_gap   --전일비
                ,case when tt.mang_plan =0 then ''
                      else to_char(round(nvl(tt.prre_clog/tt.mang_plan *100,0),1)) end   as prre_Rate      --달성율(%)
                ,case when tt.hdqt_code='2000' or tt.dept_code='9007'  --고객사업본부, CRM팀은 값없음
                      then '-'
                      when tt.tm_mang_plan=0 then '-'
                      else to_char(round(tt.tm_prre_clog/tt.tm_mang_plan*100,1) )
                      end                                                               as befo_avg_rate  --지표율(%)
                ,case when tt.hdqt_code='2000' or tt.dept_code='9007' --고객사업본부, CRM팀은 값없음
                      then '-'
                      when tt.mang_plan =0    and tt.tm_mang_plan <> 0 
                        then '-'
                        when tt.mang_plan <> 0  and tt.tm_mang_plan = 0  
                        then '-'
                        when tt.mang_plan =0    and tt.tm_mang_plan =0   
                        then '-'
                        else to_char(round(tt.mang_plan * ( (tt.prre_clog/tt.mang_plan) -(tt.tm_prre_clog/tt.tm_mang_plan)),0)  )
                        end                                                             as mang_rate      --지표비
                ,case       when (tt.hdqt_code='1000' and tt.dept_code='1010') --경영지원팀 default 값 0
                            then '0'
                            when (tt.hdqt_code='2000' or tt.dept_code='9007') and tt.mang_plan =0  --고객사업본부, CRM팀은 지표비를 0으로 해서 목표값만
                            then '-'
                            when tt.hdqt_code='2000' or tt.dept_code='9007' --고객사업본부, CRM팀은 지표비를 0으로 해서 목표값만
                            then to_char(round(tt.mang_plan,0))
                            when tt.mang_plan =0    and tt.tm_mang_plan <> 0 
                            then '-'
                            when tt.mang_plan <> 0  and tt.tm_mang_plan = 0  
                            then '-'
                            when tt.mang_plan =0    and tt.tm_mang_plan =0   
                            then '-'
                            else  to_char(round(tt.mang_plan+tt.mang_plan * ( (tt.prre_clog/tt.mang_plan) -(tt.tm_prre_clog/tt.tm_mang_plan)),0)) 
                            end                                        as pre_prre_clog  --월말예상(목표+지표비)
                ,case       when (tt.hdqt_code='1000' and tt.dept_code='1010') --경영지원팀 default 값 0
                            then '0'      
                    
                            when (tt.hdqt_code='2000' or tt.dept_code='9007') and tt.mang_plan =0  --고객사업본부, CRM팀은 지표비를 0으로 해서 목표값만
                            then '-'
                			when tt.hdqt_code='2000' or tt.dept_code='9007' --고객사업본부, CRM팀은 지표비를 0으로 해서 목표값만
                            then to_char(round(tt.mang_plan/ tt.mang_plan *100,1))
                            when tt.mang_plan =0    and tt.tm_mang_plan <> 0
                            then '-'
                         
                            when tt.mang_plan <> 0  and tt.tm_mang_plan = 0
                            then '-'
                            when tt.mang_plan =0    and tt.tm_mang_plan =0
                            then '-'
                            else to_char(round((tt.mang_plan+tt.mang_plan * ( (tt.prre_clog/tt.mang_plan) -(tt.tm_prre_clog/tt.tm_mang_plan)))/ tt.mang_plan *100,1) )
                            end                                       as  pre_prre_rate --월말예상달성율(%)         
                from
                 ( select  
                                 cm.hdqt_code
                                ,cm.dept_code
                                ,sum(nvl(a.mang_plan,0))/1000000                as mang_plan
                                ,sum(nvl(a.prre_clog,0))/1000000                as prre_clog
                                ,sum(nvl(a.prre_clog,0) -nvl(bm.prre_clog,0))/1000000  as befo_month_gap
                                ,sum(nvl(a.prre_clog,0) -nvl(bd.prre_clog,0))/1000000  as befo_day_gap
                                ,sum(nvl(tm.prre_clog/tm.mang_plan,0))  as befo_avg_rate   
                                ,sum(nvl(tm.prre_clog,0))/1000000               as tm_prre_clog
                                ,sum(nvl(tm.mang_plan,0))/1000000               as tm_mang_plan
                         from 
                             ( select   distinct
                                      decode(a.prcd_team_code,'1004','1000',a.prcd_team_code)  as hdqt_code
                                    , a.team_code       as  dept_code
                                    , decode(a.prcd_team_code,'2000','고객사업본부','8000','채권사업본부','5000','전략사업본부','9000','SA사업본부'
                                    ,'8002','공공사업부'  ,'1004','경영지원팀'  ) as hdqt_name
                                    ,a.team_name as dept_name
                                    from oparse.cm03orgn a,anddw.d_ad02clog@anddw_link b
                                    where a.use_yn=' '
                                    and ( a.prcd_team_code in ('2000','8000','5000','9000','8002')
                                        or a.team_code='1010')
                                    and a.team_code not in ('4020','4035')  
                                    and a.team_code =b.dept_code
                              ) cm
                              , ( SELECT clog_ymd
                                       ,clog_dd
                                       ,hdqt_code 
                                       ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
                                       ,sum(mang_plan) mang_plan
                                       ,sum(prre_clog) prre_clog
                                  FROM anddw.d_ad02clog@anddw_link 
                                  where 1=1
                                    and clog_ymd = v_ymd
                                  group by  clog_ymd
                                       ,clog_dd
                                       ,hdqt_code
                                       ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end
                                ) a 
                             ,( SELECT    hdqt_code 
                                       ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
                                       ,sum(mang_plan) mang_plan
                                       ,sum(prre_clog) prre_clog
                                  FROM anddw.d_ad02clog@anddw_link 
                                  where 1=1
                                  and clog_yyyy = substr(v_befo_yymm,0,4)--v_befo_yyyy
                                  and CLOG_MM   = substr(v_befo_yymm,5,2)--v_befo_mm
                                  and clog_dd   = v_dd
                                  group by  hdqt_code
                                  ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end
                                ) bm
                               ,( SELECT hdqt_code 
                                       ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
                                       ,sum(mang_plan) mang_plan
                                       ,sum(prre_clog) prre_clog
                                  FROM anddw.d_ad02clog@anddw_link 
                                  where 1=1
                                    and clog_ymd  = v_befo_ymd
                                  group by  hdqt_code
                                  ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end

                                ) bd
                               ,( SELECT  hdqt_code 
                                       ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
--                                       ,sum(mang_plan) mang_plan
--                                       ,sum(prre_clog) prre_clog
                                        ,sum(case when clog_dd='D-00' then prre_clog else 0 end) mang_plan
                                        ,sum(case when clog_dd =v_dd then prre_clog else 0 end ) prre_clog 
                                  FROM anddw.d_ad02clog@anddw_link 
                                  where 1=1
                                  and (
                                        ( p_befo_term_divi='01' and clog_ymd between v_befo_yymm3||'01' and v_befo_yymm||'31' ) 
                                    or 
                                        ( p_befo_term_divi='02' and clog_ymd between v_befo_yymm6||'01' and v_befo_yymm||'31' ) 
                                        )
                                  --and clog_dd   = v_dd
                                  and clog_dd in ('D-00', v_dd)
                                  group by  hdqt_code
                                  ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end
                                             
                                ) tm 
                            
                            where 1=1
                            and cm.hdqt_code =a.hdqt_code(+)
                            and cm.dept_code =a.dept_code(+)
                            
                            and cm.hdqt_code = bd.hdqt_code(+)
                            and cm.dept_code = bd.dept_code(+)
                            
                            and cm.hdqt_code =bm.hdqt_code(+)
                            and cm.dept_code =bm.dept_code(+)
                            
                            and cm.hdqt_code =tm.hdqt_code(+)
                            and cm.dept_code =tm.dept_code(+)
             group by  rollup(cm.hdqt_code,  Cm.dept_code )

            ) tt
              where 1=1 -- (tt.clog_dd is not null or tt.hdqt_code is not null)  
--              and (tt.clog_dd is not null or tt.dept_code='1010' )
                and ( (tt.hdqt_code <>'1000' or tt.dept_code <>'9999')
					   or (tt.hdqt_code is null or tt.dept_code ='9999')
					   )
              order by decode(  tt.hdqt_code,'2000',1,'8000',2,'5000',3,'9000',4,'8002',5,'1000','6',null,7) asc
             , decode(tt.dept_code,'3030',1,'3031',2,'6030',3
             			,'2032',4,'4060',5,'4045',6,'4050',7,'8010',8
             			,'8051',9,'8052',10,'4090',11,'7020',12
             			,'8020',13,'9007',14,'9006',15
             			,'8073',16,'8076',17,'8080',18,'1010',19,20) asc
          ;

        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '00';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;
--------------------------------------------------------------------
-- 매출현황(탭2) 월마감(총괄) 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s002  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , mm_list               OUT     rtn_rctype2

       , p_stdd_yymm           IN      VARCHAR2
    )
    IS
    
    
    v_befo_ymd      varchar2(8);         
    v_befo_yymm     varchar2(6);
    v_befo_yymm3    varchar2(6);
    v_befo_yymm6    varchar2(6);
    v_dd            varchar2(6);
    

    BEGIN
    
      select
--         case when to_char(sysdate,'yyyymm')= p_stdd_yymm
--              then (select max(stdd_ymd)
--                    from oparse.cm09cald
--                    where stdd_ymd < (select max(stdd_ymd)
--                                        from oparse.cm09cald
--                                        where stdd_ymd <= a.stdd_ymd
--                                        and hday_yn='N' )
--                    and hday_yn='N'
--
--                        )              
--              else  (select max(clog_ymd)
--                    from anddw.d_ad02clog@anddw_link
--                    where clog_ymd like p_stdd_yymm||'%') 
--              end                                            AS befo_ymd  
           (select max(clog_ymd)
                    from anddw.d_ad02clog@anddw_link
                    where clog_ymd like p_stdd_yymm||'%')    AS befo_ymd    
              
    into  v_befo_ymd --등록된최근일(당월) 또는 말일
    from (select to_char(sysdate,'yyyymmdd') stdd_ymd
            from dual
        ) a
     ; 
   select 
    nvl((select clog_dd
                from anddw.d_ad02clog@anddw_link
                where clog_ymd =v_befo_ymd
                and rownum =1 ),null)
    into v_dd
    from dual;
    
     select   to_char(add_months(to_date( p_stdd_yymm||'01','yyyymmdd'),-1),'yyyymm')
             ,to_char(add_months(to_date( p_stdd_yymm||'01','yyyymmdd'),-3),'yyyymm')       
             ,to_char(add_months(to_date( p_stdd_yymm||'01','yyyymmdd'),-6),'yyyymm')     
    into v_befo_yymm
        ,v_befo_yymm3
        ,v_befo_yymm6
    from dual;    
    
    
         OPEN mm_list  FOR

          select
              tt.rowno
              ,tt.stdd_yymm
              ,tt.hdqt_code            
              ,tt.dept_code
              ,tt.hdqt_name
              ,tt.dept_name
              ,to_char(tt.mang_plan) as mang_plan
              ,to_char(tt.prre_clog) as prre_clog
              ,case when tt.mang_plan=0 or tt.prre_clog='-'
                    then '-'
                    else to_char(round(tt.prre_clog/tt.mang_plan *100,1))
                    end             as prre_rate
              ,case when tt.prre_clog ='-' 
                    then '-'
                    when tt.hdqt_code='1000' --경영지원팀 계획비 default 0
                    then '0'
                    else to_char((to_number(tt.prre_clog)-tt.mang_plan))
                    end              as plan_gap
              ,to_char(tt.year_plan) as year_plan
              ,case when tt.prre_clog='-'
                    then to_char(tt.year_clog)
                    else to_char(tt.year_clog+to_number(tt.prre_clog))
                    end              as year_clog
             ,case when tt.year_plan=0
                   then '-'
                   else (case when tt.prre_clog='-'
                    then to_char(round(tt.year_clog/tt.year_plan*100,1))
                    else to_char(round((tt.year_clog+to_number(tt.prre_clog))/tt.year_plan*100,1))
                    end)
                   end               as year_prre_rate
         from (select rownum as rowno
                    ,p_stdd_yymm as stdd_yymm
                    ,nvl(a.hdqt_code,'9999')                                         as hdqt_code      --본부코드
                    ,decode(a.hdqt_code ,'2000','고객사업본부','8000','채권사업본부'
                            ,'5000','전략사업본부','9000','SA사업본부'
                            ,'8002','공공사업부','1000','경영지원팀',null,'총계')    as hdqt_name      --본부명
                    ,nvl(a.dept_code,'9999')                                 as dept_code      --부서코드
                    ,case
                      when a.hdqt_code is null and a.dept_code is null then '총계'
                      when  a.hdqt_code is not null and a.dept_code is null then '소계'
                      when a.dept_code='1010' then '경영지원팀'
                      else oparse.COMM_FUNC.F_GET_TEAM_NAME('1',a.dept_code)
                      end                                                     as dept_name
                    ,round(a.mang_plan,0) as mang_plan     --당월목표
                    ,case   when (a.hdqt_code='1000' and a.dept_code='1010') --경영지원팀 default 값 0
                            then '0'                    
                            when (a.hdqt_code='2000' or a.dept_code='9007') and a.dd_mang_plan =0  --고객사업본부, CRM팀은 지표비를 0으로 해서 목표값만
                            then '-'
                            when a.hdqt_code='2000' or a.dept_code='9007' --고객사업본부, CRM팀은 지표비를 0으로 해서 목표값만
                            then to_char(round(a.dd_mang_plan,0))
                            when a.dd_mang_plan =0    and a.tm_mang_plan <> 0
                            then '-'
                            when a.dd_mang_plan <> 0  and a.tm_mang_plan = 0
                            then '-'
                            when a.dd_mang_plan =0    and a.tm_mang_plan =0
                            then '-'
                            else  to_char(round(a.dd_mang_plan+a.dd_mang_plan * ( (a.dd_prre_clog/a.dd_mang_plan) -(a.tm_prre_clog/a.tm_mang_plan)),0))
                            end                                        as prre_clog  --월말예상  =당월실적

                    ,round(a.year_plan,0) as year_plan   --연간계획
                    ,round(a.year_clog,0) as year_clog   --연간실적(당월실적 불포함)
                    from
                    (select
                         cm.hdqt_code
                        ,cm.dept_code
                        ,sum(nvl(mm.mang_plan,0))/1000000   as mang_plan
                        ,sum(nvl(mm.occr_clog,0))/1000000   as occr_clog
                        ,sum(nvl(yym.mang_plan,0))/1000000   as year_plan
                        ,sum(nvl(yyc.occr_clog,0))/1000000   as year_clog
                        ,sum(nvl(bd.mang_plan,0))/1000000   as dd_mang_plan
                        ,sum(nvl(bd.prre_clog,0))/1000000   as dd_prre_clog
                        ,sum(nvl(tm.mang_plan,0))/1000000   as tm_mang_plan
                        ,sum(nvl(tm.prre_clog,0))/1000000   as tm_prre_clog
                        from
                                ( select    distinct
                                          decode(a.prcd_team_code,'1004','1000',a.prcd_team_code)  as hdqt_code
                                        , a.team_code       as  dept_code
                                        , decode(a.prcd_team_code,'2000','고객사업본부','8000','채권사업본부','5000','전략사업본부','9000','SA사업본부'
                                        ,'8002','공공사업부','1004','경영지원팀' ) as hdqt_name
                                        ,a.team_name as dept_name
                                        from oparse.cm03orgn a,anddw.d_ad02clog@anddw_link b
                                        where a.use_yn=' '
                                        and ( a.prcd_team_code in ('2000','8000','5000','9000','8002')
                                            or a.team_code='1010')
                                        and a.team_code not in ('4020','4035') 
                                        and a.team_code =b.dept_code
                                  ) cm
                                  ,(  select hdqt_code
                                            ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
                                            ,sum(nvl(mang_plan,0)) mang_plan
                                            ,sum(nvl(occr_clog,0)) occr_clog
                                        from anddw.m_ad01clog@anddw_link
                                        where 1=1
                                        and clog_yyyy=substr(p_stdd_yymm,0,4)
                                        and clog_mm=substr(p_stdd_yymm,5,2)
                                        group by 
                                             hdqt_code
                                            ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end
                                     ) mm
                                    ,(  select 
                                             hdqt_code
                                            ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
                                            ,sum(nvl(mang_plan,0)) mang_plan      
                                        from anddw.m_ad01clog@anddw_link
                                        where 1=1
                                        and clog_yyyy=substr(p_stdd_yymm,0,4)
                                        and clog_mm <=substr(p_stdd_yymm,5,2)
                                        group by  hdqt_code
                                            ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end
                                     ) yym
                                     ,(  select 
                                             hdqt_code
                                            ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
                                            ,sum(nvl(occr_clog,0)) occr_clog      
                                        from anddw.m_ad01clog@anddw_link
                                        where 1=1
                                        and clog_yyyy=substr(v_befo_yymm,0,4)
                                        and clog_mm <=substr(v_befo_yymm,5,2)
                                        group by  hdqt_code
                                            ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end
                                     ) yyc
                                   ,(  SELECT  hdqt_code
                                           	   ,case when dept_code='4020' then '4050'
		                                       		 when dept_code='4035' then '4045'
		                                       		 else dept_code end dept_code
		                                       ,sum(mang_plan) mang_plan
		                                       ,sum(prre_clog) prre_clog
		                                  FROM anddw.d_ad02clog@anddw_link 
		                                  where 1=1
		                                   and clog_ymd =v_befo_ymd
		                                  group by hdqt_code
		                                       ,case when dept_code='4020' then '4050'
		                                       		 when dept_code='4035' then '4045'
		                                       		 else dept_code end
		                             ) bd  --전영업일 실적
                                   ,( SELECT  hdqt_code 
                                       ,case when dept_code='4020' then '4050'
                                       		 when dept_code='4035' then '4045'
                                       		 else dept_code end dept_code
--                                       ,sum(mang_plan) mang_plan
--                                       ,sum(prre_clog) prre_clog
                                       ,sum(case when clog_dd='D-00' then prre_clog else 0 end) mang_plan
                                       ,sum(case when clog_dd =v_dd then prre_clog else 0 end ) prre_clog 
                                      FROM anddw.d_ad02clog@anddw_link 
                                      where 1=1
                                      and ( clog_ymd between v_befo_yymm3||'01' and v_befo_yymm||'31' )  
--                                      and clog_dd =v_dd
                                      and clog_dd in ('D-00', v_dd)  
                                      group by  hdqt_code
                                      ,case when dept_code='4020' then '4050'
                                                 when dept_code='4035' then '4045'
                                                 else dept_code end
                                    ) tm  --3개월진척도
                                where 1=1
                                and cm.hdqt_code =mm.hdqt_code(+)
                                and cm.dept_code =mm.dept_code(+)

                                and cm.hdqt_code =yym.hdqt_code(+)
                                and cm.dept_code =yym.dept_code(+)
                                
                                and cm.hdqt_code =yyc.hdqt_code(+)
                                and cm.dept_code =yyc.dept_code(+)
                                
                                and cm.hdqt_code =bd.hdqt_code(+)
                                and cm.dept_code =bd.dept_code(+)
                                
                                and cm.hdqt_code =tm.hdqt_code(+)
                                and cm.dept_code =tm.dept_code(+)
                                group by  rollup(cm.hdqt_code,  Cm.dept_code )
                    ) a                
              where 1=1
               and ( (a.hdqt_code <>'1000' or a.dept_code <>'9999')
					   or (a.hdqt_code is null or a.dept_code ='9999')
					   )         
            
           ) tt

             order by decode(  tt.hdqt_code,'2000',1,'8000',2,'5000',3,'9000',4,'8002',5,'1000','6',null,7) asc
             , decode(tt.dept_code,'3030',1,'3031',2,'6030',3
             			,'2032',4,'4060',5,'4045',6,'4050',7,'8010',8
             			,'8051',9,'8052',10,'4090',11,'7020',12
             			,'8020',13,'9007',14,'9006',15
             			,'8073',16,'8076',17,'8080',18,'1010',19,20) asc



        ;
        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '00';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;
    
    
--------------------------------------------------------------------
-- 매출현황(탭3) 월마감(부서) 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s003  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , mm_list               OUT     rtn_rctype3

       , p_stdd_yyyy           IN      VARCHAR2
       , p_hdqt_code           IN      VARCHAR2
    )
    IS
    
        v_to_yyyy varchar2(4);
        v_to_mm   varchar2(2);

    BEGIN
    
    select   to_char(sysdate,'yyyy')
            ,substr(to_char(sysdate,'yyyymm'),5,2)
      into   v_to_yyyy
            ,v_to_mm
     from dual
     ;       
    
    
         OPEN mm_list  FOR
          SELECT
          LL.STDD_YYYY
          ,LL.HDQT_CODE
          ,LL.HDQT_NAME
          ,NVL(LL.DEPT_CODE,'9999') AS DEPT_CODE
          ,NVL(LL.DEPT_NAME,'본부계') AS DEPT_NAME
          ,LL.DIVI_NAME
          ,MM1
          ,MM2
          ,MM3
          ,MM4
          ,MM5
          ,MM6
          ,MM7
          ,MM8
          ,MM9
          ,MM10
          ,MM11
          ,MM12
          ,MM13

     FROM
          ( SELECT
                     p_stdd_yyyy            as STDD_YYYY
                    ,p_hdqt_code            as hdqt_code
                    ,(select hdqt_name
					    FROM ANDDW.M_AD01CLOG@ANDDW_LINK
                    WHERE hdqt_code=p_hdqt_code
                    and rownum =1)          as hdqt_name
                   ,dept_code               as dept_code
                   ,(select dept_name
					    FROM ANDDW.M_AD01CLOG@ANDDW_LINK
                    WHERE dept_code=tt.dept_code 
                    and rownum =1)          as dept_name
                   ,DIVI_NAME
                   ,case when  p_stdd_yyyy= v_to_yyyy and v_to_mm <= '01' then 0 else round(sum(MM1)/1000000,1) end mm1
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '02' then  0 else round(sum(MM2)/1000000,1) end  mm2
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '03' then  0 else  round(sum(MM3)/1000000,1) end  mm3
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '04' then  0 else round(sum(MM4)/1000000,1) end mm4
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '05' then  0 else round(sum(MM5)/1000000,1) end mm5
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '06' then  0 else round(sum(MM6)/1000000,1) end mm6
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '07' then  0 else round(sum(MM7)/1000000,1) end mm7
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '08' then  0 else round(sum(MM8)/1000000,1) end mm8
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '09' then  0 else round(sum(MM9)/1000000,1) end mm9
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '10' then  0 else round(sum(MM10)/1000000,1)  end mm10
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '11' then  0 else round(sum(MM11)/1000000,1) end mm11
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '12' then  0 else round(sum(MM12)/1000000,1) end mm12
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm='01'
                         then round(0,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='02'
                         then round(sum(mm1)/1000000,1)   
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='03'
                         then round(sum(mm1+mm2)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='04'
                         then round(sum(mm1+mm2+mm3)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='05'
                         then round(sum(mm1+mm2+mm3+mm4)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='06'
                         then round(sum(mm1+mm2+mm3+mm4+mm5)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='07'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='08'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='09'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='10'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='11'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9+mm10)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='12'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9+mm10+mm11)/1000000,1)
                         else round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9+mm10+mm11+mm12)/1000000,1) end mm13
           FROM
               (   SELECT

                             a.DEPT_CODE         AS DEPT_CODE
                            , '목표'              AS DIVI_NAME
                            , sum(CASE WHEN a.clog_mm='01' then nvl(a.mang_plan,0) else 0 end) as mm1
                            , sum(CASE WHEN a.clog_mm='02' then nvl(a.mang_plan,0) else 0 end) as mm2
                            , sum(CASE WHEN a.clog_mm='03' then nvl(a.mang_plan,0) else 0 end) as mm3
                            , sum(CASE WHEN a.clog_mm='04' then nvl(a.mang_plan,0) else 0 end) as mm4
                            , sum(CASE WHEN a.clog_mm='05' then nvl(a.mang_plan,0) else 0 end) as mm5
                            , sum(CASE WHEN a.clog_mm='06' then nvl(a.mang_plan,0) else 0 end) as mm6
                            , sum(CASE WHEN a.clog_mm='07' then nvl(a.mang_plan,0) else 0 end) as mm7
                            , sum(CASE WHEN a.clog_mm='08' then nvl(a.mang_plan,0) else 0 end) as mm8
                            , sum(CASE WHEN a.clog_mm='09' then nvl(a.mang_plan,0) else 0 end) as mm9
                            , sum(CASE WHEN a.clog_mm='10' then nvl(a.mang_plan,0) else 0 end) as mm10
                            , sum(CASE WHEN a.clog_mm='11' then nvl(a.mang_plan,0) else 0 end) as mm11
                            , sum(CASE WHEN a.clog_mm='12' then nvl(a.mang_plan,0) else 0 end) as mm12
                    FROM ANDDW.M_AD01CLOG@ANDDW_LINK a
                    WHERE a.CLOG_YYYY =p_stdd_yyyy
                    AND   a.HDQT_CODE =p_hdqt_code
                     GROUP BY a.dept_code
                    
                    UNION ALL
                    
                  SELECT

                             a.DEPT_CODE         AS DEPT_CODE
                            , '실적'              AS DIVI_NAME
                            , sum(CASE WHEN a.clog_mm='01' then nvl(a.occr_clog,0) else 0 end) as mm1
                            , sum(CASE WHEN a.clog_mm='02' then nvl(a.occr_clog,0) else 0 end) as mm2
                            , sum(CASE WHEN a.clog_mm='03' then nvl(a.occr_clog,0) else 0 end) as mm3
                            , sum(CASE WHEN a.clog_mm='04' then nvl(a.occr_clog,0) else 0 end) as mm4
                            , sum(CASE WHEN a.clog_mm='05' then nvl(a.occr_clog,0) else 0 end) as mm5
                            , sum(CASE WHEN a.clog_mm='06' then nvl(a.occr_clog,0) else 0 end) as mm6
                            , sum(CASE WHEN a.clog_mm='07' then nvl(a.occr_clog,0) else 0 end) as mm7
                            , sum(CASE WHEN a.clog_mm='08' then nvl(a.occr_clog,0) else 0 end) as mm8
                            , sum(CASE WHEN a.clog_mm='09' then nvl(a.occr_clog,0) else 0 end) as mm9
                            , sum(CASE WHEN a.clog_mm='10' then nvl(a.occr_clog,0) else 0 end) as mm10
                            , sum(CASE WHEN a.clog_mm='11' then nvl(a.occr_clog,0) else 0 end) as mm11
                            , sum(CASE WHEN a.clog_mm='12' then nvl(a.occr_clog,0) else 0 end) as mm12       
                    FROM ANDDW.M_AD01CLOG@ANDDW_LINK a
                    WHERE a.CLOG_YYYY =p_stdd_yyyy
                    AND   a.HDQT_CODE =p_hdqt_code
                     GROUP BY a.dept_code
                    
                      UNION ALL
                    
                  SELECT

                             '9999'         AS DEPT_CODE
                            , '比'              AS DIVI_NAME
                            , sum(CASE WHEN a.clog_mm='01' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm1
                            , sum(CASE WHEN a.clog_mm='02' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm2
                            , sum(CASE WHEN a.clog_mm='03' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm3
                            , sum(CASE WHEN a.clog_mm='04' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm4
                            , sum(CASE WHEN a.clog_mm='05' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm5
                            , sum(CASE WHEN a.clog_mm='06' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm6
                            , sum(CASE WHEN a.clog_mm='07' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm7
                            , sum(CASE WHEN a.clog_mm='08' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm8
                            , sum(CASE WHEN a.clog_mm='09' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm9
                            , sum(CASE WHEN a.clog_mm='10' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm10
                            , sum(CASE WHEN a.clog_mm='11' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm11
                            , sum(CASE WHEN a.clog_mm='12' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm12       
                    FROM ANDDW.M_AD01CLOG@ANDDW_LINK a
                    WHERE a.CLOG_YYYY =p_stdd_yyyy
                    AND   a.HDQT_CODE =p_hdqt_code
                     
                    
                     
                     
            ) tt            
            group by rollup( tt.divi_name,tt.dept_code )
            
            ORDER BY TT.dept_code, TT.DIVI_NAME
           ) LL
 WHERE ((LL.DEPT_NAME IS NOT NULL AND LL.DIVI_NAME IS NOT NULL )
OR (LL.DEPT_CODE IS NULL AND LL.DIVI_NAME IS NOT NULL)
 )

        ;
        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '01';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;
    
    
    
    
--------------------------------------------------------------------
-- 매출현황(탭4) 월마감(업무) 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s004  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , mm_list               OUT     rtn_rctype4

       , p_stdd_yyyy           IN      VARCHAR2
       , p_dept_code           IN      VARCHAR2
    )
    IS

       v_to_yyyy varchar2(4);
        v_to_mm   varchar2(2);

    BEGIN
    
    select   to_char(sysdate,'yyyy')
            ,substr(to_char(sysdate,'yyyymm'),5,2)
      into   v_to_yyyy
            ,v_to_mm
     from dual
     ;       
         OPEN mm_list  FOR
         SELECT
          LL.STDD_YYYY
          ,LL.dept_code
          ,LL.dept_name
          ,NVL(LL.BSNS_CODE,'9999') AS BSNS_CODE
          ,NVL(LL.bsns_name,'팀계') AS bsns_name
          ,LL.DIVI_NAME
          ,MM1
          ,MM2
          ,MM3
          ,MM4
          ,MM5
          ,MM6
          ,MM7
          ,MM8
          ,MM9
          ,MM10
          ,MM11
          ,MM12
          ,MM13

     FROM
          ( SELECT
                    p_stdd_yyyy            as STDD_YYYY
                    ,p_dept_code              as dept_code
                    ,(select dept_name
					    FROM ANDDW.M_AD01CLOG@ANDDW_LINK
                    WHERE dept_code=p_dept_code  
                    and rownum =1)          as dept_name
                   ,BSNS_CODE               as BSNS_CODE
                   ,(select bsns_name
					    FROM ANDDW.M_AD01CLOG@ANDDW_LINK
                    WHERE BSNS_CODE=tt.BSNS_CODE
                    and rownum =1)          as bsns_name
                   ,DIVI_NAME
                   ,case when  p_stdd_yyyy= v_to_yyyy and v_to_mm <= '01' then 0 else round(sum(MM1)/1000000,1) end mm1
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '02' then  0 else round(sum(MM2)/1000000,1) end  mm2
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '03' then  0 else  round(sum(MM3)/1000000,1) end  mm3
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '04' then  0 else round(sum(MM4)/1000000,1) end mm4
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '05' then  0 else round(sum(MM5)/1000000,1) end mm5
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '06' then  0 else round(sum(MM6)/1000000,1) end mm6
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '07' then  0 else round(sum(MM7)/1000000,1) end mm7
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '08' then  0 else round(sum(MM8)/1000000,1) end mm8
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '09' then  0 else round(sum(MM9)/1000000,1) end mm9
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '10' then  0 else round(sum(MM10)/1000000,1)  end mm10
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '11' then  0 else round(sum(MM11)/1000000,1) end mm11
                   ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm <= '12' then  0 else round(sum(MM12)/1000000,1) end mm12
                  ,case when p_stdd_yyyy= v_to_yyyy and v_to_mm='01'
                         then round(0,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='02'
                         then round(sum(mm1)/1000000,1)   
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='03'
                         then round(sum(mm1+mm2)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='04'
                         then round(sum(mm1+mm2+mm3)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='05'
                         then round(sum(mm1+mm2+mm3+mm4)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='06'
                         then round(sum(mm1+mm2+mm3+mm4+mm5)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='07'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='08'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='09'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='10'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='11'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9+mm10)/1000000,1)
                         when p_stdd_yyyy= v_to_yyyy and v_to_mm='12'
                         then round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9+mm10+mm11)/1000000,1)
                         else round(sum(mm1+mm2+mm3+mm4+mm5+mm6+mm7+mm8+mm9+mm10+mm11+mm12)/1000000,1) end mm13
           FROM
               (   SELECT

                             a.BSNS_CODE         AS BSNS_CODE
                            , '계획'              AS DIVI_NAME
                            , sum(CASE WHEN a.clog_mm='01' then nvl(a.mang_plan,0) else 0 end) as mm1
                            , sum(CASE WHEN a.clog_mm='02' then nvl(a.mang_plan,0) else 0 end) as mm2
                            , sum(CASE WHEN a.clog_mm='03' then nvl(a.mang_plan,0) else 0 end) as mm3
                            , sum(CASE WHEN a.clog_mm='04' then nvl(a.mang_plan,0) else 0 end) as mm4
                            , sum(CASE WHEN a.clog_mm='05' then nvl(a.mang_plan,0) else 0 end) as mm5
                            , sum(CASE WHEN a.clog_mm='06' then nvl(a.mang_plan,0) else 0 end) as mm6
                            , sum(CASE WHEN a.clog_mm='07' then nvl(a.mang_plan,0) else 0 end) as mm7
                            , sum(CASE WHEN a.clog_mm='08' then nvl(a.mang_plan,0) else 0 end) as mm8
                            , sum(CASE WHEN a.clog_mm='09' then nvl(a.mang_plan,0) else 0 end) as mm9
                            , sum(CASE WHEN a.clog_mm='10' then nvl(a.mang_plan,0) else 0 end) as mm10
                            , sum(CASE WHEN a.clog_mm='11' then nvl(a.mang_plan,0) else 0 end) as mm11
                            , sum(CASE WHEN a.clog_mm='12' then nvl(a.mang_plan,0) else 0 end) as mm12
                    FROM ANDDW.M_AD01CLOG@ANDDW_LINK a
                    WHERE a.CLOG_YYYY =p_stdd_yyyy
                    AND   a.DEPT_CODE =p_dept_code
                     GROUP BY a.BSNS_CODE

                    UNION ALL

                  SELECT

                             a.BSNS_CODE         AS BSNS_CODE
                            , '실적'              AS DIVI_NAME
                            , sum(CASE WHEN a.clog_mm='01' then nvl(a.occr_clog,0) else 0 end) as mm1
                            , sum(CASE WHEN a.clog_mm='02' then nvl(a.occr_clog,0) else 0 end) as mm2
                            , sum(CASE WHEN a.clog_mm='03' then nvl(a.occr_clog,0) else 0 end) as mm3
                            , sum(CASE WHEN a.clog_mm='04' then nvl(a.occr_clog,0) else 0 end) as mm4
                            , sum(CASE WHEN a.clog_mm='05' then nvl(a.occr_clog,0) else 0 end) as mm5
                            , sum(CASE WHEN a.clog_mm='06' then nvl(a.occr_clog,0) else 0 end) as mm6
                            , sum(CASE WHEN a.clog_mm='07' then nvl(a.occr_clog,0) else 0 end) as mm7
                            , sum(CASE WHEN a.clog_mm='08' then nvl(a.occr_clog,0) else 0 end) as mm8
                            , sum(CASE WHEN a.clog_mm='09' then nvl(a.occr_clog,0) else 0 end) as mm9
                            , sum(CASE WHEN a.clog_mm='10' then nvl(a.occr_clog,0) else 0 end) as mm10
                            , sum(CASE WHEN a.clog_mm='11' then nvl(a.occr_clog,0) else 0 end) as mm11
                            , sum(CASE WHEN a.clog_mm='12' then nvl(a.occr_clog,0) else 0 end) as mm12
                    FROM ANDDW.M_AD01CLOG@ANDDW_LINK a
                    WHERE a.CLOG_YYYY =p_stdd_yyyy
                    AND   a.DEPT_CODE =p_dept_code
                     GROUP BY a.BSNS_CODE

                      UNION ALL

                  SELECT

                             '9999'         AS BSNS_CODE
                            , '比'              AS DIVI_NAME
                            , sum(CASE WHEN a.clog_mm='01' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm1
                            , sum(CASE WHEN a.clog_mm='02' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm2
                            , sum(CASE WHEN a.clog_mm='03' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm3
                            , sum(CASE WHEN a.clog_mm='04' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm4
                            , sum(CASE WHEN a.clog_mm='05' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm5
                            , sum(CASE WHEN a.clog_mm='06' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm6
                            , sum(CASE WHEN a.clog_mm='07' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm7
                            , sum(CASE WHEN a.clog_mm='08' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm8
                            , sum(CASE WHEN a.clog_mm='09' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm9
                            , sum(CASE WHEN a.clog_mm='10' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm10
                            , sum(CASE WHEN a.clog_mm='11' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm11
                            , sum(CASE WHEN a.clog_mm='12' then nvl(a.occr_clog,0)-nvl(a.mang_plan,0) else 0 end) as mm12
                    FROM ANDDW.M_AD01CLOG@ANDDW_LINK a
                    WHERE a.CLOG_YYYY =p_stdd_yyyy
                    AND   a.DEPT_CODE =p_dept_code

            ) tt
            group by rollup( tt.divi_name,tt.BSNS_CODE )

            ORDER BY TT.BSNS_CODE, TT.DIVI_NAME
           ) LL
 WHERE ((LL.bsns_NAME IS NOT NULL AND LL.DIVI_NAME IS NOT NULL )
    OR (LL.BSNS_CODE IS NULL AND LL.DIVI_NAME IS NOT NULL)
     )

        ;
        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '01';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;
        
--------------------------------------------------------------------
-- 매출현황(탭3) 콤보박스 조회 
--------------------------------------------------------------------
 PROCEDURE ostse06_s030  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , hdqt_list             OUT     rtn_rctype30

       , p_stdd_yyyy           IN      VARCHAR2
    )   
  IS  
    
  BEGIN  
         OPEN hdqt_list  FOR
            SELECT
              tt.HDQT_CODE as val
            , tt.HDQT_NAME as label
            FROM ANDDW.M_AD01CLOG@ANDDW_LINK tt
            WHERE tt.CLOG_YYYY=p_stdd_yyyy
            GROUP BY tt.HDQT_CODE, tt.HDQT_NAME
            order by decode(  tt.hdqt_code,'2000',1,'8000',2,'5000',3,'9000',4,'8002',5,'1004','6',null,7) asc
         ; 
    
        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '01';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;
    


--------------------------------------------------------------------
-- 매출현황(탭4) 콤보박스 조회 
--------------------------------------------------------------------
 PROCEDURE ostse06_s040  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , hdqt_list             OUT     rtn_rctype40

       , p_stdd_yyyy           IN      VARCHAR2
    )   
  IS  
    
  BEGIN  
         OPEN hdqt_list  FOR
            SELECT
              tt.HDQT_CODE as val
            , tt.HDQT_NAME as label
            FROM ANDDW.M_AD01CLOG@ANDDW_LINK tt
            WHERE tt.CLOG_YYYY=p_stdd_yyyy
            GROUP BY tt.HDQT_CODE, tt.HDQT_NAME
            order by decode(  tt.hdqt_code,'2000',1,'8000',2,'5000',3,'9000',4,'8002',5,'1004','6',null,7) asc
         ; 
    
        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '01';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;

--------------------------------------------------------------------
-- 매출현황(탭4) 콤보박스 조회 
--------------------------------------------------------------------
 PROCEDURE ostse06_s041  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , dept_list             OUT     rtn_rctype41

       , p_stdd_yyyy           IN      VARCHAR2
       , p_hdqt_code           IN      VARCHAR2
    )   
  IS  
    
  BEGIN  
         OPEN dept_list  FOR
            SELECT
              tt.dept_code as val
            , tt.dept_name as label
            FROM ANDDW.M_AD01CLOG@ANDDW_LINK tt
            WHERE tt.CLOG_YYYY=p_stdd_yyyy
            AND   tt.HDQT_CODE=p_hdqt_code
            GROUP BY tt.dept_code, tt.dept_name
            order by tt.dept_code asc
         ; 
    
        p_ret := '00' ;
        p_msg := '조회가 완료 되었습니다.' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_ret := '01';
            p_msg := '조회할 내용이 없습니다.';

        WHEN OTHERS THEN
            p_ret := SQLCODE;
            p_msg := '조회시에러- ' || SQLERRM;
    END;





END;