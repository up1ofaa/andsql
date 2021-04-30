CREATE OR REPLACE PACKAGE OPARSE.BTOIN01
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
    i_to_ledg_no      IN       WP20PRAA.TO_LEDG_NO%TYPE        --특수절차원장번호       
);


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
        
);





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
);




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
);



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
);


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

);

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

);



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

);



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
);


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
        p_ad_wkot_end_ymd2      in varchar2,   -- 종결일자                
        p_ad_dele_ymd           in varchar2,   -- 삭제일자                
        p_ad_dele_yn            in varchar2,   -- 삭제여부                
        p_wkot_step             in varchar2,   -- 에이앤디 워크아웃단계  (가공) 
        p_dh_end_divi           in varchar2,   -- 워크아웃 상세 종결구분 (가공)
        p_re_agre_yn            in varchar2    -- 재약정여부 (가공)
);


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
);


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
        p_ad_wkot_end_ymd2       in varchar2,   -- 종결일자                
        p_ad_dele_ymd           in varchar2,   -- 삭제일자                
        p_ad_dele_yn            in varchar2,   -- 삭제여부                
        p_wkot_step             in varchar2,   -- 에이앤디 워크아웃단계  (가공) 
        p_dh_end_divi           in varchar2,   -- 워크아웃 상세 종결구분 (가공)
        p_re_agre_yn            in varchar2    -- 재약정여부 (가공)                           
);



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
);


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

);


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

);


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

);



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
);

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

);

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
);

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

);

END BTOIN01; -- Package BTOIN01