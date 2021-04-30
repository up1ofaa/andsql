CREATE OR REPLACE PACKAGE BODY OPARSE.BTOIN01
IS
--------------------------------------------------------------------------------
--  제    목 : 토스 회생신청/확정 조회 (TS_130003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_s13 (
    p_ret             OUT      VARCHAR2,                        -- 에러코드
    p_msg             OUT      VARCHAR2,                        -- 에러메세지
    s_cnt             OUT      NUMBER,                          -- 채무자 리스트

    i_clnt_id         IN       CA01BOND.clnt_id%TYPE,           -- 위탁사ID
    i_clnt_cust_no    IN       CA05CLCU.CLNT_CUST_NO%TYPE,      -- 고객번호
    i_to_ledg_no      IN       WP20PRAA.TO_LEDG_NO%TYPE         -- 특수절차원장번호        
) IS
    v_cust_id       ca01bond.CUST_ID%type;
    v_cust_cnt      number(3);
    v_loan_cnt      number(3);
    
    cust_err        exception;
    loan_err        exception;

BEGIN   
    s_cnt:=-1;
    SELECT count(*)
        into v_cust_cnt
    FROM CA05CLCU
    WHERE CLNT_ID       =i_clnt_id
    AND CLNT_CUST_NO    =i_clnt_cust_no;
    
    IF v_cust_cnt=0 THEN
        raise cust_err;
    ELSE     
         SELECT CUST_ID
        into v_cust_id
        FROM CA05CLCU
        WHERE CLNT_ID       =i_clnt_id
        AND CLNT_CUST_NO    =i_clnt_cust_no;        
    END IF;
    
    SELECT count(*)
        into v_loan_cnt
    FROM CA01BOND c1, CA02RELN c2
    where 1=1
    and c1.use_yn=' '
    and c2.use_yn=' '
    and c1.clnt_id  =c2.clnt_id
    and c1.cont_no  =c2.cont_no
    and c1.bond_seq =c2.bond_seq
    and c2.clnt_id  = i_clnt_id
    and c2.cust_id  = v_cust_id
    and c1.end_divi ='00'
    ;
    
    IF v_loan_cnt =0    then 
        raise loan_err;
    END IF;
    
    select count(*)
     into s_cnt
    from wp20praa wp20
    where wp20.use_yn=' '
    and wp20.clnt_id = i_clnt_id
    and wp20.cust_id = v_cust_id
--    and to_number(substr(wp20.TO_LEDG_NO,5)) = to_number(substr(i_to_ledg_no,5))     
    and wp20.TO_LEDG_NO=i_to_ledg_no
    ;                   
    
    p_ret := '0000';
    p_msg := '조회가 완료되었습니다.';

EXCEPTION
    WHEN cust_err THEN
        s_cnt:=-1;
        p_ret := '3001';
        p_msg := '대상고객이 존재하지 않습니다.';
    WHEN loan_err THEN
        s_cnt:=-1;
        p_ret := '3002';
        p_msg := '진행 대출번호가 존재하지 않습니다.';   
    WHEN NO_DATA_FOUND THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회할 건이 없습니다.';
    WHEN OTHERS THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회시에러 - ' || SQLCODE || ' ' || SQLERRM;
END; 

--------------------------------------------------------------------------------
--  제    목 : 토스 회생신청/확정 입력  (TS_130003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_i13 (
        p_ret                   out varchar2,   -- 리턴 값
        p_msg                   out varchar2,   -- 에러 메세지 
        p_ad_to_ledg_no              in varchar2,   -- 특수절차원장번호       
        p_ad_clnt_cust_no            in varchar2,   -- 고객번호             
        p_ad_case_no                 in varchar2,   -- 사건번호             
        p_ad_jrdt_curt               in varchar2,   -- 관할법원코드         
        p_ad_psrs_aply_ymd           in varchar2,   -- 신청일자             
        p_fx_admn_divi_cd            in varchar2,   -- 특수관리구분코드     
        p_ad_strt_dcsn_dcsn_ymd      in varchar2,   -- 개시결정일자         
        p_ad_strt_dcsn_dmur_perd     in varchar2,   -- 채권신고만기일자     
        p_ad_pmdc_ymd                in varchar2,   -- 인가일자             
        p_ad_stdc_wtop_sbms_ymd      in varchar2,   -- 관리일자             
        p_ad_exam_opin               in varchar2,   -- 관리내용             
        p_ad_psrs_step               in varchar2,   -- 특수절차진행상태코드 
        p_ad_inpt_ymd                in varchar2,   -- 신청등록일자         
        p_ad_acct_sbms_ymd           in varchar2,   -- 계좌신고제출일자     
        p_ad_acct_sbms_inpt_ymd      in varchar2,   -- 계좌신고제출입력일자 
        p_ad_dmap_sbms_ymd           in varchar2,   -- 이의신청제출일자     
        p_ad_psrs_disc_ymd           in varchar2,   -- 폐지일자             
        p_ad_stop_ordr_dcsn_ymd      in varchar2,   -- 금지명령일자         
        p_ad_psrs_immu_ymd           in varchar2,   -- 면책결정일자         
        p_ad_psrs_end_ymd            in varchar2,   -- 종결일자             
        p_ad_dele_ymd                in varchar2,   -- 삭제일자             
        p_ad_dele_yn                 in varchar2,   -- 삭제여부  
        p_psrs_step                  in varchar2,
        p_end_resn                   in varchar2                             
) IS 
    v_cust_id       wp20praa.cust_id%type;    
    v_seq           wp20praa.seq%type;
    v_ledg_seq      wp30toss.seq%type;
    v_to_ledg_no1   wp20praa.TO_LEDG_NO%type;
    
    v_ad_to_ledg_no1 varchar2(4);
    v_ad_to_ledg_no2 number(6);
    
    v_yy            varchar2(2);
    v_debt_cnt      number(3);
    debt_err        exception;
    
    to_ledg_err     exception;
    v_to_live_cnt   number(3);
    to_dupl_err     exception;
    
    v_case_no1      varchar2(4);
    v_case_no2      varchar2(9);
    v_case_no3      varchar2(15);
    v_case_no22      varchar2(9);
    v_case_no33      varchar2(15);
    v_case_no       wp20praa.CASE_NO%type;
    
    
    BEGIN
        p_ret := '3000';
        p_msg := '저장시 에러';  
        v_debt_cnt:=0;
        
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;   
        
      select count(distinct c2.debt_divi) 
        into v_debt_cnt
        from ca01bond c1, ca02reln c2
        where c1.use_yn=' '
        and c2.use_yn=' '
        and c1.clnt_id=c2.CLNT_ID
        and c1.cont_no=c2.cont_no
        and c1.bond_seq=c2.bond_seq
        and c2.clnt_id='700'
        and c2.cust_id= v_cust_id
        and c1.end_divi='00'
        ;
        
      if v_debt_cnt >1 then 
       raise debt_err;
      end if; 

      select nvl(max(w.seq),0)+1
               into v_seq
            from wp20praa w
            where 1=1
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
       ;
      
      select substr(to_char(sysdate,'yyyy'),3,4)
            ,substr(p_ad_to_ledg_no,0,4)
            ,to_number(substr(p_ad_to_ledg_no,5))
        into v_yy
            ,v_ad_to_ledg_no1
            ,v_ad_to_ledg_no2
        from dual
        ;
       SELECT NVL(MAX(TO_NUMBER(SUBSTR(TO_LEDG_NO,5))),0)
           into v_ledg_seq
        FROM WP30TOSS 
        WHERE 1=1
        and clnt_id     ='700'
--       and cust_id     = v_cust_id
        AND RGST_DIVI   ='00' --위임기관 토스
        ;
        --년도(2)+위임기관구분(2)+일련번호(12)
        --위팀기관구분 00:토스 01:에이앤디 02:미래신용정보
        v_to_ledg_no1 := v_yy||'00';        
        IF v_to_ledg_no1 <> v_ad_to_ledg_no1 then
            raise to_ledg_err ;
        END IF; 
        --새로생성되는 번호가 기존 등록번호와 작거나 같으면 에러발생(20210427 김선영 차장 삭제요청)
--        IF v_ad_to_ledg_no2 <=  v_ledg_seq THEN
--            raise to_ledg_err ;
--        END IF; 
        
        
        --기존 삭제되지 않은 특수절차원장번호의 회생이 존재하면 입력중복에러
        --기존 특수절차원장번호와 중복된건이 있으면 중복에러
        select count(*)
            into v_to_live_cnt
        from wp30toss 
        where 1=1
--        and use_yn  =' '
        and clnt_id ='700'
        and to_ledg_no =p_ad_to_ledg_no 
--      AND cust_id =v_cust_id
--      and wp_divi ='PS'
        ;
        
        if v_to_live_cnt > 0 then 
           raise to_dupl_err ;
        end if;
            
        IF  p_ad_case_no is not null THEN
            select   substr(p_ad_case_no,0,4)
                    ,substr(p_ad_case_no,5,2)
                    ,substr(p_ad_case_no,7)  
                    ,substr(p_ad_case_no,5,3)
                    ,substr(p_ad_case_no,8)
              into  v_case_no1
                   ,v_case_no2
                   ,v_case_no3
                   ,v_case_no22
                   ,v_case_no33
             from dual;
             IF  v_case_no22='간회단' THEN
                 v_case_no2:= v_case_no22 ;
                 v_case_no3:= v_case_no33 ;
             END IF;
            v_case_no := v_case_no1||'-'||v_case_no2||'-'||v_case_no3;
        END IF;

       -- (1) 
       -- WP20PRAA 신규입력
       -- SEQ ,TO_LEDG_NO 조회하여 입력 
        INSERT INTO WP20PRAA (   CLNT_ID            ,CUST_ID    ,SEQ 
                                ,TO_LEDG_NO
                                ,JRDT_CURT          
                                ,JRDT_SUPT  
                                ,CASE_NO
                                ,STOP_ORDR_DCSN_YMD 
                                ,STRT_DCSN_DCSN_YMD    
                                ,STRT_DCSN_DMUR_PERD
                                ,STDC_WTOP_SBMS_YMD 
                                ,EXAM_OPIN  
                                ,ACCT_SBMS_YMD 
                                ,ACCT_SBMS_INPT_YMD    
                                ,DMAP_SBMS_YMD
                                ,PMDC_YMD
                                ,PMDC_CNFM_YMD
                                ,APLY_INPT_YMD
                                ,PROG_STEP       
                                ,END_RESN 
                                ,END_YMD        ,END_INPT_DATE          ,END_INPT_STAF    
                                ,INPT_DATE      ,INPT_STAF              ,CHNG_PGM_ID
                                ,CHNG_DATE      ,CHNG_STAF              ,USE_YN )
                    VALUES (    '700'           ,v_cust_id      ,v_seq
                                ,p_ad_to_ledg_no  
 --관할법원코드 변경 전                                
 /*                               ,case when p_ad_jrdt_curt is not null
                                               then decode(p_ad_jrdt_curt, 'ADD1','AQ', substr( p_ad_jrdt_curt,0,2))
                                               else '' end 
                                ,case when p_ad_jrdt_curt is not null then '00' else '' end  */
 --관할법원코드 변경 후                                
                              ,nvl((SELECT decode(rfrc_code,'ADD1','AQ','0000','',substr(rfrc_code,0,2))
                                       from cm02code
                                       where code_id='TO_CPCR_CD'
                                       and code_val= p_ad_jrdt_curt
                                       and rownum=1 ),'')
                                ,case when (SELECT decode(rfrc_code,'ADD1','AQ','0000','',substr(rfrc_code,0,2))
                                                    from cm02code
                                                    where code_id='TO_CPCR_CD'
                                                    and code_val= p_ad_jrdt_curt
                                                    and rownum=1 ) is not null
                                       then  '00' else '' end   
                                ,v_case_no
                                ,p_ad_stop_ordr_dcsn_ymd
                                ,p_ad_strt_dcsn_dcsn_ymd
                                ,p_ad_strt_dcsn_dmur_perd
                                ,p_ad_stdc_wtop_sbms_ymd
                                ,replace(replace(replace(p_ad_exam_opin,chr(13),' '),chr(10),' '),chr(9),' ')
                                ,p_ad_acct_sbms_ymd
                                ,p_ad_acct_sbms_inpt_ymd
                                ,p_ad_dmap_sbms_ymd
                                ,p_ad_pmdc_ymd
                                ,case when p_ad_pmdc_ymd is not null then to_char(sysdate,'yyyymmdd') else '' end
                                ,case when p_ad_psrs_aply_ymd is not null then to_char(sysdate,'yyyymmdd') else '' end
                                ,p_psrs_step
                                ,p_end_resn
                                ,p_ad_psrs_end_ymd
                                ,case when p_ad_psrs_end_ymd is not null then sysdate else to_Date('','yyyymmdd') end
                                ,case when p_ad_psrs_end_ymd is not null then '90000' else '' end                               	    
                                ,sysdate      ,'90000'              ,'BTOIN01_I13'
                                ,sysdate      ,'90000'              ,' ' 
                        );
                        
       -- (2) 
       -- WP30TOSS 신규입력
       -- 특수절차원장번호 생성
          INSERT INTO WP30TOSS ( clnt_id                    ,cust_id            ,to_ledg_no
                                ,seq                        ,clnt_cust_no       ,rgst_divi  
                                ,wp_divi                    ,inpt_date          ,inpt_staf
                                ,chng_pgm_id                ,use_yn )
            VALUES (            '700'                       ,v_cust_id          ,p_ad_to_ledg_no 
                                , to_number(v_seq)          ,p_ad_clnt_cust_no  ,'00'  
                                ,'PS'                       ,SYSDATE            ,'90000'
                                ,'BTOIN01_I13'              ,' '                 
                    );
       
       -- (3) 
       -- WP20PRAB 신규입력
       -- 등록 위임된 모든 대출 등록 
         INSERT INTO  WP20PRAB(      CLNT_ID        ,CUST_ID        ,SEQ    
                                    ,LOAN_NO        ,RGST_YN        ,CUST_NAME       
                                    ,DEBT_DIVI      ,BOND_TYPE      ,APLY_PPD
                                    ,MORT_KIND      ,BOND_RAMT      ,LOAN_YMD
                                    ,INPT_DATE      ,INPT_STAF      ,CHNG_PGM_ID
                                    ,USE_YN )
                SELECT              '700'           ,c2.cust_id     ,v_seq
                                    ,c1.loan_no     ,'Y'            ,c2.cust_name
                                    ,c2.debt_divi   ,c1.bond_type   ,COMM_FUNC.F_GET_PPD(c1.CLNT_ID, c1.CONT_NO, c1.BOND_SEQ)
                                    ,c1.MORT_KIND   ,c1.bond_ramt   ,c1.cont_ymd
                                    ,sysdate        ,'90000'        ,'BTOIN01_I13'
                                    ,' '
                FROM CA01BOND c1, CA02RELN c2
                where c1.use_yn=' '
                and c2.use_yn=' '
                and c1.clnt_id=c2.CLNT_ID
                and c1.cont_no=c2.cont_no
                and c1.bond_seq=c2.bond_seq
                and c2.clnt_id='700'
                and c2.cust_id= v_cust_id
                and c1.end_divi='00'
         ;       
           
          -- (4) 
          -- CA02RELN 단계 수정
          -- 등록 위임된 모든 대출의 회생단계 등록            
             update ca02reln c2
             set  c2.psrs_step       = case when c2.psrs_step<> p_psrs_step or c2.psrs_step is null 
                                         then p_psrs_step else c2.psrs_step end                                        
                , c2.chng_pgm_id     = 'BTOIN01_I13'
                , c2.chng_date       = sysdate
                , c2.chng_staf       = '90000'
              where 1=1
              and c2.use_yn     =' '
              and c2.clnt_id    ='700'
              and c2.cust_id    =v_cust_id
              and exists (select 1
                            from ca01bond c1
                            where c1.use_yn=' '
                            and c1.clnt_id=c2.CLNT_ID
                            and c1.cont_no=c2.cont_no
                            and c1.bond_seq=c2.bond_seq
                            and c1.end_divi='00' )
              ; 
          p_ret := '0000';
          p_msg := '정상적으로 처리되었습니다.';

   EXCEPTION
        WHEN to_ledg_err THEN
            p_ret := '3001';
            p_msg := '새로 생성한 특수절차원장번호와 불일치합니다. ';
        WHEN to_dupl_err THEN
            p_ret := '3001';
            p_msg := '기등록된 특수절차원장번호의 회생사건 삭제후 입력가능합니다. ';    
         WHEN debt_err THEN
            p_ret := '3001';
            p_msg := '대상고객의 채무, 보증채무 등의 위임대출 중 선택 해주세요.';
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

   END;




--------------------------------------------------------------------------------
--  제    목 : 토스 회생신청/확정 수정  (TS_130003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_u13 (
        p_ret                   out varchar2,   -- 리턴 값
        p_msg                   out varchar2,   -- 에러 메세지 
        p_ad_to_ledg_no              in varchar2,   -- 특수절차원장번호       
        p_ad_clnt_cust_no            in varchar2,   -- 고객번호             
        p_ad_case_no                 in varchar2,   -- 사건번호             
        p_ad_jrdt_curt               in varchar2,   -- 관할법원코드         
        p_ad_psrs_aply_ymd           in varchar2,   -- 신청일자             
        p_fx_admn_divi_cd            in varchar2,   -- 특수관리구분코드     
        p_ad_strt_dcsn_dcsn_ymd      in varchar2,   -- 개시결정일자         
        p_ad_strt_dcsn_dmur_perd     in varchar2,   -- 채권신고만기일자     
        p_ad_pmdc_ymd                in varchar2,   -- 인가일자             
        p_ad_stdc_wtop_sbms_ymd      in varchar2,   -- 관리일자             
        p_ad_exam_opin               in varchar2,   -- 관리내용             
        p_ad_psrs_step               in varchar2,   -- 특수절차진행상태코드 
        p_ad_inpt_ymd                in varchar2,   -- 신청등록일자         
        p_ad_acct_sbms_ymd           in varchar2,   -- 계좌신고제출일자     
        p_ad_acct_sbms_inpt_ymd      in varchar2,   -- 계좌신고제출입력일자 
        p_ad_dmap_sbms_ymd           in varchar2,   -- 이의신청제출일자     
        p_ad_psrs_disc_ymd           in varchar2,   -- 폐지일자             
        p_ad_stop_ordr_dcsn_ymd      in varchar2,   -- 금지명령일자         
        p_ad_psrs_immu_ymd           in varchar2,   -- 면책결정일자         
        p_ad_psrs_end_ymd            in varchar2,   -- 종결일자             
        p_ad_dele_ymd                in varchar2,   -- 삭제일자             
        p_ad_dele_yn                 in varchar2,   -- 삭제여부  
        p_psrs_step                  in varchar2,
        p_end_resn                   in varchar2                                
) IS 
     v_cust_id       wp01woaa.cust_id%type;
     v_seq           wp01woaa.seq%type;
    v_case_no1      varchar2(4);
    v_case_no2      varchar2(9);
    v_case_no3      varchar2(15);
    v_case_no22      varchar2(9);
    v_case_no33      varchar2(15);
    v_case_no       wp20praa.CASE_NO%type;
                       
    BEGIN
        p_ret := '3000';
        p_msg := '저장시 에러';  
        
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;       
                          
        select w.seq
               into v_seq
            from wp20praa w
            where 1=1
            and w.use_yn=' '
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
            and w.TO_LEDG_NO = p_ad_to_ledg_no
--            and to_number(substr(w.TO_LEDG_NO,5)) =  to_number(substr(p_ad_to_ledg_no,5))          
        ;   
        
        IF  p_ad_case_no is not null THEN
            select   substr(p_ad_case_no,0,4)
                    ,substr(p_ad_case_no,5,2)
                    ,substr(p_ad_case_no,7)  
                    ,substr(p_ad_case_no,5,3)
                    ,substr(p_ad_case_no,8)
              into  v_case_no1
                   ,v_case_no2
                   ,v_case_no3
                   ,v_case_no22
                   ,v_case_no33
             from dual;
             IF  v_case_no22='간회단' THEN
                 v_case_no2:= v_case_no22 ;
                 v_case_no3:= v_case_no33 ;
             END IF;
            v_case_no := v_case_no1||'-'||v_case_no2||'-'||v_case_no3;
         END IF;
     
          --2) WP20PRAA 수정
          -- CLNT_ID, CUST_ID, SEQ, TO_LEDG_NO 로 조회하여 수정
          update wp20praa 
          set   to_ledg_no             = case when to_ledg_no is null then p_ad_to_ledg_no else to_ledg_no end
 --관할법원코드 변경 전          
 /*              ,jrdt_curt              = case when p_ad_jrdt_curt is not null               
                                               then decode(p_ad_jrdt_curt, 'ADD1','AQ', substr( p_ad_jrdt_curt,0,2))
                                               else '' end 
               ,jrdt_supt              = case when p_ad_jrdt_curt is not null then '00' else '' end     */                           
               
 --관할법원코드 변경 후               
               ,jrdt_curt               = nvl((SELECT decode(rfrc_code,'ADD1','AQ','0000','',substr(rfrc_code,0,2))
                                            from cm02code
                                            where code_id='TO_CPCR_CD'
                                            and code_val= p_ad_jrdt_curt
                                            and rownum=1 ),'') 
               ,jrdt_supt               = case when (SELECT decode(rfrc_code,'ADD1','AQ','0000','',substr(rfrc_code,0,2))
                                                from cm02code
                                                where code_id='TO_CPCR_CD'
                                                and code_val= p_ad_jrdt_curt
                                                and rownum=1 ) is not null
                                            then  '00' else '' end                             
               , case_no                = v_case_no                                
               , strt_dcsn_dcsn_ymd     = p_ad_strt_dcsn_dcsn_ymd              
               , strt_dcsn_dmur_perd    = p_ad_strt_dcsn_dmur_perd 
               , pmdc_ymd               = p_ad_pmdc_ymd 
               , pmdc_cnfm_ymd          = case when p_ad_pmdc_ymd is not null and pmdc_cnfm_ymd is null 
                                               then to_char(sysdate,'yyyymmdd') else  pmdc_cnfm_ymd end
               , stdc_wtop_sbms_ymd     = p_ad_stdc_wtop_sbms_ymd 
               , exam_opin              = replace(replace(replace(p_ad_exam_opin,chr(13),' '),chr(10),' '),chr(9),' ')
               , acct_sbms_ymd          = p_ad_acct_sbms_ymd
               , acct_sbms_inpt_ymd     = p_ad_acct_sbms_inpt_ymd
               , dmap_sbms_ymd          = p_ad_dmap_sbms_ymd
               , stop_ordr_dcsn_ymd     = p_ad_stop_ordr_dcsn_ymd 
               , aply_inpt_ymd          = case when p_ad_psrs_aply_ymd is not null and aply_inpt_ymd is null 
                                               then to_char(sysdate,'yyyymmdd') else  aply_inpt_ymd end
               , prog_step       = p_psrs_step
               , end_resn        = p_end_resn
           -- AND  개인회생단계 :   00.단계없음    	01.법원사항 	10.중지명령 	20.개시결정
		   --				        60.인가결정		70.종결 	
		   --				        21.인가조건		40.이의신청		50.채권자집회
		   --		종결구분    :	71.기각결정		72.인가후폐지	73.면책결정
		   --				        74.신청취하		75.대출완제		76.인가전폐지	79.기타	               
               , end_ymd        = case when p_psrs_step='70' 
                                        then nvl(COALESCE(p_ad_psrs_immu_ymd,p_ad_psrs_disc_ymd,p_ad_psrs_end_ymd ),'') 
                                        else '' end
               , end_inpt_date   = case when p_psrs_step='70' then sysdate else to_date('','yyyymmdd') end  
               , end_inpt_staf   = case when p_psrs_step='70' then '90000' else '' end 
               , chng_pgm_id     = 'BTOIN01_U13'
               , chng_date       = sysdate
               , chng_staf       = '90000'
          where  1=1
            and use_yn  = ' ' 
            and clnt_id = '700'                                                                
            and cust_id = v_cust_id   
            and seq     = v_seq 
--            and TO_LEDG_NO = p_ad_to_ledg_no
            ; 
            -- 2) WP30TOSS 단계 수정
            -- WP30TOSS 등록된 대출의 특수절차원장번호 수정
            UPDATE WP30TOSS w
                set  seq = v_seq
                    ,cust_id = v_cust_id  
                    ,wp_divi    = 'PS'
                    ,chng_date  = sysdate
                    ,chng_Staf  = '90000'
               where 1=1
               and w.clnt_id = '700'
               and w.to_ledg_no = p_ad_to_ledg_no
            ;
            --3) CA02RELN 단계 수정
            --WP20PRAB 등록된 대출만 SEQ로 조회하여 수정
            update ca02reln c2
                    set   psrs_step       = p_psrs_step
                        , chng_pgm_id     = 'BTOIN01_U13'
                        , chng_date       = sysdate
                        , chng_staf       = '90000'
             where 1=1
             and c2.use_yn=' '
             and c2.clnt_id='700'
             and c2.cust_id= v_cust_id  
             and ( c2.cont_no, c2.bond_seq) 
                            in (select c1.cont_no, c1.bond_seq
                                 from wp20prab b , ca01bond c1
                                 where b.use_yn=' '
                                 and b.clnt_id='700'
                                 and b.cust_id =v_cust_id
                                 and b.seq     =v_seq 
                                 and b.clnt_id =c1.clnt_id
                                 and b.loan_no =c1.loan_no
                                 and c1.end_divi='00'
                                 and c1.use_yn=' '
                                 )
              ; 
              
            p_ret := '0000';
            p_msg := '정상적으로 처리되었습니다.';
              
           
   EXCEPTION
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

   END;




--------------------------------------------------------------------------------
--  제    목 : 토스 회생신청/확정 삭제  (TS_130003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_d13 (
        p_ret                   out varchar2,   -- 리턴 값
        p_msg                   out varchar2,   -- 에러 메세지 
        p_ad_to_ledg_no              in varchar2,   -- 특수절차원장번호       
        p_ad_clnt_cust_no            in varchar2,   -- 고객번호             
        p_ad_case_no                 in varchar2,   -- 사건번호             
        p_ad_jrdt_curt               in varchar2,   -- 관할법원코드         
        p_ad_psrs_aply_ymd           in varchar2,   -- 신청일자             
        p_fx_admn_divi_cd            in varchar2,   -- 특수관리구분코드     
        p_ad_strt_dcsn_dcsn_ymd      in varchar2,   -- 개시결정일자         
        p_ad_strt_dcsn_dmur_perd     in varchar2,   -- 채권신고만기일자     
        p_ad_pmdc_ymd                in varchar2,   -- 인가일자             
        p_ad_stdc_wtop_sbms_ymd      in varchar2,   -- 관리일자             
        p_ad_exam_opin               in varchar2,   -- 관리내용             
        p_ad_psrs_step               in varchar2,   -- 특수절차진행상태코드 
        p_ad_inpt_ymd                in varchar2,   -- 신청등록일자         
        p_ad_acct_sbms_ymd           in varchar2,   -- 계좌신고제출일자     
        p_ad_acct_sbms_inpt_ymd      in varchar2,   -- 계좌신고제출입력일자 
        p_ad_dmap_sbms_ymd           in varchar2,   -- 이의신청제출일자     
        p_ad_psrs_disc_ymd           in varchar2,   -- 폐지일자             
        p_ad_stop_ordr_dcsn_ymd      in varchar2,   -- 금지명령일자         
        p_ad_psrs_immu_ymd           in varchar2,   -- 면책결정일자         
        p_ad_psrs_end_ymd            in varchar2,   -- 종결일자             
        p_ad_dele_ymd                in varchar2,   -- 삭제일자             
        p_ad_dele_yn                 in varchar2,   -- 삭제여부  
        p_psrs_step                  in varchar2,
        p_end_resn                   in varchar2                                
) IS 
      v_cust_id       wp01woaa.cust_id%type;
      v_seq           wp01woaa.seq%type;
                       
    BEGIN
        p_ret := '3000';
        p_msg := '저장시 에러';  
        
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;       
                          
        select w.seq
               into v_seq
            from wp20praa w
            where 1=1
            and w.use_yn=' '
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
            and w.TO_LEDG_NO = p_ad_to_ledg_no
        ;                                 
              -- 개인회생 마스터 삭제처리 
              update wp20praa 
              set        chng_pgm_id     = 'BTOIN01_D13'
                       , dele_date       = sysdate
                       , dele_staf       = '90000'
                       , use_yn          = 'D'
              where  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ; 
                
                -- 개인회생 대출관리 삭제처리  
              update wp20prab 
              set        chng_pgm_id     = 'BTOIN01_D13'
                       , dele_date       = sysdate
                       , dele_staf       = '90000'
                       , use_yn          = 'D'
              where  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ;    
                
                 -- 개인회생 법무일정관리 삭제처리
              UPDATE WP20PRAC
              SET use_yn = 'D'
                  , dele_staf ='90000'
                  , dele_date = SYSDATE
                  , chng_pgm_id = 'BTOIN01_D13'
              WHERE  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ;
              -- 개인회생 속성 및 기타사항 삭제처리
              UPDATE WP20PRAD
              SET use_yn = 'D'
                  , dele_staf ='90000'
                  , dele_date = SYSDATE
                  , chng_pgm_id = 'BTOIN01_D13'
              WHERE  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ;
             --  개인회생 변제스케쥴 삭제처리
             UPDATE WP21PRKA
              SET   use_yn = 'D'
                  , dele_staf = '90000'
                  , dele_date = SYSDATE
                   , chng_pgm_id = 'BTOIN01_D13'
              WHERE  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ;
              --  개인회생 변제스케쥴 삭제처리
            UPDATE WP21PRKB
              SET use_yn = 'D'
                  , dele_staf = '90000'
                  , dele_date = SYSDATE
                   , chng_pgm_id = 'BTOIN01_D13'
              WHERE  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ;
      
           --  관계인 회생단계 초기화      
            update ca02reln c2
                    set   psrs_step       = ''
                        , chng_pgm_id     = 'BTOIN01_D13'
                        , chng_date       = sysdate
                        , chng_staf       = '90000'
             where 1=1
             and c2.use_yn=' '
             and c2.clnt_id='700'
             and c2.cust_id= v_cust_id  
             and ( c2.cont_no, c2.bond_seq) 
                            in (select c1.cont_no, c1.bond_seq
                                 from wp20prab b , ca01bond c1
                                 where b.use_yn=' '
                                 and b.clnt_id='700'
                                 and b.cust_id =v_cust_id
                                 and b.seq     =v_seq 
                                 and b.clnt_id =c1.clnt_id
                                 and b.loan_no =c1.loan_no
                                 and c1.end_divi='00'
                                 and c1.use_yn=' '
                                 )
              ; 
              
            -- 특수절차원장번호 삭제  
             UPDATE WP30TOSS w
                set  use_yn    = 'D'
                    ,dele_date  = sysdate
                    ,dele_Staf  = '90000'
                    ,chng_pgm_id = 'BTOIN01_D13'
               where 1=1
               and w.clnt_id = '700'
               and w.to_ledg_no = p_ad_to_ledg_no
            ;
              
            p_ret := '0000';
            p_msg := '정상적으로 처리되었습니다.';

   EXCEPTION
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

   END;



--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 회생 계좌별 상환내역 조회 (TS_160003)
--  작성일자 :  
--  작 성 자 : 
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_s16 (
    p_ret             OUT      VARCHAR2,                        -- 에러코드
    p_msg             OUT      VARCHAR2,                        -- 에러메세지
    s_cnt             OUT      NUMBER,                          -- 채무자 리스트
   
    i_clnt_id         IN       WP22PRTA.CLNT_ID%TYPE,
    i_to_ledg_no      IN       WP22PRTA.TO_LEDG_NO%TYPE,        -- 특수절차원장번호
    i_loan_no         IN       CA01BOND.LOAN_NO%TYPE,           -- 대출번호
    i_rcnt_admn_no    IN       VARCHAR2,                        -- 승인거래번호
    i_bond_type       IN       VARCHAR2,                        -- 특수채권구분코드
    i_recp_dgre       IN       VARCHAR2,                        -- 상환회차
    i_recv_ymd        IN       WP22PRTA.RECV_YMD%TYPE           -- 상환일자   
) IS
    v_cust_id       ca01bond.CUST_ID%type;
    v_rcnt_admn_no  to01loan.RCNT_ADMN_NO%type;
    v_bond_type     VARCHAR2(4);
    v_psrs_cnt      number(3);
    
    cust_err        exception;
    rcnt_err        exception;
    type_err        exception;

BEGIN   
    s_cnt:=-1;
    
    select count(*)
     into v_psrs_cnt
    from wp20praa wp20, wp20prab ab
    where wp20.use_yn   = ' '
    and wp20.clnt_id    = i_clnt_id
    and wp20.TO_LEDG_NO = i_to_ledg_no                    
    and ab.USE_YN       = ' '
    and wp20.clnt_id    = ab.CLNT_ID
    and wp20.CUST_ID    = ab.CUST_ID
    and wp20.SEQ        = ab.seq
    and ab.LOAN_NO      = i_loan_no
    ;    
    
    IF v_psrs_cnt > 0 THEN
       select wp20.cust_id
            , decode(ab.bond_type, '10','0001','20','0002','0001')
         into v_cust_id
            , v_bond_type
       from wp20praa wp20, wp20prab ab
       where wp20.use_yn   = ' '
       and wp20.clnt_id    = i_clnt_id
       and wp20.TO_LEDG_NO = i_to_ledg_no                    
       and ab.USE_YN       = ' '
       and wp20.clnt_id    = ab.CLNT_ID
       and wp20.CUST_ID    = ab.CUST_ID
       and wp20.SEQ        = ab.seq
       and ab.LOAN_NO      = i_loan_no
       and rownum =1
       ;
    ELSE    
       raise cust_err;
    END IF;
    
    
--    select lpad(nvl(to01.rcnt_admn_no,0),5,0)
--     into v_rcnt_admn_no
--    from to01loan to01, ca05clcu ca05                                                   
--    where to01.use_yn=' '			                                                    
--       and to01.acct_no     =i_loan_no	                                                
--       and to01.clnt_cust_no=ca05.clnt_cust_no	                                        
--       and ca05.clnt_id     = i_clnt_id			                                        
--       and ca05.cust_id     = v_cust_id				                                        
--       and to01.stdd_ymd = (select max( t.stdd_ymd)                                     
--                            from to01loan t			                                    
--                            where t.use_yn      =' '		                                    
--                            and t.acct_no       =to01.acct_no                                  
--                            and t.clnt_cust_no  =to01.clnt_cust_no)    
--    ;
--    
--    IF v_rcnt_admn_no <> i_rcnt_admn_no THEN
--        raise rcnt_err ;
--    END IF;
--    
--    IF v_bond_type <> i_bond_type THEN
--        raise type_err;
--    END IF;
--    
    
    SELECT count(*)
        into s_cnt
    FROM WP22PRTA w
    WHERE stdd_ymd  =to_char(sysdate,'yyyymmdd')
    AND clnt_id     = i_clnt_id
    and loan_no     = i_loan_no
    and recp_dgre   = to_number(i_recp_dgre)
    ;

    
    p_ret := '0000';
    p_msg := '조회가 완료되었습니다.';

EXCEPTION
    WHEN cust_err THEN
        s_cnt:=-1;
        p_ret := '3001';
        p_msg := '대상고객이 존재하지 않습니다.';
    WHEN rcnt_err THEN
        s_cnt:=-1;
        p_ret := '3002';
        p_msg := '승인거래번호가 일치하지 않습니다.'; 
    WHEN type_err THEN
        s_cnt:=-1;
        p_ret := '3002';
        p_msg := '등록된 특수채권구분코드가 일치하지 않습니다.';         
    WHEN NO_DATA_FOUND THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회할 건이 없습니다.';
    WHEN OTHERS THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회시에러 - ' || SQLCODE || ' ' || SQLERRM;
END;  


--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 회생 계좌별 상환내역 입력 (TS_160003)
--  작성일자 :  
--  작 성 자 : 
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_i16 (
        p_ret                  out     varchar2,  -- 리턴 값
        p_msg                  out     varchar2,  -- 에러 메세지        
        p_ad_to_ledg_no       in varchar2,   -- 특수절차원장번호    
        p_ad_loan_no          in varchar2,   -- 계좌번호            
        p_ad_rcnt_admn_no     in number,     -- 승인신청거래관리번호
        p_ad_bond_type        in varchar2,   -- 특수채권구분코드    
        p_ad_recp_dgre        in varchar2,   -- 상환회차            
        p_ad_recv_ymd         in varchar2,   -- 상환일자            
        p_ad_dlng_pamt        in number,     -- 관련계좌상환원금    
        p_nl_dlng_int         in number,     -- 관련계좌상환이자    
        p_ad_dele_ymd         in varchar2,   -- 삭제일자            
        p_ad_dele_yn          in varchar2    -- 삭제여부            

) IS 
    v_cust_id     wp22prta.cust_id%type;
    v_cust_name   wp20prab.cust_name%type;
    
    BEGIN
               
        p_ret := '3000';
        p_msg := '저장시 에러';    

        select  ab.CUST_ID
               ,ab.cust_name
        into v_cust_id
            ,v_cust_name
        from wp20praa wp20, wp20prab ab
        where wp20.use_yn   = ' '
        and wp20.clnt_id    = '700'
        and wp20.TO_LEDG_NO = p_ad_to_ledg_no                    
        and ab.USE_YN       = ' '
        and wp20.clnt_id    = ab.CLNT_ID
        and wp20.CUST_ID    = ab.CUST_ID
        and wp20.SEQ        = ab.seq
        and ab.LOAN_NO      = p_ad_loan_no
        ;                      
         
         
         INSERT INTO WP22PRTA (
                           stdd_ymd,                -- 기준일자
                           clnt_id,                 -- 위탁사ID
                           loan_no,                 -- 대출번호
                           recp_dgre,               -- 입금차수               
                           cust_id,                 -- 고객ID
                           aply_man_name,           -- 신청인명
                           recv_ymd,                -- 수납일자
                           dlng_pamt,               -- 처리원금
                           dlng_int,                -- 처리이자
                           curr_stat,               -- 현상태
                           err_cten,                -- 에러내용
                           to_ledg_no,              -- 특수절차원장번호
                           rcnt_admn_no,            -- 거래승인번호
                           bond_type,               -- 특수채권구분코드
                           inpt_date,               -- 입력일자
                           inpt_staf,               -- 입력사번
                           chng_pgm_id,             -- 변경프로그램ID
                           use_yn                   -- 사용여부
                    ) values (
                           to_char(sysdate, 'yyyymmdd'),
                           '700',
                           p_ad_loan_no,
                           to_number(p_ad_recp_dgre),
                           v_cust_id,  
                           v_cust_name,
                           p_ad_recv_ymd,
                           ROUND(nvl(p_ad_dlng_pamt,0)/1000000,0),
                           0,
                           '02', --정상처리
                           '',
                           p_ad_to_ledg_no,
                           to_number(p_ad_rcnt_admn_no),
                           decode(p_ad_bond_type, '0001','10','0002','20','10'),
                           sysdate,
                           '90000',
                           'BTOIN01_I16',
                           ' '
                    );
            p_ret := '0000';
            p_msg := '정상적으로 처리되었습니다.';

     
    EXCEPTION 
        WHEN no_data_found THEN
            p_ret := '3000';
            p_msg := '조회건이 없습니다.';
        WHEN others THEN
            p_ret := '3001';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

    END;






--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 회생 계좌별 상환내역 수정 (TS_160003)
--  작성일자 :  
--  작 성 자 : 
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_u16 (
        p_ret                  out     varchar2,  -- 리턴 값
        p_msg                  out     varchar2,  -- 에러 메세지        
        p_ad_to_ledg_no       in varchar2,   -- 특수절차원장번호    
        p_ad_loan_no          in varchar2,   -- 계좌번호            
        p_ad_rcnt_admn_no     in number,     -- 승인신청거래관리번호
        p_ad_bond_type        in varchar2,   -- 특수채권구분코드    
        p_ad_recp_dgre        in varchar2,   -- 상환회차            
        p_ad_recv_ymd         in varchar2,   -- 상환일자            
        p_ad_dlng_pamt        in number,     -- 관련계좌상환원금    
        p_nl_dlng_int         in number,     -- 관련계좌상환이자    
        p_ad_dele_ymd         in varchar2,   -- 삭제일자            
        p_ad_dele_yn          in varchar2    -- 삭제여부            

) IS 
    v_cust_id     wp22prta.cust_id%type;
    v_cust_name   wp20prab.cust_name%type;
    
    
    BEGIN     
        p_ret := '3000';
        p_msg := '저장시 에러';    

        select  ab.CUST_ID
               ,ab.cust_name
        into v_cust_id
            ,v_cust_name
        from wp20praa wp20, wp20prab ab
        where wp20.use_yn   = ' '
        and wp20.clnt_id    = '700'
        and wp20.TO_LEDG_NO = p_ad_to_ledg_no                    
        and ab.USE_YN       = ' '
        and wp20.clnt_id    = ab.CLNT_ID
        and wp20.CUST_ID    = ab.CUST_ID
        and wp20.SEQ        = ab.seq
        and ab.LOAN_NO      = p_ad_loan_no
        ;      
                                 
        UPDATE WP22PRTA
        SET  cust_id        = v_cust_id
            ,aply_man_name  = v_cust_name
            ,recv_ymd       = p_ad_recv_ymd
            ,dlng_pamt      =  ROUND(nvl(p_ad_dlng_pamt,0)/1000000,0)
            ,dlng_int       = 0
            ,curr_stat      = '02'
            ,err_cten       = ''
            ,to_ledg_no     = p_ad_to_ledg_no
            ,rcnt_admn_no   = to_number(p_ad_rcnt_admn_no)
            ,bond_type      = decode(p_ad_bond_type, '0001','10','0002','20','10')
            ,chng_date      = sysdate
            ,chng_staf      = '90000'
            ,chng_pgm_id    = 'BTOIN01_U16'
            ,use_yn         = ' '
        WHERE stdd_ymd    =to_char(sysdate,'yyyymmdd')
          AND clnt_id     ='700'
          and loan_no     = p_ad_loan_no
          and recp_dgre   = to_number(p_ad_recp_dgre)
        ;
       
       p_ret := '0000';
       p_msg := '정상적으로 처리되었습니다.';   
    EXCEPTION 
        WHEN no_data_found THEN
            p_ret := '3000';
            p_msg := '조회건이 없습니다.';
        WHEN others THEN
            p_ret := '3001';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

    END;

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 회생 계좌별 상환내역 삭제 (TS_160003)
--  작성일자 :  
--  작 성 자 : 
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_d16 (
        p_ret                  out     varchar2,  -- 리턴 값
        p_msg                  out     varchar2,  -- 에러 메세지        
        p_ad_to_ledg_no       in varchar2,   -- 특수절차원장번호    
        p_ad_loan_no          in varchar2,   -- 계좌번호            
        p_ad_rcnt_admn_no     in number,     -- 승인신청거래관리번호
        p_ad_bond_type        in varchar2,   -- 특수채권구분코드    
        p_ad_recp_dgre        in varchar2,   -- 상환회차            
        p_ad_recv_ymd         in varchar2,   -- 상환일자            
        p_ad_dlng_pamt        in number,     -- 관련계좌상환원금    
        p_nl_dlng_int         in number,     -- 관련계좌상환이자    
        p_ad_dele_ymd         in varchar2,   -- 삭제일자            
        p_ad_dele_yn          in varchar2    -- 삭제여부            

) IS 

    BEGIN     
        p_ret := '3000';
        p_msg := '저장시 에러';    

       -- WP22PRTA 토스 개인회생 수납테이블    
        UPDATE WP22PRTA
          set    curr_stat      = '04'
               , dele_staf      = '90000'
               , dele_date      = sysdate
               , chng_pgm_id    = 'BTOIN01_D16'
               , use_yn         = 'D'
        WHERE 1=1
        and  stdd_ymd   =to_char(sysdate,'yyyymmdd')
        AND clnt_id     ='700'
        and loan_no     = p_ad_loan_no
        and recp_dgre   = ROUND(nvl(to_number(p_ad_recp_dgre),0),0)
        ;      
    
      p_ret := '0000';
      p_msg := '정상적으로 처리되었습니다.';     
    EXCEPTION 
        WHEN no_data_found THEN
            p_ret := '3000';
            p_msg := '조회건이 없습니다.';
        WHEN others THEN
            p_ret := '3001';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

    END;

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 신용회복 신청/확정 조회 (TS_190003)
--  작성일자 : 
--  작 성 자 : 
--  내    용 : 
--------------------------------------------------------------------------------
PROCEDURE btoin01_s19 (
    p_ret             OUT      VARCHAR2,                        -- 에러코드
    p_msg             OUT      VARCHAR2,                        -- 에러메세지
    s_cnt             OUT      NUMBER,                          -- 채무자 리스트

    i_clnt_id         IN       CA01BOND.clnt_id%TYPE,           -- 위탁사ID
    i_clnt_cust_no    IN       CA05CLCU.CLNT_CUST_NO%TYPE,      -- 고객번호
    i_loan_no         IN       CA01BOND.LOAN_NO%TYPE,
    i_rcnt_admn_no    IN       TO01LOAN.RCNT_ADMN_NO%TYPE,
    i_wkot_divi       IN       WP01WOAA.WKOT_DIVI%TYPE
) IS
    v_cust_id       ca01bond.CUST_ID%type;
    v_cust_cnt      number(3);
    v_loan_cnt      number(3);
    
    cust_err        exception;
    loan_err        exception;

BEGIN   
    s_cnt:=-1;
    SELECT count(*)
        into v_cust_cnt
    FROM CA05CLCU ca05  --, to01loan to01
    WHERE ca05.CLNT_ID       =i_clnt_id
    AND ca05.CLNT_CUST_NO    =i_clnt_cust_no
--    AND TO01.USE_YN=' '
--    and to01.acct_no= i_loan_no
--    and to01.clnt_cust_no =  ca05.CLNT_CUST_NO
--    and to01.rcnt_admn_no =   i_rcnt_admn_no
--    and to01.stdd_ymd = (select max( t.stdd_ymd)                                     
--                            from to01loan t			                                    
--                            where t.use_yn=' '		                                    
--                            and t.acct_no=to01.acct_no                                  
--                            and t.clnt_cust_no=to01.clnt_cust_no)
    
    ;
    
    IF v_cust_cnt=0 THEN
        raise cust_err;
    ELSE     
         SELECT CUST_ID
        into v_cust_id
        FROM CA05CLCU
        WHERE CLNT_ID       =i_clnt_id
        AND CLNT_CUST_NO    =i_clnt_cust_no;        
    END IF;
    
    SELECT count(*)
        into v_loan_cnt
    FROM CA01BOND c1, CA02RELN c2
    where 1=1
    and c1.use_yn=' '
    and c2.use_yn=' '
    and c1.clnt_id  =c2.clnt_id
    and c1.cont_no  =c2.cont_no
    and c1.bond_seq =c2.bond_seq
    and c2.clnt_id  = i_clnt_id
    and c2.cust_id  = v_cust_id
    and c1.loan_no  = i_loan_no
    ;
    
    IF v_loan_cnt =0    then 
        raise loan_err;
    END IF;
    
    
    select count(*)
     into s_cnt
    from wp01woaa wp01
    where wp01.use_yn=' '
    and wp01.clnt_id = i_clnt_id
    and wp01.cust_id = v_cust_id
    and wp01.loan_no = i_loan_no 
    and wp01.wkot_divi = i_wkot_divi
    and wp01.seq     = (select max(w.seq)
                        from wp01woaa w
                        where w.use_yn=' '
                        and w.clnt_id=wp01.CLNT_ID
                        and w.cust_id=wp01.cust_id
                        and w.loan_no=wp01.loan_no)                        
    ;                   
    
    p_ret := '0000';
    p_msg := '조회가 완료되었습니다.';

EXCEPTION
    WHEN cust_err THEN
        s_cnt:=-1;
        p_ret := '3001';
        p_msg := '대상고객이 존재하지 않습니다.';
    WHEN loan_err THEN
        s_cnt:=-1;
        p_ret := '3002';
        p_msg := '해당 대출번호가 존재하지 않습니다.';   
    WHEN NO_DATA_FOUND THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회할 건이 없습니다.';
    WHEN OTHERS THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회시에러 - ' || SQLCODE || ' ' || SQLERRM;
END; 


--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 신용회복 신청/확정 입력(TS_190003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_i19 (
        p_ret                   out varchar2,   -- 리턴 값
        p_msg                   out varchar2,   -- 에러 메세지        
        
        p_ad_clnt_cust_no       in varchar2,   -- 고객번호                
        p_ad_loan_no            in varchar2,   -- 계좌번호                
        p_ad_rcnt_admn_no       in number  ,   -- 승인신청거래관리번호    
        p_ad_wkot_divi          in varchar2,   -- 개인신용회복지원구분코드
        p_ad_bond_type          in varchar2,   -- 채권종류코드            
        p_ad_aply_notc_ymd      in varchar2,   -- 시작일자                
        p_ad_opin_sbms_ymd1     in varchar2,   -- 채권신고신청일자        
        p_ad_agre_ymd           in varchar2,   -- 지원확정통지일자        
        p_ad_laps_ymd           in varchar2,   -- 지원효력상실일자        
        p_ad_bond_ramt1         in number,     -- 채권신고원금            
        p_nl_bond_eamt          in number,     -- 채권신고가지급금액      
        p_nl_bond_int           in number,     -- 채권신고정상이자        
        p_nl_bond_ovrd_int      in number,     -- 채권신고연체이자        
        p_ad_redu_pamt          in number,     -- 면제원금                
        p_nl_redu_eamt          in number,     -- 면제가지급금액          
        p_ad_redu_norm_int      in number,     -- 면제정상이자            
        p_ad_redu_ovrd_int      in number,     -- 면제연체이자            
        p_ad_bond_ramt2         in number,     -- 지원확정당시원금        
        p_nl_fixd_eamt          in number,     -- 지원확정당시가지급금액  
        p_nl_fixd_int           in number,     -- 지원확정당시정상이자    
        p_nl_fixd_ovrd_int      in number,     -- 지원확정당시연체이자    
        p_nl_agre_strt_ymd      in varchar2,   -- 신규약정채권개시일자    
        p_ad_frst_paym_ymd      in varchar2,   -- 신규약정채권최초변제일자
        p_ad_agre_term          in number,     -- 신규약정채권상환개월수  
        p_ad_evmt_paym_ymd      in varchar2,   -- 신규약정채권상환일자    
        p_ad_rpmt_cycl          in varchar2,   -- 신규약정채권상환주기코드
        p_ad_agre_aplc_rate     in number,     -- 신규약정채권확정이율    
        p_crss_pamt             in number,     -- 신규약정채권기표원금    
        p_crss_int              in number,     -- 신규약정채권기표이자    
        p_ad_rpmt_end_ymd       in varchar2,   -- 신규약정채권최종상환일자
        p_ad_wkot_end_ymd1      in varchar2,   -- 완제일자                
        p_crss_dlbr_yymm        in varchar2,   -- 확정년도                
        p_crss_cseq             in number,     -- 확정회차                
        p_ad_wkot_step          in varchar2,   -- 개인신용회복지원상태코드
        p_ad_wkot_memo          in varchar2,   -- 관리사항메모내용        
        p_ad_re_laps_divi       in varchar2,   -- 실효부활구분코드        
        p_ad_agre_conc_ymd      in varchar2,   -- 합의서체결일자          
        p_ad_acct_divi_cd       in varchar2,   -- 개인신용회복계좌구분코드
        p_ad_inpt_ymd           in varchar2,   -- 신청등록일자            
        p_ad_opin_sbms_ymd2     in varchar2,   -- 의견제출기한일자        
        p_ad_opin_sbms_inpt_ymd in varchar2,   -- 의견제출기한입력일자    
        p_ad_dcus_ymd           in varchar2,   -- 의결행사일자            
        p_ad_dcus_inpt_ymd      in varchar2,   -- 의결행사입력일자        
        p_ad_dcsn_agre_yn       in varchar2,   -- 동의여부                
        p_ad_wkot_end_ymd2       in varchar2,   -- 종결일자                
        p_ad_dele_ymd           in varchar2,   -- 삭제일자                
        p_ad_dele_yn            in varchar2,   -- 삭제여부                
        p_wkot_step             in varchar2,   -- 에이앤디 워크아웃단계  (가공) 
        p_dh_end_divi           in varchar2,   -- 워크아웃 상세 종결구분 (가공)
        p_re_agre_yn            in varchar2    -- 재약정여부 (가공)              
) IS 

    v_cust_id       wp01woaa.cust_id%type;
    v_seq           wp01woaa.seq%type;
    v_cont_no       wp01woaa.cont_no%type;
    v_bond_seq      wp01woaa.bond_seq%type;
    v_debt_divi     wp01woaa.DEBT_DIVI%type;
                      
    BEGIN            
        p_ret := '3000';
        p_msg := '저장시 에러';  
        
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;        
        
        select nvl(max(w.seq),0)+1
               into v_seq
            from wp01woaa w
            where 1=1
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
            and w.loan_no   =   p_ad_loan_no
        ;  
        
        select  c1.cont_no
               ,c1.bond_seq
               ,c2.debt_divi
          into  v_cont_no
               ,v_bond_seq
               ,v_debt_divi
        from ca01bond c1, ca02reln c2
           where c1.use_yn  =' '
           and c2.use_yn=' '
           and c1.clnt_id   = c2.CLNT_ID
           and c1.cont_no   = c2.CONT_NO
           and c1.bond_seq  = c2.bond_Seq
           and c1.clnt_id   ='700'
           and c1.end_divi  ='00'
           and c1.loan_no   = p_ad_loan_no
           and c2.cust_id   = v_cust_id 
           and rownum =1
        ;   
     
        --1)  WP01WOAA 신규입력
        -- SEQ, DEBT_DIVI, CONT_NO, BOND_SEQ 조회하여 입력 
        INSERT INTO WP01WOAA (   CLNT_ID  ,CUST_ID    ,SEQ
                                ,LOAN_NO  ,DEBT_DIVI  ,WKOT_DIVI                            
                                ,CONT_NO  ,BOND_SEQ
                                ,APLY_NOTC_DATE ,APLY_NOTC_INPT_DATE    ,APLY_NOTC_INPT_STAF
                                ,OPIN_SBMS_DATE ,OPIN_SBMS_INPT_DATE    ,OPIN_SBMS_INPT_STAF
                                ,DCUS_DATE      ,DCUS_INPT_DATE         ,DCUS_INPT_STAF
                                ,DCSN_AGRE_YN   ,RE_AGRE_YN             ,AGRE_CONC_YMD
                                ,AGRE_DATE      ,AGRE_INPT_DATE         ,AGRE_INPT_STAF
                                ,END_DATE       ,END_INPT_DATE          ,END_INPT_STAF
                                ,END_DIVI       ,DH_END_DIVI        
                                -- 면제원금,면제정상이자,면제연체이자
                                ,REDU_PAMT      ,REDU_NORM_INT          ,REDU_OVRD_INT
                                -- 최초변제일,상환개월수,상환일자
                                ,FRST_PAYM_YMD  ,AGRE_TERM              ,EVMT_PAYM_YMD
                                -- 상환주기,최종변제일
                                ,RPMT_CYCL      ,RPMT_END_YMD
                                -- 확정이율,확정원금,확정이자
                                ,AGRE_APLC_RATE ,FIXD_PAMT              ,FIXD_INT
                                -- 심의차수, 메모
                                ,DLBR_DGRE      ,WKOT_MEMO
                                ,INPT_DATE      ,INPT_STAF              ,CHNG_PGM_ID
                                ,CHNG_DATE      ,CHNG_STAF              ,USE_YN )
                    VALUES (    '700'           ,v_cust_id      ,v_seq
                                ,p_ad_loan_no   ,v_debt_divi    ,decode(p_ad_wkot_divi, '06','06','07','07','08','08','01') 
                                ,v_cont_no      ,v_bond_seq
                                ,to_date(p_ad_aply_notc_ymd,'yyyymmdd')
                                ,case when p_ad_aply_notc_ymd is not null then sysdate else to_date('')  end
                                ,case when p_ad_aply_notc_ymd is not null then '90000' else '' end
                                ,to_date(p_ad_opin_sbms_ymd2,'yyyymmdd')
                                ,case when p_ad_opin_sbms_ymd2 is not null then sysdate else to_date('')  end
                                ,case when p_ad_opin_sbms_ymd2 is not null then '90000' else '' end
                                ,to_date(p_ad_dcus_ymd,'yyyymmdd')                       
                                ,case when p_ad_dcus_ymd is not null then sysdate else to_date('')  end
                                ,case when p_ad_dcus_ymd is not null then '90000' else '' end
                                ,p_ad_dcsn_agre_yn  ,p_re_agre_yn ,p_ad_agre_conc_ymd
                                ,to_date(p_ad_agre_ymd,'yyyymmdd')                             
                                ,case when p_ad_agre_ymd is not null then sysdate else to_date('')  end
                                ,case when p_ad_agre_ymd is not null then '90000' else '' end
                                ,to_date(p_ad_wkot_end_ymd2,'yyyymmdd')                             
                                ,case when p_ad_wkot_end_ymd2 is not null then sysdate else to_date('')  end
                                ,case when p_ad_wkot_end_ymd2 is not null then '90000' else '' end
                                ,p_wkot_step    ,p_dh_end_divi
                                -- 면제원금,면제정상이자,면제연체이자
                                ,ROUND(nvl(p_ad_redu_pamt,0)/100,0)  , ROUND(nvl(p_ad_redu_norm_int,0)/100000,0)     ,ROUND(nvl(p_ad_redu_ovrd_int,0)/100000,0)  
                                -- 최초변제일,상환개월수,상환일자
                                ,p_ad_frst_paym_ymd  ,p_ad_agre_term     ,p_ad_evmt_paym_ymd
                                -- 상환주기,최종변제일
                                ,p_ad_rpmt_cycl      ,p_ad_rpmt_end_ymd
                                -- 확정이율,확정원금,확정이자
                                ,ROUND(nvl(p_ad_agre_aplc_rate,0)/100000,2)  ,ROUND(nvl(p_crss_pamt,0)/100,0)    ,ROUND(nvl(p_crss_int,0)/100000,0) 
                                -- 심의차수,메모
                                ,to_number(p_crss_cseq)    ,replace(replace(replace(p_ad_wkot_memo,chr(13),' '),chr(10),' '),chr(9),' ')	    
                                ,sysdate      ,'90000'              ,'BTOIN01_I19'
                                ,sysdate      ,'90000'              ,' ' 
                        );

           
             -- 2) CA02RELN 단계 수정
             -- CONT_NO, BOND_SEQ 조회하여 수정 
             update ca02reln c2
             set  c2.wkot_step       = case when c2.wkot_step<> p_wkot_step or c2.wkot_step is null 
                                         then p_wkot_step else c2.wkot_step end                                        
                , c2.chng_pgm_id     = 'BTOIN01_I19'
                , c2.chng_date       = sysdate
                , c2.chng_staf       = '90000'
              where 1=1
              and c2.use_yn     =' '
              and c2.clnt_id    ='700'
              and c2.cont_no    =v_cont_no
              and c2.bond_seq   =v_bond_seq
              and c2.cust_id    =v_cust_id
              ; 
          
            p_ret := '0000';
            p_msg := '정상적으로 처리되었습니다.';        

        

 EXCEPTION
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

 END;   



--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 신용회복 신청/확정 수정 (TS_190003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_u19 (
        p_ret                   out varchar2,   -- 리턴 값
        p_msg                   out varchar2,   -- 에러 메세지        
        
        p_ad_clnt_cust_no       in varchar2,   -- 고객번호                
        p_ad_loan_no            in varchar2,   -- 계좌번호                
        p_ad_rcnt_admn_no       in number  ,   -- 승인신청거래관리번호    
        p_ad_wkot_divi          in varchar2,   -- 개인신용회복지원구분코드
        p_ad_bond_type          in varchar2,   -- 채권종류코드            
        p_ad_aply_notc_ymd      in varchar2,   -- 시작일자                
        p_ad_opin_sbms_ymd1     in varchar2,   -- 채권신고신청일자        
        p_ad_agre_ymd           in varchar2,   -- 지원확정통지일자        
        p_ad_laps_ymd           in varchar2,   -- 지원효력상실일자        
        p_ad_bond_ramt1         in number,     -- 채권신고원금            
        p_nl_bond_eamt          in number,     -- 채권신고가지급금액      
        p_nl_bond_int           in number,     -- 채권신고정상이자        
        p_nl_bond_ovrd_int      in number,     -- 채권신고연체이자        
        p_ad_redu_pamt          in number,     -- 면제원금                
        p_nl_redu_eamt          in number,     -- 면제가지급금액          
        p_ad_redu_norm_int      in number,     -- 면제정상이자            
        p_ad_redu_ovrd_int      in number,     -- 면제연체이자            
        p_ad_bond_ramt2         in number,     -- 지원확정당시원금        
        p_nl_fixd_eamt          in number,     -- 지원확정당시가지급금액  
        p_nl_fixd_int           in number,     -- 지원확정당시정상이자    
        p_nl_fixd_ovrd_int      in number,     -- 지원확정당시연체이자    
        p_nl_agre_strt_ymd      in varchar2,   -- 신규약정채권개시일자    
        p_ad_frst_paym_ymd      in varchar2,   -- 신규약정채권최초변제일자
        p_ad_agre_term          in number,     -- 신규약정채권상환개월수  
        p_ad_evmt_paym_ymd      in varchar2,   -- 신규약정채권상환일자    
        p_ad_rpmt_cycl          in varchar2,   -- 신규약정채권상환주기코드
        p_ad_agre_aplc_rate     in number,     -- 신규약정채권확정이율    
        p_crss_pamt             in number,     -- 신규약정채권기표원금    
        p_crss_int              in number,     -- 신규약정채권기표이자    
        p_ad_rpmt_end_ymd       in varchar2,   -- 신규약정채권최종상환일자
        p_ad_wkot_end_ymd1      in varchar2,   -- 완제일자                
        p_crss_dlbr_yymm        in varchar2,   -- 확정년도                
        p_crss_cseq             in number,     -- 확정회차                
        p_ad_wkot_step          in varchar2,   -- 개인신용회복지원상태코드
        p_ad_wkot_memo          in varchar2,   -- 관리사항메모내용        
        p_ad_re_laps_divi       in varchar2,   -- 실효부활구분코드        
        p_ad_agre_conc_ymd      in varchar2,   -- 합의서체결일자          
        p_ad_acct_divi_cd       in varchar2,   -- 개인신용회복계좌구분코드
        p_ad_inpt_ymd           in varchar2,   -- 신청등록일자            
        p_ad_opin_sbms_ymd2     in varchar2,   -- 의견제출기한일자        
        p_ad_opin_sbms_inpt_ymd in varchar2,   -- 의견제출기한입력일자    
        p_ad_dcus_ymd           in varchar2,   -- 의결행사일자            
        p_ad_dcus_inpt_ymd      in varchar2,   -- 의결행사입력일자        
        p_ad_dcsn_agre_yn       in varchar2,   -- 동의여부                
        p_ad_wkot_end_ymd2      in varchar2,   -- 종결일자                
        p_ad_dele_ymd           in varchar2,   -- 삭제일자                
        p_ad_dele_yn            in varchar2,   -- 삭제여부                
        p_wkot_step             in varchar2,   -- 에이앤디 워크아웃단계  (가공) 
        p_dh_end_divi           in varchar2,   -- 워크아웃 상세 종결구분 (가공)
        p_re_agre_yn            in varchar2    -- 재약정여부 (가공)               
) IS 
    v_cust_id       wp01woaa.cust_id%type;
    v_seq           wp01woaa.seq%type;
    v_cont_no       wp01woaa.cont_no%type;
    v_bond_seq      wp01woaa.bond_seq%type;
                      
    BEGIN
       p_ret := '3000';
       p_msg := '저장시 에러';  
        
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;        
        
        select w.SEQ
                ,w.cont_no
                ,w.bond_seq
               into v_seq
               ,v_cont_no
               ,v_bond_seq
            from wp01woaa w
            where 1=1
            and w.use_yn=' '
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
            and w.loan_no   =   p_ad_loan_no
            and w.wkot_divi =   p_ad_wkot_divi
            and w.seq       = (select max(wp01.seq)
                                from wp01woaa wp01
                                where wp01.clnt_id= w.clnt_id
                                and wp01.cust_id= w.cust_id
                                and wp01.loan_no= w.loan_no )
        ;  

        -- 1) WP01WOAA 수정
        -- SEQ 조회하여 수정 
             update wp01woaa            
              set    wkot_divi       = decode(p_ad_wkot_divi, '06','06','07','07','08','08','01') 
                   , aply_notc_date  = TO_DATE(p_ad_aply_notc_ymd, 'yyyymmdd')
                   , aply_notc_inpt_date  = case when aply_notc_date is null and p_ad_aply_notc_ymd is not null then sysdate else aply_notc_inpt_date end 
                   , aply_notc_inpt_staf  = case when aply_notc_date is null and p_ad_aply_notc_ymd is not null then '90000' else aply_notc_inpt_staf end 
                   , opin_sbms_date  = TO_DATE(p_ad_opin_sbms_ymd2, 'yyyymmdd')
                   , opin_sbms_inpt_date = case when opin_sbms_date is null and p_ad_opin_sbms_ymd2 is not null then sysdate else opin_sbms_inpt_date end 
                   , opin_sbms_inpt_staf = case when opin_sbms_date is null and p_ad_opin_sbms_ymd2 is not null then '90000' else opin_sbms_inpt_staf end 
                   , dcus_date       = TO_DATE(p_ad_dcus_ymd, 'yyyymmdd')
                   , dcus_inpt_date  = case when dcus_date is null and p_ad_dcus_ymd is not null then sysdate else dcus_inpt_date end  
                   , dcus_inpt_staf  = case when dcus_date is null and p_ad_dcus_ymd is not null then '90000' else dcus_inpt_staf end    
                   , agre_date       = TO_DATE(p_ad_agre_ymd, 'yyyymmdd') --약정일자 , 확정통지일자
                   , agre_inpt_date  = case when agre_date is null and p_ad_agre_ymd is not null then sysdate else agre_inpt_date end 
                   , agre_inpt_staf  = case when agre_date is null and p_ad_agre_ymd is not null then '90000' else agre_inpt_staf end    
                   , end_date        = TO_DATE(p_ad_wkot_end_ymd2, 'yyyymmdd') 
                   , end_inpt_date   = case when end_date is null and p_ad_wkot_end_ymd2 is not null then sysdate else end_inpt_date end 
                   , end_inpt_staf   = case when end_date is null and p_ad_wkot_end_ymd2 is not null then '90000' else end_inpt_staf end    
                   , redu_pamt       = ROUND(nvl(p_ad_redu_pamt,0)/100,0)
                   , redu_norm_int   = ROUND(nvl(p_ad_redu_norm_int,0)/100000,0)                    
                   , redu_ovrd_int   = ROUND(nvl(p_ad_redu_ovrd_int,0)/100000,0)      
                   , frst_paym_ymd   = p_ad_frst_paym_ymd   
                   , agre_term       = p_ad_agre_term  
                   , evmt_paym_ymd   = p_ad_evmt_paym_ymd 
                   , rpmt_cycl       = p_ad_rpmt_cycl    
                   , agre_aplc_rate  = ROUND(nvl(p_ad_agre_aplc_rate,0)/100000,2)
                   , rpmt_end_ymd    = p_ad_rpmt_end_ymd
                   , wkot_memo       = replace(replace(replace(p_ad_wkot_memo,chr(13),' '),chr(10),' '),chr(9),' ')	
                   , agre_conc_ymd   = p_ad_agre_conc_ymd 
                   , DLBR_DGRE       = to_number(p_crss_cseq)
                   , FIXD_PAMT       = ROUND(nvl(p_crss_pamt,0)/100,0) 
                   , FIXD_INT        = ROUND(nvl(p_crss_int,0)/100000,0) 
                   , dcsn_agre_yn    = p_ad_dcsn_agre_yn
                   , end_divi        = p_wkot_step 
                   , dh_end_divi     = p_dh_end_divi
                   , re_agre_yn      = case when p_re_agre_yn is not null and p_wkot_step='50' then p_re_agre_yn else re_agre_yn end
                   , chng_pgm_id     = 'BTOIN01_U19'
                   , chng_date       = sysdate
                   , chng_staf       = '90000'
             where clnt_id   = '700'	                                     
               and loan_no   = p_ad_loan_no
               and cust_id   = v_cust_id
               and seq       = v_seq
               ;	   
             
              -- 2) WP03CRSSA 수정
              --   LOAN_NO, CUST_ID, DLBR_YYMM, CSEQ 존재하면 수정
             merge into wp03crssa w3
             using dual
             on (      w3.clnt_id       = '700'	                                     
                   and w3.acct_no      = p_ad_loan_no
                   and w3.cust_id      = v_cust_id
                   and w3.dlbr_yymm    = p_crss_dlbr_yymm
                   and w3.cseq         = to_number(p_crss_cseq) )
             when matched  then     
             update 
              set    w3.pamt            = ROUND(nvl(p_crss_pamt,0)/100,0)     
                   , w3.int             = ROUND(nvl(p_crss_int,0)/100000,0) 
                   , w3.chng_pgm_id     = 'BTOIN01_U19'
                   , w3.chng_date       = sysdate
                   , w3.chng_staf       = '90000'
             ;
               
            -- 3) CA02RELN 단계 수정
            --    CONT_NO, BOND_SEQ 조회하여 수정
             update ca02reln c2
             set  c2.wkot_step       = case when wkot_step<>p_wkot_step or wkot_step is null 
                                         then p_wkot_step else c2.wkot_step end                                        
                , c2.chng_pgm_id     = 'BTOIN01_U19'
                , c2.chng_date       = sysdate
                , c2.chng_staf       = '90000'
              where 1=1
              and c2.use_yn     =' '
              and c2.clnt_id    ='700'
              and c2.cont_no    =v_cont_no
              and c2.bond_seq   =v_bond_seq
              and c2.cust_id    =v_cust_id
              ; 
         
            p_ret := '0000';
            p_msg := '정상적으로 처리되었습니다.';        
 EXCEPTION
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

 END;   
--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 신용회복 신청/확정 삭제 (TS_190003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_d19 (
        p_ret                   out varchar2,   -- 리턴 값
        p_msg                   out varchar2,   -- 에러 메세지        
        
        p_ad_clnt_cust_no       in varchar2,   -- 고객번호                
        p_ad_loan_no            in varchar2,   -- 계좌번호                
        p_ad_rcnt_admn_no       in number  ,   -- 승인신청거래관리번호    
        p_ad_wkot_divi          in varchar2,   -- 개인신용회복지원구분코드
        p_ad_bond_type          in varchar2,   -- 채권종류코드            
        p_ad_aply_notc_ymd      in varchar2,   -- 시작일자                
        p_ad_opin_sbms_ymd1     in varchar2,   -- 채권신고신청일자        
        p_ad_agre_ymd           in varchar2,   -- 지원확정통지일자        
        p_ad_laps_ymd           in varchar2,   -- 지원효력상실일자        
        p_ad_bond_ramt1         in number,     -- 채권신고원금            
        p_nl_bond_eamt          in number,     -- 채권신고가지급금액      
        p_nl_bond_int           in number,     -- 채권신고정상이자        
        p_nl_bond_ovrd_int      in number,     -- 채권신고연체이자        
        p_ad_redu_pamt          in number,     -- 면제원금                
        p_nl_redu_eamt          in number,     -- 면제가지급금액          
        p_ad_redu_norm_int      in number,     -- 면제정상이자            
        p_ad_redu_ovrd_int      in number,     -- 면제연체이자            
        p_ad_bond_ramt2         in number,     -- 지원확정당시원금        
        p_nl_fixd_eamt          in number,     -- 지원확정당시가지급금액  
        p_nl_fixd_int           in number,     -- 지원확정당시정상이자    
        p_nl_fixd_ovrd_int      in number,     -- 지원확정당시연체이자    
        p_nl_agre_strt_ymd      in varchar2,   -- 신규약정채권개시일자    
        p_ad_frst_paym_ymd      in varchar2,   -- 신규약정채권최초변제일자
        p_ad_agre_term          in number,     -- 신규약정채권상환개월수  
        p_ad_evmt_paym_ymd      in varchar2,   -- 신규약정채권상환일자    
        p_ad_rpmt_cycl          in varchar2,   -- 신규약정채권상환주기코드
        p_ad_agre_aplc_rate     in number,     -- 신규약정채권확정이율    
        p_crss_pamt             in number,     -- 신규약정채권기표원금    
        p_crss_int              in number,     -- 신규약정채권기표이자    
        p_ad_rpmt_end_ymd       in varchar2,   -- 신규약정채권최종상환일자
        p_ad_wkot_end_ymd1      in varchar2,   -- 완제일자                
        p_crss_dlbr_yymm        in varchar2,   -- 확정년도                
        p_crss_cseq             in number,     -- 확정회차                
        p_ad_wkot_step          in varchar2,   -- 개인신용회복지원상태코드
        p_ad_wkot_memo          in varchar2,   -- 관리사항메모내용        
        p_ad_re_laps_divi       in varchar2,   -- 실효부활구분코드        
        p_ad_agre_conc_ymd      in varchar2,   -- 합의서체결일자          
        p_ad_acct_divi_cd       in varchar2,   -- 개인신용회복계좌구분코드
        p_ad_inpt_ymd           in varchar2,   -- 신청등록일자            
        p_ad_opin_sbms_ymd2     in varchar2,   -- 의견제출기한일자        
        p_ad_opin_sbms_inpt_ymd in varchar2,   -- 의견제출기한입력일자    
        p_ad_dcus_ymd           in varchar2,   -- 의결행사일자            
        p_ad_dcus_inpt_ymd      in varchar2,   -- 의결행사입력일자        
        p_ad_dcsn_agre_yn       in varchar2,   -- 동의여부                
        p_ad_wkot_end_ymd2      in varchar2,   -- 종결일자                
        p_ad_dele_ymd           in varchar2,   -- 삭제일자                
        p_ad_dele_yn            in varchar2,   -- 삭제여부                
        p_wkot_step             in varchar2,   -- 에이앤디 워크아웃단계  (가공) 
        p_dh_end_divi           in varchar2,   -- 워크아웃 상세 종결구분 (가공)
        p_re_agre_yn            in varchar2    -- 재약정여부 (가공)                 
) IS 
    v_cust_id       wp01woaa.cust_id%type;
    v_seq           wp01woaa.seq%type;
    v_cont_no       wp01woaa.cont_no%type;
    v_bond_seq      wp01woaa.bond_seq%type;
                      
    BEGIN
       p_ret := '3000';
       p_msg := '저장시 에러';  
        
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;        
        
        select   w.seq
                ,w.cont_no
                ,w.bond_seq
               into v_seq
               ,v_cont_no
               ,v_bond_seq
            from wp01woaa w
            where 1=1
            and w.use_yn=' '
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
            and w.loan_no   =   p_ad_loan_no
            and w.wkot_divi =   p_ad_wkot_divi
            and w.seq       = (select max(wp01.seq)
                                from wp01woaa wp01
                                where wp01.clnt_id= w.clnt_id
                                and wp01.cust_id= w.cust_id
                                and wp01.loan_no= w.loan_no )
        ;  
    
           -- 1) WP01WOAA 수정
           -- SEQ 조회하여 수정 
             update wp01woaa            
              set    chng_pgm_id     = 'BTOIN01_D19'
                   , dele_date       = sysdate
                   , dele_staf       = '90000'
                   , use_yn          = 'D'
             where clnt_id   = '700'	                                     
               and loan_no   = p_ad_loan_no
               and cust_id   = v_cust_id
               and seq       <= v_seq
               and use_yn    =' '
               ;	   
                
           -- 2) CA02RELN 단계 수정
           -- CONT_NO, BOND_SEQ 조회하여 수정
             update ca02reln c2
             set  wkot_step       = ''                                     
                , chng_pgm_id     = 'BTOIN01_D19'
                , chng_date       = sysdate
                , chng_staf       = '90000'
              where 1=1
              and c2.use_yn     =' '
              and c2.clnt_id    ='700'
              and c2.cont_no    =v_cont_no
              and c2.bond_seq   =v_bond_seq
              and c2.cust_id    =v_cust_id
              ; 
          
            p_ret := '0000';
            p_msg := '정상적으로 처리되었습니다.';        

 EXCEPTION
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

 END;   

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 상환내역 조회  (TS_220003)
--  작성일자 :  
--  작 성 자 : 
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_s22 (
    p_ret             OUT      VARCHAR2,                        -- 에러코드
    p_msg             OUT      VARCHAR2,                        -- 에러메세지
    s_cnt             OUT      NUMBER,                          -- 채무자 리스트

    i_clnt_id         IN       CA01BOND.clnt_id%TYPE,           -- 위탁사ID
    i_clnt_cust_no    IN       CA05CLCU.CLNT_CUST_NO%TYPE,      -- 고객번호
    i_loan_no         IN       CA01BOND.LOAN_NO%TYPE,           -- 대출번호
    i_recp_dgre       IN       WP01WOAB.RECP_DGRE%TYPE          -- 납부회차
) IS
    v_cust_id       ca01bond.CUST_ID%type;
    v_cust_cnt      number(3);
    v_loan_cnt      number(3);
    
    cust_err        exception;
    loan_err        exception;

BEGIN   
    s_cnt:=-1;
    SELECT count(*)
        into v_cust_cnt
    FROM CA05CLCU
    WHERE CLNT_ID       =i_clnt_id
    AND CLNT_CUST_NO    =i_clnt_cust_no;
    
    IF v_cust_cnt=0 THEN
        raise cust_err;
    ELSE     
         SELECT CUST_ID
        into v_cust_id
        FROM CA05CLCU
        WHERE CLNT_ID       =i_clnt_id
        AND CLNT_CUST_NO    =i_clnt_cust_no;        
    END IF;
    
    SELECT count(*)
        into v_loan_cnt
    FROM CA01BOND c1, CA02RELN c2, WP01WOAA W
    where 1=1
    and c1.use_yn=' '
    and c2.use_yn=' '
    and c1.clnt_id  =c2.clnt_id
    and c1.cont_no  =c2.cont_no
    and c1.bond_seq =c2.bond_seq
    and c2.clnt_id  = i_clnt_id
    and c2.cust_id  = v_cust_id
    and c1.loan_no  = i_loan_no
    and w.use_yn    =' '
    and w.clnt_id   =c2.CLNT_ID
    and w.cust_id   =c2.CUST_ID
    and w.loan_no   =c1.loan_no
    ;
    
    IF v_loan_cnt =0    then 
        raise loan_err;
    END IF;
    
    select count(*)
    into   s_cnt
    from wp02wota w
    where stdd_ymd  =to_char(sysdate,'yyyymmdd')
    and clnt_id     =i_clnt_id
    and loan_no     =i_loan_no
    and recp_dgre   =to_number(i_recp_dgre)
    ;
    
    p_ret := '0000';
    p_msg := '조회가 완료되었습니다.';

EXCEPTION
    WHEN cust_err THEN
        s_cnt:=-1;
        p_ret := '3001';
        p_msg := '대상고객이 존재하지 않습니다.';
    WHEN loan_err THEN
        s_cnt:=-1;
        p_ret := '3002';
        p_msg := '해당 등록된 신용회복 대출번호가 존재하지 않습니다.';   
    WHEN NO_DATA_FOUND THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회할 건이 없습니다.';
    WHEN OTHERS THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회시에러 - ' || SQLCODE || ' ' || SQLERRM;
END;  

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 상환내역 입력 (TS_220003)
--  작성일자 : 
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_i22 (
        p_ret                out     varchar2,            -- 리턴 값
        p_msg                out     varchar2,            -- 에러 메세지        
       
        p_crss_cseq                  in number  ,   -- 신용회복심의차수      
        p_ad_clnt_cust_no            in varchar2,   -- 고객번호              
        p_ad_loan_no                 in varchar2,   -- 대출계좌번호          
        p_ad_recp_dgre               in number  ,   -- 납부회차              
        p_ad_recv_ymd                in varchar2,   -- 처리일자              
        p_ad_aply_man_name           in varchar2,   -- 신청인명              
        p_ad_dlng_pamt               in number,     -- 대출원금              
        p_ad_dlng_int                in number,     -- 이자금액              
        p_ad_cost                    in number,     -- 비용합계금액          
        p_ad_dlng_amt                in number,     -- 합계금액              
        p_ad_wkot_step               in varchar2,   -- 신용회복계좌별상태코드
        p_crss_pamt                  in number,     -- 확정채권금액          
        p_ad_once_paym_redu_rate     in number,     -- 신용회복일시납부감면율
        p_ad_fee                     in number,     -- 수수료                
        p_ad_fast_frst_yn            in varchar2,   -- 유효여부 (1회차여부)  
        p_ad_dele_ymd                in varchar2,   -- 삭제일자              
        p_ad_dele_yn                 in varchar2    -- 삭제여부              

) IS 
    v_cust_id   wp02wota.cust_id%type;
    v_wkot_step wp02wota.WKOT_STEP%type;
    v_dlng_amt  number(13);
    
    sum_err exception;
    
    BEGIN
        p_ret := '3000';
        p_msg := '저장시 에러';    
      
        select w.cust_id
              ,w.end_divi
         into  v_cust_id
              ,v_wkot_step
        from wp01woaa w, ca05clcu ca05
        where 1=1
        and ca05.use_yn=' '
        and ca05.clnt_id='700'
        and ca05.clnt_cust_no = p_ad_clnt_cust_no
        and w.use_yn=' '
        and w.clnt_id= ca05.CLNT_ID
        and w.cust_id= ca05.CUST_ID
        and w.loan_no= p_ad_loan_no
        and w.seq = (select max(w1.seq)
                        from wp01woaa w1
                        where w1.use_yn=' '
                        and w1.clnt_id=w.CLNT_ID
                        and w1.cust_id=w.cust_id
                        and w1.loan_no=w.loan_no )
        ;   
        
        select nvl(p_ad_dlng_pamt,0)+ nvl(p_ad_dlng_int,0)+nvl(p_ad_cost,0)
        into v_dlng_amt
        from dual;
        
        IF v_dlng_amt <> p_ad_dlng_amt THEN
            raise sum_err;
        END IF;
      -- 워크아웃 상환내역 테이블
      -- WP02WOTA 에 입력
        INSERT INTO WP02WOTA (  stdd_ymd           --기준일자
                               ,clnt_id            --위탁사ID
                               ,loan_no            --대출번호
                               ,recp_dgre          --입금차수
                               ,cust_id            --고객ID
                               ,aply_man_name      --신청인명
                               ,recv_ymd           --수납일자
                               ,dlng_pamt          --처리원금
                               ,dlng_int           --처리이자
                               ,cost               --비용
                               ,dlng_amt           --처리합계(원금+이자+비용)
                               ,once_paym_redu_rate--일시납부감면율
                               ,fee                --수수료
                               ,wkot_step          --워크아웃단계
                               ,crss_cseq          --신용회복심의차수
                               ,crss_pamt          --확정채권금액
                               ,fast_frst_yn       --유효여부 (1회차여부)
                               ,curr_stat          --현상태
                               ,inpt_date          --입력일자
                               ,inpt_staf          --입력사번
                               ,chng_pgm_id        --변경프로그램ID
                               ,use_yn             --사용여부
                ) values ( 
                              to_char(sysdate,'yyyymmdd')  
                               ,'700'
                               ,p_ad_loan_no
                               ,ROUND(nvl(p_ad_recp_dgre,0),0)  
                               ,v_cust_id
                               ,p_ad_aply_man_name
                               ,p_ad_recv_ymd
                               ,ROUND(nvl(p_ad_dlng_pamt,0)/100,0) 
                               ,ROUND(nvl(p_ad_dlng_int,0)/100,0) 
                               ,ROUND(nvl(p_ad_cost,0)/100,0) 
                               ,ROUND(nvl(p_ad_dlng_amt,0)/100,0)
                               ,ROUND(nvl(p_ad_once_paym_redu_rate,0)/1000,0) 
                               ,ROUND(nvl(p_ad_fee,0)/1000000,0)  
                               ,decode(p_ad_wkot_step,'999','80','888','90',v_wkot_step)
                               ,ROUND(nvl(p_crss_cseq,0),0)  
                               ,ROUND(nvl(p_crss_pamt,0)/100,0)
                               ,p_ad_fast_frst_yn  
                               ,'02'  -- 전송완료
                               ,sysdate
                               ,'90000'
                               ,'BTOIN01_I22'
                               ,' '
                );
       
        p_ret := '0000';
        p_msg := '정상적으로 처리되었습니다.';     
    exception
        when sum_err    then
            p_ret := '3001';
            p_msg := '금액합계오류(원금+이자+비용)';    
        when no_data_found then
            p_ret := '3000';
            p_msg := '조회건이 없습니다.';
        when others then
            p_ret := '3001';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

    end;   


--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 상환내역 수정 (TS_220003)
--  작성일자 : 
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_u22 (
        p_ret                out     varchar2,            -- 리턴 값
        p_msg                out     varchar2,            -- 에러 메세지        
        p_crss_cseq                  in number  ,   -- 신용회복심의차수      
        p_ad_clnt_cust_no            in varchar2,   -- 고객번호              
        p_ad_loan_no                 in varchar2,   -- 대출계좌번호          
        p_ad_recp_dgre               in number  ,   -- 납부회차              
        p_ad_recv_ymd                in varchar2,   -- 처리일자              
        p_ad_aply_man_name           in varchar2,   -- 신청인명              
        p_ad_dlng_pamt               in number,     -- 대출원금              
        p_ad_dlng_int                in number,     -- 이자금액              
        p_ad_cost                    in number,     -- 비용합계금액          
        p_ad_dlng_amt                in number,     -- 합계금액              
        p_ad_wkot_step               in varchar2,   -- 신용회복계좌별상태코드
        p_crss_pamt                  in number,     -- 확정채권금액          
        p_ad_once_paym_redu_rate     in number,     -- 신용회복일시납부감면율
        p_ad_fee                     in number,     -- 수수료                
        p_ad_fast_frst_yn            in varchar2,   -- 유효여부 (1회차여부)  
        p_ad_dele_ymd                in varchar2,   -- 삭제일자              
        p_ad_dele_yn                 in varchar2    -- 삭제여부              

) IS 
    v_cust_id   wp02wota.cust_id%type;
    v_wkot_step wp02wota.WKOT_STEP%type;
    v_dlng_amt  number(13);
    
    sum_err exception;
    
    BEGIN
       p_ret := '3000';
       p_msg := '저장시 에러';    
      
        select w.cust_id
              ,w.end_divi
         into  v_cust_id
              ,v_wkot_step
        from wp01woaa w, ca05clcu ca05
        where 1=1
        and ca05.use_yn=' '
        and ca05.clnt_id='700'
        and ca05.clnt_cust_no = p_ad_clnt_cust_no
        and w.use_yn=' '
        and w.clnt_id= ca05.CLNT_ID
        and w.cust_id= ca05.CUST_ID
        and w.loan_no= p_ad_loan_no
        and w.seq = (select max(w1.seq)
                        from wp01woaa w1
                        where w1.use_yn=' '
                        and w1.clnt_id=w.CLNT_ID
                        and w1.cust_id=w.cust_id
                        and w1.loan_no=w.loan_no )
        ;   
        
        select nvl(p_ad_dlng_pamt,0)+ nvl(p_ad_dlng_int,0)+nvl(p_ad_cost,0)
        into v_dlng_amt
        from dual;
        
        IF v_dlng_amt <> p_ad_dlng_amt THEN
            raise sum_err;
        END IF;          
      -- 워크아웃 상환내역 테이블
      -- WP02WOTA 에 수정
                 update wp02wota 
                  set    cust_id               = v_cust_id
                       , aply_man_name         = p_ad_aply_man_name
                       , recv_ymd              = p_ad_recv_ymd
                       , dlng_pamt             = ROUND(nvl(p_ad_dlng_pamt,0)/100,0)   
                       , dlng_int              = ROUND(nvl(p_ad_dlng_int,0)/100,0)  
                       , cost                  = ROUND(nvl(p_ad_cost,0)/100,0) 
                       , dlng_amt              = ROUND(nvl(p_ad_dlng_amt,0)/100,0)   
                       , once_paym_redu_rate   = ROUND(nvl(p_ad_once_paym_redu_rate,0)/1000,0)   
                       , fee                   = ROUND(nvl(p_ad_fee,0)/1000000,0) 
                       , wkot_step             = decode(p_ad_wkot_step,'999','80','888','90',v_wkot_step)
                       , crss_cseq             = ROUND(nvl(p_crss_cseq,0),0)  
                       , crss_pamt             = ROUND(nvl(p_crss_pamt,0)/100,0)  
                       , fast_frst_yn          = p_ad_fast_frst_yn
                       , curr_stat             = '02'
                       , chng_date             = sysdate
                       , chng_staf             = '90000'
                       , chng_pgm_id           = 'BTOIN01_U22'
                       , use_yn                = ' '
                 where clnt_id   = '700'	                                     
                   and stdd_ymd  = to_char(sysdate, 'yyyymmdd') 
                   and loan_no   = p_ad_loan_no	   
                   and recp_dgre = ROUND(nvl(p_ad_recp_dgre,0),0)  
                   ;    
        p_ret := '0000';
        p_msg := '정상적으로 처리되었습니다.';     

    exception
        when sum_err    then
            p_ret := '3001';
            p_msg := '금액합계오류(원금+이자+비용)';    
        when no_data_found then
            p_ret := '3000';
            p_msg := '조회건이 없습니다.';
        when others then
            p_ret := '3001';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

    end;   


--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 상환내역 삭제 (TS_220003)
--  작성일자 : 
--  작 성 자 :  
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_d22 (
        p_ret                out     varchar2,            -- 리턴 값
        p_msg                out     varchar2,            -- 에러 메세지        
        p_crss_cseq                  in number  ,   -- 신용회복심의차수      
        p_ad_clnt_cust_no            in varchar2,   -- 고객번호              
        p_ad_loan_no                 in varchar2,   -- 대출계좌번호          
        p_ad_recp_dgre               in number  ,   -- 납부회차              
        p_ad_recv_ymd                in varchar2,   -- 처리일자              
        p_ad_aply_man_name           in varchar2,   -- 신청인명              
        p_ad_dlng_pamt               in number,     -- 대출원금              
        p_ad_dlng_int                in number,     -- 이자금액              
        p_ad_cost                    in number,     -- 비용합계금액          
        p_ad_dlng_amt                in number,     -- 합계금액              
        p_ad_wkot_step               in varchar2,   -- 신용회복계좌별상태코드
        p_crss_pamt                  in number,     -- 확정채권금액          
        p_ad_once_paym_redu_rate     in number,     -- 신용회복일시납부감면율
        p_ad_fee                     in number,     -- 수수료                
        p_ad_fast_frst_yn            in varchar2,   -- 유효여부 (1회차여부)  
        p_ad_dele_ymd                in varchar2,   -- 삭제일자              
        p_ad_dele_yn                 in varchar2    -- 삭제여부              

) IS 

    BEGIN
        p_ret := '3000';
        p_msg := '저장시 에러'; 
       -- 워크아웃 상환내역 테이블
       -- WP02WOTA 에 삭제
        UPDATE WP02WOTA
          set    curr_stat      = '04'
               , dele_staf      = '90000'
               , dele_date      = sysdate
               , chng_pgm_id    = 'BTOIN01_D22'
               , use_yn         = 'D'
        WHERE 1=1
        and  stdd_ymd   =to_date(sysdate,'yyyymmdd')
        AND clnt_id     ='700'
        and loan_no     = p_ad_loan_no
        and recp_dgre   = ROUND(nvl(p_ad_recp_dgre,0),0)
        ;
       p_ret := '0000';
       p_msg := '정상적으로 처리되었습니다.';     
    exception
        when no_data_found then
            p_ret := '3000';
            p_msg := '조회건이 없습니다.';
        when others then
            p_ret := '3001';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;
    end;   



--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 파산면책 조회  (TS_240003)
--  작성일자 :  
--  작 성 자 : 
--  내    용 :  
--------------------------------------------------------------------------------
PROCEDURE btoin01_s24 (
    p_ret             OUT      VARCHAR2,                        -- 에러코드
    p_msg             OUT      VARCHAR2,                        -- 에러메세지
    s_cnt             OUT      NUMBER,                          -- 채무자 리스트

    i_clnt_id         IN       CA01BOND.clnt_id%TYPE,           -- 위탁사ID
    i_clnt_cust_no    IN       CA05CLCU.CLNT_CUST_NO%TYPE,      -- 고객번호
    i_to_ledg_no      IN       WP10BEAA.TO_LEDG_NO%TYPE        -- 특수절차원장번호         
) IS
    v_cust_id       ca01bond.CUST_ID%type;
    v_cust_cnt      number(3);
    v_loan_cnt      number(3);
    
    cust_err        exception;
    loan_err        exception;


BEGIN   
    s_cnt:=-1;
    SELECT count(*)
        into v_cust_cnt
    FROM CA05CLCU
    WHERE CLNT_ID       =i_clnt_id
    AND CLNT_CUST_NO    =i_clnt_cust_no;
    
    IF v_cust_cnt=0 THEN
        raise cust_err;
    ELSE     
         SELECT CUST_ID
        into v_cust_id
        FROM CA05CLCU
        WHERE CLNT_ID       =i_clnt_id
        AND CLNT_CUST_NO    =i_clnt_cust_no;        
    END IF;
    
    SELECT count(*)
        into v_loan_cnt
    FROM CA01BOND c1, CA02RELN c2
    where 1=1
    and c1.use_yn=' '
    and c2.use_yn=' '
    and c1.clnt_id  = c2.clnt_id
    and c1.cont_no  = c2.cont_no
    and c1.bond_seq = c2.bond_seq
    and c2.clnt_id  = i_clnt_id
    and c2.cust_id  = v_cust_id
    and c1.end_divi ='00'
    ;
    
    IF v_loan_cnt =0    then 
        raise loan_err;
    END IF;
    
    select count(*)
     into s_cnt
    from wp10beaa wp10
    where 1=1
    and wp10.use_yn     =' '
    and wp10.clnt_id    = i_clnt_id
    and wp10.cust_id    = v_cust_id
    and wp10.TO_LEDG_NO =  i_to_ledg_no                    
    ;                   
    
    p_ret := '0000';
    p_msg := '조회가 완료되었습니다.'; 
EXCEPTION
    WHEN cust_err THEN
        s_cnt:=-1;
        p_ret := '3001';
        p_msg := '대상고객이 존재하지 않습니다.';
    WHEN loan_err THEN
        s_cnt:=-1;
        p_ret := '3002';
        p_msg := '진행 대출번호가 존재하지 않습니다.';       
    WHEN NO_DATA_FOUND THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회할 건이 없습니다.';
    WHEN OTHERS THEN
        s_cnt:=-1;
        p_ret := '3000';
        p_msg := '조회시에러 - ' || SQLCODE || ' ' || SQLERRM;
END;  

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 파산면책 입력 (TS_240003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :   
--------------------------------------------------------------------------------
PROCEDURE btoin01_i24 (
        p_ret                  out     varchar2,  -- 리턴 값
        p_msg                  out     varchar2,  -- 에러 메세지        
        p_ad_to_ledg_no             in varchar2,   -- 특수절차원장번호    
        p_ad_clnt_cust_no           in varchar2,   -- 고객번호            
        p_ad_case_no                in varchar2,   -- 사건번호            
        p_ad_jrdt_curt              in varchar2,   -- 관할법원코드        
        p_ad_bkrt_aply_ymd          in varchar2,   -- 신청일자            
        p_ad_bkrt_immu_end_ymd      in varchar2,   -- 종결일자            
        p_ad_bkrt_immu_step         in varchar2,   -- 특수절차진행상태코드
        p_ad_bkrt_stop_ordr_ymd     in varchar2,   -- 금지명령일자        
        p_ad_immu_dcsn_ymd          in varchar2,   -- 면책결정일자        
        p_ad_bkrt_sntn_ymd          in varchar2,   -- 파산선고일자        
        p_ad_immu_fixd_ymd          in varchar2,   -- 면책확정일자        
        p_ad_dele_ymd               in varchar2,   -- 삭제일자            
        p_ad_dele_yn                in varchar2,    -- 삭제여부  
        p_bkrt_immu_step            in varchar2,    -- 파산면책단계
        p_bkrt_abnd_ymd             in varchar2,    -- 파산기각일
        p_bkrt_disc_ymd             in varchar2,    -- 파산폐지일
        p_immu_cncl_ymd             in varchar2     -- 면책취소일
          

) IS 

    v_cust_id       wp10beaa.cust_id%type;
    v_seq           wp10beaa.seq%type;
    v_ledg_seq      wp30toss.seq%type;
    v_to_ledg_no1   wp20praa.TO_LEDG_NO%type;
    
    v_ad_to_ledg_no1 varchar2(4);
    v_ad_to_ledg_no2 number(6);
    
    v_case_no1      wp10beaa.immu_case_no1%type;
    v_case_no2      wp10beaa.immu_case_no2%type;
    v_case_no3      wp10beaa.immu_case_no3%type;        

    v_yy            varchar2(2);
    v_debt_cnt      number(3);
        
    debt_err        exception;
    to_ledg_err     exception;
    v_to_live_cnt   number(3);
    to_dupl_err     exception;
    
    v_immu_yn   varchar2(1);  
   
   BEGIN
                                
        p_ret := '3000';
        p_msg := '저장시 에러'; 
        v_debt_cnt:=0;
        
       SELECT CUST_ID
        into v_cust_id
        FROM CA05CLCU
        WHERE CLNT_ID       ='700'
        AND CLNT_CUST_NO    =p_ad_clnt_cust_no
        ;        
           
         select count(distinct c2.debt_divi) 
        into v_debt_cnt
        from ca01bond c1, ca02reln c2
        where c1.use_yn=' '
        and c2.use_yn=' '
        and c1.clnt_id=c2.CLNT_ID
        and c1.cont_no=c2.cont_no
        and c1.bond_seq=c2.bond_seq
        and c2.clnt_id='700'
        and c2.cust_id= v_cust_id
        and c1.end_divi='00'
        ;
        
      if v_debt_cnt >1 then 
       raise debt_err;
      end if; 

      select nvl(max(w.seq),0)+1
               into v_seq
            from wp10beaa w
            where 1=1
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
       ;  
      select substr(to_char(sysdate,'yyyy'),3,4)
            ,substr(p_ad_to_ledg_no,0,4)
            ,to_number(substr(p_ad_to_ledg_no,5))
        into v_yy
            ,v_ad_to_ledg_no1
            ,v_ad_to_ledg_no2
        from dual
       ;
      
      select  NVL(MAX(TO_NUMBER(SUBSTR(TO_LEDG_NO,5))),0)
        into v_ledg_seq
       from wp30toss
       where 1=1
       and clnt_id='700'
--       and cust_id =v_cust_id
       AND RGST_DIVI='00'
       ;

        --년도(2)+위임기관구분(2)+일련번호(12)
        --위팀기관구분 00:토스 01:에이앤디 02:미래신용정보
        v_to_ledg_no1 := v_yy||'00'; 
        
        IF v_to_ledg_no1 <> v_ad_to_ledg_no1 then
            raise to_ledg_err ;
        END IF; 
        --새로생성되는 번호가 기존 등록번호와 작거나 같으면 에러발생(20210427 김선영 차장 삭제요청)
--        IF v_ad_to_ledg_no2 <=  v_ledg_seq THEN
--            raise to_ledg_err ;
--        END IF; 
        
         --기존 삭제되지 않은 특수절차원장번호의 파산이 존재하면 입력중복에러
        select count(*)
        into  v_to_live_cnt
        from wp30toss
        where 1=1
--        and use_yn=' '
        and clnt_id='700'
        and to_ledg_no= p_ad_to_ledg_no
--        and cust_id=v_cust_id
--        and wp_divi='BK'        
        ;   
        
        IF v_to_live_cnt >0 THEN
            raise to_dupl_err;
        END IF;    
        
         --사건번호를 나눔.   
        IF p_ad_case_no IS NOT NULL THEN 
        /*select  regexp_substr(bkrt_case_no,'[^-]+', 1, 1) 
              , (select c.code_val
                    from CM02CODE c
                    where c.use_yn=' '
                    and c.code_id in ('BKRT_CASE_NO','IMMU_CASE_NO')
                    and c.code_name =    regexp_substr(bkrt_case_no,'[^-]+', 1, 2) 
                    and rownum =1
                    )
              , regexp_substr(bkrt_case_no,'[^-]+', 1, 3)
              , case when regexp_substr(bkrt_case_no,'[^-]+', 1, 2) ='하면' 
                     then 'Y' else 'N' end 
          into v_case_no1,v_case_no2,v_case_no3, v_immu_yn
          from
              (
                  select p_ad_case_no as bkrt_case_no from dual
              );
*/
                  select   substr(p_ad_case_no,0,4)
                            , (select c.code_val
                            from CM02CODE c
                            where c.use_yn=' '
                            and c.code_id in ('BKRT_CASE_NO','IMMU_CASE_NO')
                            and c.code_name =substr(p_ad_case_no,5,2)
                          and rownum =1
                            )
                            ,substr(p_ad_case_no,7)
                            ,case when substr(p_ad_case_no,5,2) ='하면' 
                                     then 'Y' else 'N' end 
                  into  v_case_no1
                       ,v_case_no2
                       ,v_case_no3 
                       , v_immu_yn
                 from dual; 
        END IF;
        
           -- // TOSS 특수절차진행상태코드 : 	01.신청	02.보전처분(금지명령) 	03.개시결정
		   -- //						        04.인가	05.졸업			06.기각
		   -- //						        07.폐지	08.부결			09.수행불능
		   -- //						        10.취소	11.면책결정		
        
       -- (1) 
       -- WP10BEAA 신규입력
       -- SEQ ,TO_LEDG_NO 조회하여 입력        
       INSERT INTO WP10BEAA (    CLNT_ID         
                                ,CUST_ID        
                                ,SEQ
                                ,TO_LEDG_NO           
                                ,BKRT_IMMU_STEP
                                ,BKRT_JRDT_CURT
                                ,BKRT_CASE_NO1
                                ,BKRT_CASE_NO2
                                ,BKRT_CASE_NO3
                                ,IMMU_JRDT_CURT
                                ,IMMU_CASE_NO1
                                ,IMMU_CASE_NO2
                                ,IMMU_CASE_NO3
                                ,BKRT_APLY_YMD
                                ,BKRT_STOP_ORDR_YMD
                                ,BKRT_STOP_INPT_DATE
                                ,BKRT_STOP_INPT_STAF
                                ,BKRT_SNTN_YMD
                                ,BKRT_SNTN_INPT_DATE
                                ,BKRT_SNTN_INPT_STAF
                                ,BKRT_DISC_YMD 
                                ,BKRT_ABND_YMD
                                ,BKRT_ABND_INPT_DATE
                                ,BKRT_ABND_INPT_STAF
                                ,IMMU_DCSN_YMD
                                ,IMMU_DCSN_INPT_DATE
                                ,IMMU_DCSN_INPT_STAF
                                ,IMMU_FIXD_YMD
                                ,IMMU_FIXD_INPT_DATE
                                ,IMMU_FIXD_INPT_STAF
                                ,IMMU_CNCL_YMD
                                ,IMMU_CNCL_INPT_DATE
                                ,IMMU_CNCL_INPT_STAF                                          
                                ,INPT_DATE
                                ,INPT_STAF
                                ,CHNG_PGM_ID
                                ,USE_YN                 )
                   VALUES (     '700'       
                                ,v_cust_id
                                ,v_seq
                                ,p_ad_to_ledg_no
                                ,p_bkrt_immu_step
 --관할법원코드 변경 전                                
 /*                             ,case when p_ad_jrdt_curt is not null  and v_immu_yn='N'
                                      then decode(p_ad_jrdt_curt, 'AA00','11', 'AR00','17', 'AC00', '31'
                                                                ,'AP00','16','AB00','21', 'AD00','41', 'AF00', '51'
                                                                ,'AE00','61','AG00','71', 'AH00','81', 'AI00', '83'
                                                                ,'AJ00','91','AK00','A1', 'AL00','B1', 'AM00', 'C1', 'ADD1','D1', '0000','','')
                                                     else  null end */
 --관할법원코드 변경 후                                                     
                                  ,case when  p_ad_jrdt_curt is not null  and v_immu_yn='N'
                                      then  nvl( (select  c.code_val
                                                from cm02code c, cm02code t
                                                where c.code_id='BKRT_IMMU_JRDT_CURT'
                                                and c.rfrc_code=t.rfrc_code 		
                                                and t.code_id='TO_CPCR_CD'
                                                and t.code_val= p_ad_jrdt_curt             	                 	
                                                and rownum=1),'')
                                      else null end                     
                                ,case when  p_ad_case_no is not null and v_immu_yn='N'
                                              then v_case_no1 else null end
                                ,case when  p_ad_case_no is not null and v_immu_yn='N'
                                              then v_case_no2 else  null end 
                                ,case when  p_ad_case_no is not null and v_immu_yn='N'
                                              then v_case_no3 else  null end 
 --관할법원코드 변경 전                                              
  /*                             ,case when p_ad_jrdt_curt is not null and v_immu_yn='Y'
                                      then decode(p_ad_jrdt_curt, 'AA00','11', 'AR00','17', 'AC00', '31'
                                                                ,'AP00','16','AB00','21', 'AD00','41', 'AF00', '51'
                                                                ,'AE00','61','AG00','71', 'AH00','81', 'AI00', '83'
                                                                ,'AJ00','91','AK00','A1', 'AL00','B1', 'AM00', 'C1', 'ADD1','D1', '0000','','')
                                                     else  '' end  */
  --관할법원코드 변경 후        
                              ,case when  p_ad_jrdt_curt is not null and v_immu_yn='Y'
                                      then  nvl( (select  c.code_val
                                                from cm02code c, cm02code t
                                                where c.code_id='BKRT_IMMU_JRDT_CURT'
                                                and c.rfrc_code=t.rfrc_code 		
                                                and t.code_id='TO_CPCR_CD'
                                                and t.code_val= p_ad_jrdt_curt             	                 	
                                                and rownum=1),'')
                                      else null end                                              
                                ,case when  p_ad_case_no is not null and v_immu_yn='Y'
                                              then v_case_no1 else  null end
                                ,case when  p_ad_case_no is not null and v_immu_yn='Y'
                                              then v_case_no2 else  null end 
                                ,case when  p_ad_case_no is not null and v_immu_yn='Y'
                                              then v_case_no3 else  null end 
                                ,nvl(p_ad_bkrt_aply_ymd,'')
                                ,nvl(p_ad_bkrt_stop_ordr_ymd,'')
                                ,case when p_ad_bkrt_stop_ordr_ymd is not null then sysdate else null end
                                ,case when p_ad_bkrt_stop_ordr_ymd is not null then '90000' else null end
                                ,nvl(p_ad_bkrt_sntn_ymd,'')
                                ,case when p_ad_bkrt_sntn_ymd is not null then sysdate else null end
                                ,case when p_ad_bkrt_sntn_ymd is not null then '90000' else null end
                                ,nvl(p_bkrt_disc_ymd,'')
                                ,nvl(p_bkrt_abnd_ymd,'')
                                ,case when p_bkrt_abnd_ymd is not null then sysdate else null end
                                ,case when p_bkrt_abnd_ymd is not null then '90000' else null end
                                ,nvl(p_ad_immu_dcsn_ymd,'')
                                ,case when p_ad_immu_dcsn_ymd is not null then sysdate else null end
                                ,case when p_ad_immu_dcsn_ymd is not null then '90000' else null end
                                ,nvl(p_ad_immu_fixd_ymd,'')
                                ,case when p_ad_immu_fixd_ymd is not null then sysdate else null end
                                ,case when p_ad_immu_fixd_ymd is not null then '90000' else null end
                                ,nvl(p_immu_cncl_ymd,'')
                                ,case when p_immu_cncl_ymd is not null then sysdate else null end
                                ,case when p_immu_cncl_ymd is not null then '90000' else null end
                                ,sysdate
                                ,'90000'
                                ,'BTOIN01_I24'
                                ,' '   
                         ) ;
                         
       -- (2) WP30TOSS 
       --     특수원장번호 신규 입력
         INSERT INTO  WP30TOSS ( CLNT_ID        ,CUST_ID            ,SEQ        
                                ,TO_LEDG_NO     ,CLNT_CUST_NO       ,RGST_DIVI  
                                ,WP_DIVI        ,INPT_DATE          ,INPT_STAF
                                ,CHNG_PGM_ID    ,USE_YN)
               VALUES (         '700'           ,v_cust_id         ,to_number(v_seq)  
                                ,p_ad_to_ledg_no,p_ad_clnt_cust_no ,'00'   
                                ,'BK'           ,sysdate           ,'90000'
                                ,'BTOIN01_I24'  ,' ')
          ;               
       
                
       -- (3) 
       -- WP20PRAB 신규입력
       -- 등록 위임된 모든 대출 등록 
         INSERT INTO  WP10BEAB(      CLNT_ID        ,CUST_ID        ,SEQ    
                                    ,LOAN_NO        ,CUST_NAME      ,DEBT_DIVI                                          
                                    ,INPT_DATE      ,INPT_STAF      ,CHNG_PGM_ID
                                    ,USE_YN )
                SELECT              '700'           ,c2.cust_id     ,v_seq
                                    ,c1.loan_no     ,c2.cust_name   ,c2.debt_divi   
                                    ,sysdate        ,'90000'        ,'BTOIN01_I13'
                                    ,' '
                FROM CA01BOND c1, CA02RELN c2
                where c1.use_yn=' '
                and c2.use_yn=' '
                and c1.clnt_id=c2.CLNT_ID
                and c1.cont_no=c2.cont_no
                and c1.bond_seq=c2.bond_seq
                and c2.clnt_id='700'
                and c2.cust_id= v_cust_id
                and c1.end_divi='00'
         ;       
           
          -- (4) 
          -- CA02RELN 단계 수정
          -- 등록 위임된 모든 대출의 파산면책단계 등록            
             update ca02reln c2
             set  c2.bkrt_immu_step  = case when c2.bkrt_immu_step<> p_bkrt_immu_step or c2.bkrt_immu_step is null 
                                            then p_bkrt_immu_step else c2.bkrt_immu_step end                                        
                , c2.chng_pgm_id     = 'BTOIN01_I13'
                , c2.chng_date       = sysdate
                , c2.chng_staf       = '90000'
              where 1=1
              and c2.use_yn     =' '
              and c2.clnt_id    ='700'
              and c2.cust_id    =v_cust_id
              and exists (select 1
                            from ca01bond c1
                            where c1.use_yn=' '
                            and c1.clnt_id=c2.CLNT_ID
                            and c1.cont_no=c2.cont_no
                            and c1.bond_seq=c2.bond_seq
                            and c1.end_divi='00' )
              ; 
        p_ret := '0000';
        p_msg := '정상적으로 처리되었습니다.';        


    EXCEPTION 
        WHEN to_ledg_err THEN
            p_ret := '3001';
            p_msg := '새로 생성한 특수절차원장번호와 불일치합니다. ';
        WHEN to_dupl_err THEN
            p_ret := '3001';
            p_msg := '기등록된 특수절차원장번호의 파산사건 삭제후 입력가능합니다. '; 
         WHEN debt_err THEN
            p_ret := '3001';
            p_msg := '대상고객의 채무, 보증채무 등의 위임대출 중 선택 해주세요.';
        WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;
    END;

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 파산면책 수정 (TS_240003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :   
--------------------------------------------------------------------------------
PROCEDURE btoin01_u24 (
        p_ret                  out     varchar2,  -- 리턴 값
        p_msg                  out     varchar2,  -- 에러 메세지        
        p_ad_to_ledg_no             in varchar2,   -- 특수절차원장번호    
        p_ad_clnt_cust_no           in varchar2,   -- 고객번호            
        p_ad_case_no                in varchar2,   -- 사건번호            
        p_ad_jrdt_curt              in varchar2,   -- 관할법원코드        
        p_ad_bkrt_aply_ymd          in varchar2,   -- 신청일자            
        p_ad_bkrt_immu_end_ymd      in varchar2,   -- 종결일자            
        p_ad_bkrt_immu_step         in varchar2,   -- 특수절차진행상태코드
        p_ad_bkrt_stop_ordr_ymd     in varchar2,   -- 금지명령일자        
        p_ad_immu_dcsn_ymd          in varchar2,   -- 면책결정일자        
        p_ad_bkrt_sntn_ymd          in varchar2,   -- 파산선고일자        
        p_ad_immu_fixd_ymd          in varchar2,   -- 면책확정일자        
        p_ad_dele_ymd               in varchar2,   -- 삭제일자            
        p_ad_dele_yn                in varchar2,    -- 삭제여부  
        p_bkrt_immu_step            in varchar2,    -- 파산면책단계
        p_bkrt_abnd_ymd             in varchar2,    -- 파산기각일
        p_bkrt_disc_ymd             in varchar2,    -- 파산폐지일
        p_immu_cncl_ymd             in varchar2     -- 면책취소일
  

) IS 
    v_cust_id       wp10beaa.cust_id%type;
    v_seq           wp10beaa.seq%type;
    
    v_case_no1      varchar2(4);
    v_case_no2       varchar2(2);
    v_case_no3      wp10beaa.immu_case_no3%type;        

    v_immu_yn   varchar2(1);  
   
   BEGIN
        p_ret := '3000';
        p_msg := '저장시 에러'; 
        select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn=' '
          and c5.clnt_id='700'
          and c5.CLNT_CUST_NO = p_ad_clnt_cust_no
        ;                                 
        select w.seq
               into v_seq
            from WP10BEAA w
            where 1=1
            and w.use_yn=' '
            and w.clnt_id   =   '700'
            and w.cust_id   =   v_cust_id
            and w.TO_LEDG_NO = p_ad_to_ledg_no
        ;                                 
        --사건번호를 나눔.   
        IF p_ad_case_no IS NOT NULL THEN 
--                select  regexp_substr(bkrt_case_no,'[^-]+', 1, 1) 
--                      , (select c.code_val
--                            from CM02CODE c
--                            where c.use_yn=' '
--                            and c.code_id in ('BKRT_CASE_NO','IMMU_CASE_NO')
--                            and c.code_name =    regexp_substr(bkrt_case_no,'[^-]+', 1, 2) 
--                            and rownum =1
--                            )
--                      ,regexp_substr(bkrt_case_no,'[^-]+', 1, 3)
--                      , case when regexp_substr(bkrt_case_no,'[^-]+', 1, 2) ='하면' 
--                             then 'Y' else 'N' end 
--                  into v_case_no1,v_case_no2,v_case_no3, v_immu_yn
--                  from  (
--                          select p_ad_case_no as bkrt_case_no from dual
--                        ); 
             select   substr(p_ad_case_no,0,4)
                    , (select c.code_val
                            from CM02CODE c
                            where c.use_yn=' '
                            and c.code_id in ('BKRT_CASE_NO','IMMU_CASE_NO')
                            and c.code_name =substr(p_ad_case_no,5,2)
                          and rownum =1
                            )
                    ,substr(p_ad_case_no,7)
                    ,case when substr(p_ad_case_no,5,2) ='하면' 
                             then 'Y' else 'N' end 
              into  v_case_no1
                   ,v_case_no2
                   ,v_case_no3 
                   , v_immu_yn
             from dual; 
          ELSE   
             v_immu_yn := 'N' ;
             
          END IF;            
       -- (1) 
       -- WP10BEAA 수정
       -- SEQ ,TO_LEDG_NO 조회하여 수정    
                UPDATE WP10BEAA 
                  SET   
 --관할법원코드 변경 전                  
  /*                      bkrt_jrdt_curt       = case when p_ad_jrdt_curt='0000' THEN bkrt_jrdt_curt
                                                     when p_ad_jrdt_curt is not null  and v_immu_yn='N'
                                                     then decode(p_ad_jrdt_curt, 'AA00','11', 'AR00','17', 'AC00', '31'
                                                                     ,'AP00','16','AB00','21', 'AD00','41', 'AF00', '51'
                                                                     ,'AE00','61','AG00','71', 'AH00','81', 'AI00', '83'
                                                                     ,'AJ00','91','AK00','A1', 'AL00','B1', 'AM00', 'C1', 'ADD1','D1', '00')
                                                     else bkrt_jrdt_curt end  */
  --관할법원코드 변경 후                                                    
                       bkrt_jrdt_curt       = case when p_ad_jrdt_curt='0000' THEN bkrt_jrdt_curt
                                                     when p_ad_jrdt_curt is not null  and v_immu_yn='N'
                                                     then nvl( (select  c.code_val
                                                                from cm02code c, cm02code t
                                                                where c.code_id='BKRT_IMMU_JRDT_CURT'
                                                                and c.rfrc_code=t.rfrc_code 		
                                                                and t.code_id='TO_CPCR_CD'
                                                                and t.code_val= p_ad_jrdt_curt             	                 	
                                                                and rownum=1),'')
                                                     else bkrt_jrdt_curt end         
                       , bkrt_case_no1        = case when  p_ad_case_no is not null and v_immu_yn='N'
                                                     then v_case_no1 else bkrt_case_no1 end
                       , bkrt_case_no2        = case when  p_ad_case_no is not null and v_immu_yn='N'
                                                     then v_case_no2 else bkrt_case_no2 end 
                       , bkrt_case_no3        = case when  p_ad_case_no is not null and v_immu_yn='N'
                                                     then v_case_no3 else bkrt_case_no3 end
 --관할법원코드 변경 전                                                     
 /*                    , immu_jrdt_curt       = case  when p_ad_jrdt_curt='0000' THEN bkrt_jrdt_curt
                                                     when p_ad_jrdt_curt is not null and v_immu_yn='Y'
                                                     then decode(p_ad_jrdt_curt, 'AA00','11', 'AR00','17', 'AC00', '31'
                                                                     ,'AP00','16','AB00','21', 'AD00','41', 'AF00', '51'
                                                                     ,'AE00','61','AG00','71', 'AH00','81', 'AI00', '83'
                                                                     ,'AJ00','91','AK00','A1', 'AL00','B1', 'AM00', 'C1', 'ADD1','D1', '00')
                                                     else bkrt_jrdt_curt end  */
 --관할법원코드 변경 후  
                        , immu_jrdt_curt       = case  when p_ad_jrdt_curt='0000' THEN bkrt_jrdt_curt
                                                     when p_ad_jrdt_curt is not null and v_immu_yn='Y'
                                                     then nvl( (select  c.code_val
                                                                from cm02code c, cm02code t
                                                                where c.code_id='BKRT_IMMU_JRDT_CURT'
                                                                and c.rfrc_code=t.rfrc_code 		
                                                                and t.code_id='TO_CPCR_CD'
                                                                and t.code_val= p_ad_jrdt_curt             	                 	
                                                                and rownum=1),'')
                                                     else  bkrt_jrdt_curt end           
                       , immu_case_no1        = case when  p_ad_case_no is not null and v_immu_yn='Y'
                                                     then v_case_no1 else immu_case_no1 end
                       , immu_case_no2        = case when  p_ad_case_no is not null and v_immu_yn='Y'
                                                     then v_case_no2 else immu_case_no2 end 
                       , immu_case_no3        = case when  p_ad_case_no is not null and v_immu_yn='Y'
                                                     then v_case_no3 else immu_case_no3 end
                       , bkrt_immu_step       = p_bkrt_immu_step 
                       , bkrt_aply_ymd        = nvl(p_ad_bkrt_aply_ymd,'')
                       , bkrt_stop_ordr_ymd   = nvl(p_ad_bkrt_stop_ordr_ymd,'') --파산중지명령일
                       , bkrt_stop_inpt_date  = case when bkrt_stop_inpt_date is null and p_ad_bkrt_stop_ordr_ymd is not null
                                                     then sysdate else null end
                       , bkrt_stop_inpt_staf  = case when bkrt_stop_inpt_staf is null and p_ad_bkrt_stop_ordr_ymd is not null
                                                     then '90000' else null end
                       , bkrt_stop_chng_date  = case when bkrt_stop_ordr_ymd is not null and bkrt_stop_ordr_ymd <> nvl(p_ad_bkrt_stop_ordr_ymd,'99999999')
                                                     then sysdate else bkrt_stop_chng_date end
                       , bkrt_stop_chng_staf  = case when bkrt_stop_ordr_ymd is not null and bkrt_stop_ordr_ymd <> nvl(p_ad_bkrt_stop_ordr_ymd,'99999999')
                                                     then '90000' else bkrt_stop_chng_staf end
                       , bkrt_sntn_ymd        = nvl(p_ad_bkrt_sntn_ymd,'')     --파산선고일
                       , bkrt_sntn_inpt_date  = case when bkrt_sntn_inpt_date is null and p_ad_bkrt_sntn_ymd is not null
                                                     then sysdate else null end
                       , bkrt_sntn_inpt_staf  = case when bkrt_sntn_inpt_staf is null and p_ad_bkrt_sntn_ymd is not null
                                                     then '90000' else null end
                       , bkrt_sntn_chng_date  = case when bkrt_sntn_ymd is not null and bkrt_sntn_ymd <> nvl(p_ad_bkrt_sntn_ymd,'99999999')
                                                     then sysdate else bkrt_sntn_chng_date end
                       , bkrt_sntn_chng_staf  = case when bkrt_sntn_ymd is not null and bkrt_sntn_ymd <> nvl(p_ad_bkrt_sntn_ymd,'99999999')
                                                     then '90000' else bkrt_sntn_chng_staf end                                                     
                       , bkrt_disc_ymd        = nvl(p_bkrt_disc_ymd,'')        --파산폐지일                                              
                       , bkrt_abnd_ymd        = nvl(p_bkrt_abnd_ymd,'')        --파산기각일
                       , bkrt_abnd_inpt_date  = case when bkrt_abnd_inpt_date is null and p_bkrt_abnd_ymd is not null
                                                     then sysdate else null end
                       , bkrt_abnd_inpt_staf  = case when bkrt_abnd_inpt_staf is null and p_bkrt_abnd_ymd is not null
                                                     then '90000' else null end
                       , bkrt_abnd_chng_date  = case when bkrt_abnd_ymd is not null and bkrt_abnd_ymd <> nvl(p_bkrt_abnd_ymd,'99999999')
                                                     then sysdate else bkrt_abnd_chng_date end
                       , bkrt_abnd_chng_staf  = case when bkrt_abnd_ymd is not null and bkrt_abnd_ymd <> nvl(p_bkrt_abnd_ymd,'99999999')
                                                     then '90000' else bkrt_abnd_chng_staf end  
                                                     
                       , immu_dcsn_ymd        = nvl(p_ad_immu_dcsn_ymd,'')      --면책결정일
                       , immu_dcsn_inpt_date  = case when immu_dcsn_inpt_date is null and p_ad_immu_dcsn_ymd is not null
                                                     then sysdate else null end
                       , immu_dcsn_inpt_staf  = case when immu_dcsn_inpt_staf is null and p_ad_immu_dcsn_ymd is not null
                                                     then '90000' else null end
                       , immu_dcsn_chng_date  = case when immu_dcsn_ymd is not null and immu_dcsn_ymd <> nvl(p_ad_immu_dcsn_ymd,'99999999')
                                                     then sysdate else immu_dcsn_chng_date end
                       , immu_dcsn_chng_staf  = case when immu_dcsn_ymd is not null and immu_dcsn_ymd <> nvl(p_ad_immu_dcsn_ymd,'99999999')
                                                     then '90000' else immu_dcsn_chng_staf end                                                       
                       , immu_fixd_ymd        = nvl(p_ad_immu_fixd_ymd,'')      --면책확정일
                       , immu_fixd_inpt_date  = case when immu_fixd_inpt_date is null and p_ad_immu_fixd_ymd is not null
                                                     then sysdate else null end
                       , immu_fixd_inpt_staf  = case when immu_fixd_inpt_staf is null and p_ad_immu_fixd_ymd is not null
                                                     then '90000' else null end
                       , immu_fixd_chng_date  = case when immu_fixd_ymd is not null and immu_fixd_ymd <> nvl(p_ad_immu_fixd_ymd,'99999999')
                                                     then sysdate else immu_fixd_chng_date end
                       , immu_fixd_chng_staf  = case when immu_fixd_ymd is not null and immu_fixd_ymd <> nvl(p_ad_immu_fixd_ymd,'99999999')
                                                     then '90000' else immu_fixd_chng_staf end  
                       , immu_cncl_ymd        = nvl(p_immu_cncl_ymd,'')      --면책취소일
                       , immu_cncl_inpt_date  = case when immu_cncl_inpt_date is null and p_immu_cncl_ymd is not null
                                                     then sysdate else null end
                       , immu_cncl_inpt_staf  = case when immu_cncl_inpt_staf is null and p_immu_cncl_ymd is not null
                                                     then '90000' else null end
                       , immu_cncl_chng_date  = case when immu_cncl_ymd is not null and immu_cncl_ymd <> nvl(p_immu_cncl_ymd,'99999999')
                                                     then sysdate else immu_cncl_chng_date end
                       , immu_cncl_chng_staf  = case when immu_cncl_ymd is not null and immu_cncl_ymd <> nvl(p_immu_cncl_ymd,'99999999')
                                                     then '90000' else immu_cncl_chng_staf end                                                        
                       , chng_pgm_id     = 'BTOIN01_U24'
                       , chng_date       = sysdate
                       , chng_staf       = '90000'                                                                                                                                      
                    where  1=1          
                    and  use_yn     = ' '   
                    and  clnt_id    = '700'                                                                         		      
                    and  cust_id    = v_cust_id
                    and  seq        = v_seq 
                    and  to_ledg_no = p_ad_to_ledg_no  
                    ;  
       --
       --
       --
       -- 2) WP30TOSS 단계 수정
            -- WP30TOSS 등록된 대출의 특수절차원장번호 수정
            UPDATE WP30TOSS w
                set  seq = v_seq
                    ,cust_id = v_cust_id
                    ,wp_divi    = 'BK'
                    ,chng_date  = sysdate
                    ,chng_Staf  = '90000'
               where 1=1
               and w.clnt_id ='700'
               and w.to_ledg_no = p_ad_to_ledg_no
            ;

        -- (3) 
       -- CA02RELN 수정
       -- WP10BEAB에 등록된 대출만 SEQ로 조회하여 수정
              UPDATE CA02RELN c2
                    set   bkrt_immu_step       = p_bkrt_immu_step
                        , chng_pgm_id          = 'BTOIN01_U24'
                        , chng_date            = sysdate
                        , chng_staf            = '90000'
              where 1=1
                 and c2.use_yn=' '
                 and c2.clnt_id='700'
                 and c2.cust_id= v_cust_id  
                 and ( c2.cont_no, c2.bond_seq) 
                                in (select c1.cont_no, c1.bond_seq
                                     from wp10beab b , ca01bond c1
                                     where b.use_yn=' '
                                     and b.clnt_id='700'
                                     and b.cust_id =v_cust_id
                                     and b.seq     =v_seq 
                                     and b.clnt_id =c1.clnt_id
                                     and b.loan_no =c1.loan_no
                                     and c1.end_divi='00'
                                     and c1.use_yn=' '
                                     )
              ; 
        p_ret := '0000';
        p_msg := '정상적으로 처리되었습니다.';  
    EXCEPTION 
         WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;
    END;

--------------------------------------------------------------------------------
--  제    목 : 토스 실시간 파산면책 삭제 (TS_240003)
--  작성일자 :  
--  작 성 자 :  
--  내    용 :   
--------------------------------------------------------------------------------
PROCEDURE btoin01_d24 (
        p_ret                  out     varchar2,  -- 리턴 값
        p_msg                  out     varchar2,  -- 에러 메세지        
        p_ad_to_ledg_no             in varchar2,   -- 특수절차원장번호    
        p_ad_clnt_cust_no           in varchar2,   -- 고객번호            
        p_ad_case_no                in varchar2,   -- 사건번호            
        p_ad_jrdt_curt              in varchar2,   -- 관할법원코드        
        p_ad_bkrt_aply_ymd          in varchar2,   -- 신청일자            
        p_ad_bkrt_immu_end_ymd      in varchar2,   -- 종결일자            
        p_ad_bkrt_immu_step         in varchar2,   -- 특수절차진행상태코드
        p_ad_bkrt_stop_ordr_ymd     in varchar2,   -- 금지명령일자        
        p_ad_immu_dcsn_ymd          in varchar2,   -- 면책결정일자        
        p_ad_bkrt_sntn_ymd          in varchar2,   -- 파산선고일자        
        p_ad_immu_fixd_ymd          in varchar2,   -- 면책확정일자        
        p_ad_dele_ymd               in varchar2,   -- 삭제일자            
        p_ad_dele_yn                in varchar2,    -- 삭제여부  
        p_bkrt_immu_step            in varchar2,    -- 파산면책단계
        p_bkrt_abnd_ymd             in varchar2,    -- 파산기각일
        p_bkrt_disc_ymd             in varchar2,    -- 파산폐지일
        p_immu_cncl_ymd             in varchar2     -- 면책취소일


) IS 
    
   v_cust_id       wp01woaa.cust_id%type;
   v_seq           wp01woaa.seq%type;
   
   BEGIN
         select cust_id
            into v_cust_id
         from ca05clcu c5
         where c5.use_yn        = ' '
          and c5.clnt_id        = '700'
          and c5.CLNT_CUST_NO   = p_ad_clnt_cust_no
        ;       
                          
        select w.seq
               into v_seq
            from wp10beaa w
            where 1=1
            and w.use_yn        = ' '
            and w.clnt_id       = '700'
            and w.cust_id       = v_cust_id
            and w.TO_LEDG_NO    = p_ad_to_ledg_no
        ;  
            --  파산면책 마스터 삭제처리 
            update wp10beaa 
              set        chng_pgm_id     = 'BTOIN01_D24'
                       , dele_date       = sysdate
                       , dele_staf       = '90000'
                       , use_yn          = 'D'
              where  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ; 
                
            --  파산면책 대출관리 삭제처리  
            update wp10beab 
              set        chng_pgm_id     = 'BTOIN01_D24'
                       , dele_date       = sysdate
                       , dele_staf       = '90000'
                       , use_yn          = 'D'
              where  1=1
                and use_yn  = ' ' 
                and clnt_id = '700'                                                                
                and cust_id = v_cust_id   
                and seq     <= v_seq 
                ;  

              -- 관계인 파산면책 단계 초기화      
            update ca02reln c2
                    set   bkrt_immu_step  = ''
                        , chng_pgm_id     = 'BTOIN01_D24'
                        , chng_date       = sysdate
                        , chng_staf       = '90000'
             where 1=1
             and c2.use_yn=' '
             and c2.clnt_id='700'
             and c2.cust_id= v_cust_id  
             and ( c2.cont_no, c2.bond_seq) 
                            in (select c1.cont_no, c1.bond_seq
                                 from wp10beab b , ca01bond c1
                                 where b.use_yn=' '
                                 and b.clnt_id='700'
                                 and b.cust_id =v_cust_id
                                 and b.seq     =v_seq 
                                 and b.clnt_id =c1.clnt_id
                                 and b.loan_no =c1.loan_no
                                 and c1.end_divi='00'
                                 and c1.use_yn=' '
                                 )
              ; 
              -- 특수절차원장번호 삭제  
             UPDATE WP30TOSS w
                set  use_yn    = 'D'
                    ,dele_date  = sysdate
                    ,dele_Staf  = '90000'
                    ,chng_pgm_id = 'BTOIN01_D24'
               where 1=1
               and w.clnt_id ='700'
               and w.cust_id = v_cust_id  
               AND W.TO_ledg_no = p_ad_to_ledg_no
            ;   
              
           p_ret := '0000';
           p_msg := '정상적으로 처리되었습니다.';
    EXCEPTION 
       WHEN no_data_found THEN
            p_ret := '3001';
            p_msg := '조회건이 없습니다.';
        WHEN OTHERS THEN
            p_ret := '3000';
            p_msg := '저장시에러- ' || SQLCODE || ':' || SQLERRM;

    END;

END BTOIN01; -- Package BTOIN01