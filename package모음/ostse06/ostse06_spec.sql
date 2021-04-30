CREATE OR REPLACE PACKAGE OPARSE.OSTSE06
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
    TYPE r_rtn_type IS RECORD(
        rowno           number(5),
        clog_ymd        varchar2(8),
        clog_dd         varchar2(5),
        hdqt_code       varchar2(4),
        dept_code       varchar2(4),
        hdqt_name       varchar2(20),
        dept_name       varchar2(20),
/*        mang_plan       number(13),
        prre_clog       number(13),
        befo_month_gap  number(13),
        befo_day_gap    number(13),
        prre_rate       number(13),
        befo_avg_rate   number(13),
        mang_rate       number(13),
        pre_prre_clog   number(13),
        pre_prre_rate   number(13) */
        mang_plan       varchar2(13),
        prre_clog       varchar2(13),
        befo_month_gap  varchar2(13),
        befo_day_gap    varchar2(13),
        prre_rate       varchar2(13),
        befo_avg_rate   varchar2(13),
        mang_rate       varchar2(13),
        pre_prre_clog   varchar2(13),
        pre_prre_rate   varchar2(13)
    );
--------------------------------------------------------------------
-- record에대한 refcursor 선언
--------------------------------------------------------------------
    TYPE rtn_rctype       IS  REF CURSOR  RETURN  r_rtn_type;
    
    
--------------------------------------------------------------------
-- 매출현황(탭2) 월마감(총괄) 조회 
--------------------------------------------------------------------
    TYPE r_rtn_type2 IS RECORD(
        rowno           number(5),
        stdd_yymm       varchar2(6),
        hdqt_code       varchar2(4),
        dept_code       varchar2(4),
        hdqt_name       varchar2(20),
        dept_name       varchar2(20),
        mang_plan       varchar2(13),
        prre_clog       varchar2(13),
        prre_rate       varchar2(13),
        plan_gap        varchar2(13),
        year_plan       varchar2(13),
        year_clog       varchar2(13),
        year_prre_rate  varchar2(13)
    );
--------------------------------------------------------------------
-- record에대한 refcursor 선언
--------------------------------------------------------------------
    TYPE rtn_rctype2       IS  REF CURSOR  RETURN  r_rtn_type2;
    
    
--------------------------------------------------------------------
-- 매출현황(탭3) 년도별 부서 콤보박스 조회 
--------------------------------------------------------------------    
    TYPE r_rtn_type30 IS RECORD(
        val          varchar2(4),
        label        varchar2(20)
    );
   
    TYPE rtn_rctype30    IS REF CURSOR RETURN r_rtn_type30;
    
--------------------------------------------------------------------
-- 매출현황(탭3) 월마감(부서) 조회 
--------------------------------------------------------------------
    TYPE r_rtn_type3 IS RECORD(
        stdd_yyyy       varchar2(4),
        hdqt_code       varchar2(4),
        dept_code       varchar2(4),
        hdqt_name       varchar2(20),
        dept_name       varchar2(20),
        divi_name       varchar2(20),
        mm1             number(18),
        mm2             number(18),
        mm3             number(18),
        mm4             number(18),
        mm5             number(18),
        mm6             number(18),
        mm7             number(18),
        mm8             number(18),
        mm9             number(18),
        mm10            number(18),
        mm11            number(18),
        mm12            number(18),
        mm13            number(18)
    );
    
--------------------------------------------------------------------
-- record에대한 refcursor 선언
--------------------------------------------------------------------
    TYPE rtn_rctype3       IS  REF CURSOR  RETURN  r_rtn_type3;   
    
--------------------------------------------------------------------
-- 매출현황(탭4) 월마감(업무) 조회 
--------------------------------------------------------------------
    TYPE r_rtn_type4 IS RECORD(
        stdd_yyyy       varchar2(4),
        dept_code       varchar2(4),
        dept_name       varchar2(20),
        bsns_code       varchar2(4),
        bsns_name       varchar2(20),
        divi_name       varchar2(20),
        mm1             number(18),
        mm2             number(18),
        mm3             number(18),
        mm4             number(18),
        mm5             number(18),
        mm6             number(18),
        mm7             number(18),
        mm8             number(18),
        mm9             number(18),
        mm10            number(18),
        mm11            number(18),
        mm12            number(18),
        mm13            number(18)
    );    
--------------------------------------------------------------------
-- record에대한 refcursor 선언
--------------------------------------------------------------------
    TYPE rtn_rctype4       IS  REF CURSOR  RETURN  r_rtn_type4;       
--------------------------------------------------------------------
-- 매출현황(탭4) 년도별 본부 콤보박스 조회 
--------------------------------------------------------------------    
    TYPE r_rtn_type40 IS RECORD(
        val          varchar2(4),
        label        varchar2(20)
    );
   
    TYPE rtn_rctype40    IS REF CURSOR RETURN r_rtn_type40;    
    
--------------------------------------------------------------------
-- 매출현황(탭4) 본부별 부서 콤보박스 조회 
--------------------------------------------------------------------    
    TYPE r_rtn_type41 IS RECORD(
        val          varchar2(4),
        label        varchar2(20)
    );
   
    TYPE rtn_rctype41    IS REF CURSOR RETURN r_rtn_type41;        

--------------------------------------------------------------------
--매출현황(탭1) 일보 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s001  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , day_list              OUT     rtn_rctype

       , p_stdd_ymd            IN      VARCHAR2
       , p_befo_term_divi      IN      VARCHAR2
    ) ;
    
    
--------------------------------------------------------------------
-- 매출현황(탭2) 월마감(총괄) 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s002  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , mm_list               OUT     rtn_rctype2

       , p_stdd_yymm           IN      VARCHAR2
    ) ;    



--------------------------------------------------------------------
-- 매출현황(탭3) 년도별 본부 콤보박스 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s030  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , hdqt_list             OUT     rtn_rctype30

       , p_stdd_yyyy           IN      VARCHAR2
    ) ;  

--------------------------------------------------------------------
-- 매출현황(탭3) 월마감(부서) 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s003  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , mm_list               OUT     rtn_rctype3

       , p_stdd_yyyy           IN      VARCHAR2
       , p_hdqt_code           IN      VARCHAR2
    ) ;  
    
    
--------------------------------------------------------------------
-- 매출현황(탭4) 월마감(업무) 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s004  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , mm_list               OUT     rtn_rctype4

       , p_stdd_yyyy           IN      VARCHAR2
       , p_dept_code           IN      VARCHAR2
    ) ;  
        
    
--------------------------------------------------------------------
-- 매출현황(탭4) 년도별 본부 콤보박스 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s040  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , hdqt_list             OUT     rtn_rctype40

       , p_stdd_yyyy           IN      VARCHAR2
    ) ;  



--------------------------------------------------------------------
-- 매출현황(탭4) 년도와 본부별 부서 콤보박스 조회 
--------------------------------------------------------------------
    PROCEDURE ostse06_s041  (
         p_ret                 OUT     VARCHAR2
       , p_msg                 OUT     VARCHAR2
       , dept_list             OUT     rtn_rctype41

       , p_stdd_yyyy           IN      VARCHAR2
       , p_hdqt_code           IN      VARCHAR2
    ) ;  



END; -- Package spec