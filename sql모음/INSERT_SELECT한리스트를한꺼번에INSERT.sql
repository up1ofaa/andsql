/* SELECT 한 리스트 한꺼번에 INSERT
프로시져 참조 : BCAFT01.BCAFT01_i002

*/


--INSERT INTO M_CE01CLOG_TEST@ANDDW_LINK
--          SELECT
--                 ADMN_YYMM
--                ,CLNT_ID
--                ,LOAN_NO
--                ,substr(CUST_NAME, 0, 1) || '**'
--                ,BOND_RAMT
--                ,DUE_YMD
--                ,EXPR_YMD
--                ,ENPY_YMD
--                ,CNSL_YMD
--                ,PROM_YMD
--                ,PPD
--                ,RECV_STAT
--                ,TEAM_CODE
--                ,STAF_ID
--                ,INPT_DATE
--                ,UPDT_DATE
--                ,INPT_STAF
--                ,CHNG_PGM_ID
--                ,USE_YN
--                ,CUST_ID
--                ,CUST_AMT
--                ,NEW_PROM_YMD
--                ,SOLU_CODE
--                ,SIL_YN
--                ,SIL_REQU_YN
--                ,CHO_YN
--                ,CHO_REQU_YN
--                ,GAE_YN
--                ,PA_YN
--                ,BOND_TYPE
--                ,BANG_RESN
--                ,''
--  				,VTAC_CNSL_YN
--                ,RGST_YN
--            FROM CE01CLOG
--           WHERE admn_yymm = substr(p_stdd_ymd, 0, 6)
--             and use_yn = ' ';




SELECT * FROM
IMSI_TB_SHY1;


SELECT * FROM
IMSI_TB_SHY2;

/* 다건일경우 VALUES 는 안먹힘 아래 안되는 쿼리*/
INSERT INTO IMSI_TB_SHY1  (COL1, COL2, COL3)
    VALUES (SELECT COL1, COL2, COL3
    		FROM IMSI_TB_SHY2
    		WHERE COL2 BETWEEN '00001' AND '01999')
;                                              
/* 다건일경우 VALUES 제외하고 입력할 항목(선택적으로 입력가능)은 나열 */
 INSERT INTO IMSI_TB_SHY1 (COL1, COL2, COL3)
   SELECT COL1, COL2, COL3
    		FROM IMSI_TB_SHY2
    		WHERE COL2 BETWEEN '00001' AND '01999'
    	;
