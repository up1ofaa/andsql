
SELECT
 IMSI.NUM
,CA01.CLNT_ID||'-'||CA01.CONT_NO||'-'||CA01.BOND_SEQ 			 AS 채권번호
,CA01.CUST_NAME													AS 채무자명
--,BOND_RAMT            --채권잔고
,BOND_TYPE            --채권유형
--,BDBT_YMD             --상각일자
--,LAST_RECV_YMD        --최종수납일자
--,CPLT_LAST_YMD        --이수최종일자
,CASE WHEN BOND_TYPE  <> IMSI.AFTR_TYPE
 THEN '변경전후가 다릅니다'
 ELSE '' END AS ERR
,CHNG_DATE
,CHNG_STAF
,CHNG_PGM_ID
FROM CA01BOND CA01,
(SELECT
ROWNUM AS NUM
,COL1
,'20'     AS AFTR_TYPE  -- 변경할 채권유형 코드
--,COL2     AS AFTR_RAMT  -- 변경할 채권잔액
--,COL2     AS AFTR_BDBT_YMD
--,COL2     AS AFTR_RECV_YMD
--,COL4     AS AFTR_CPLT_YMD
FROM IMSI_TB_SHY1 ) IMSI
WHERE CA01.USE_YN=' '
AND CA01.CLNT_ID=SUBSTR(IMSI.COL1,1,3)
AND CA01.CONT_NO=SUBSTR(IMSI.COL1,5,5)
AND CA01.BOND_SEQ=SUBSTR(IMSI.COL1,11,LENGTH(IMSI.COL1)-10)
ORDER BY IMSI.NUM ASC
;

SELECT    SUBSTR(A.COL1,1,3)   AS CLNT_ID
        , SUBSTR(A.COL1,5,5)   AS CONT_NO
        , SUBSTR(A.COL1,11,LENGTH(A.COL1)-10)	 AS BOND_SEQ
		, '20'       AS AFTR_TYPE  -- 변경할 채권유형 코드
--				  , A.COL2     AS AFTR_RAMT  -- 변경할 채권잔액
--				  , A.COL2     AS AFTR_BDBT_YMD
--				  , A.COL2     AS AFTR_RECV_YMD
--				  , A.COL2     AS AFTR_CPLT_YMD
FROM    IMSI_TB_SHY1   A
 ;

/*******************************************************************************/


------------------------------------------------------------------------------------------
DECLARE
    p_code           VARCHAR2(50);               -- error code
    p_errm           VARCHAR2(5000);             -- error message
    v_count          NUMBER(10);                  -- 갯수

    ---------------------------------------------
    -- request SR bond_ramt working list
    ---------------------------------------------
    CURSOR cur01 IS
       SELECT
        		   A.CLNT_ID                                   		 AS CLNT_ID
        		  ,A.CONT_NO										 AS CONT_NO
        		  ,A.BOND_SEQ										 AS BOND_SEQ
--        		  ,A.AFTR_BDBT_YMD                                   AS AFTR_BDBT_YMD
        		  ,A.AFTR_BOND_TYPE                                  AS AFTR_BOND_TYPE
        		  ,A.CHNG_STAF                                       AS CHNG_STAF
        		  ,A.CHNG_PGM_ID									 AS CHNG_PGM_ID
        		  ,CA01.BDBT_YMD                                     AS BEFO_BDBT_YMD
        		  ,CA01.BOND_TYPE                                    AS BEFO_BOND_TYPE
       FROM
        (SELECT     SUBSTR(TRIM(COL1),1,3)   						 AS CLNT_ID
                  , SUBSTR(TRIM(COL1),5,5)   						 AS CONT_NO
                  , SUBSTR(TRIM(COL1),11,LENGTH(TRIM(COL1))-10)		 AS BOND_SEQ
--				  , TRIM(REPLACE(COL2,'-',''))					 	 AS AFTR_BDBT_YMD
				  , '20'											 AS AFTR_BOND_TYPE
				  , '10067'										 	 AS CHNG_STAF
				  , 'TOAD'                                           AS CHNG_PGM_ID
          FROM    IMSI_TB_SHY1)   A, CA01BOND CA01
          WHERE CA01.USE_YN=' '
          AND CA01.CLNT_ID=A.CLNT_ID
          AND CA01.CONT_NO=A.CONT_NO
          AND CA01.BOND_SEQ=A.BOND_sEQ

           ;

BEGIN
    ---------------------------------------------
    -- 작업
    ---------------------------------------------
    v_count := 0;

    FOR c1 IN cur01 LOOP    
    		IF 	c1.befo_bond_type <> c1.aftr_bond_type   THEN
    	UPDATE CA35OUTL
        SET CHNG_PGM_ID = c1.chng_pgm_id       --변경프로그램ID
           ,USE_YN      = 'D'                 --사용여부
      WHERE CLNT_ID  = c1.clnt_id
        AND CONT_NO  = c1.cont_no
        AND BOND_SEQ = c1.bond_seq
        AND HSTR_KIND_NAME =  '채권유형'
        AND USE_YN   = ' ';

	    INSERT INTO CA35OUTL(
				      CLNT_ID
				     ,CONT_NO
				     ,BOND_SEQ
				     ,DLNG_DATE
				     ,HSTR_KIND_NAME
				     ,CHNG_BEFO_CTEN
				     ,CHNG_AFTR_CTEN
				     ,INPT_STAF
				     ,CHNG_PGM_ID
				     ,USE_YN)
		     VALUES(
			      c1.clnt_id
			     ,c1.cont_no
			     ,c1.bond_seq
			     , sysdate
			     , '채권유형'
			     , (SELECT BOND_TYPE FROM CA01BOND
			         WHERE USE_YN=' ' AND CLNT_ID=c1.clnt_id AND CONT_NO=c1.cont_no AND BOND_SEQ=c1.bond_seq AND ROWNUM =1)
			     ,c1.aftr_bond_type
			     ,c1.chng_staf
			     ,c1.chng_pgm_id
			     ,' '
		     ) ;
     END IF;
        -----------------------------------------
 		--    채권유형(10:일반, 20:특수)
        --  , 상각일자(BDBT_YMD)
        --  , 최종수납일자(LAST_RECV_YMD)
        --  , 이수최종일자(CPLT_LAST_YMD)
        -----------------------------------------
        UPDATE    CA01BOND A
           SET
--           		A.BOND_RAMT =CASE WHEN TO_NUMBER(c1.AFTR_RAMT)= A.BOND_RAMT THEN A.BOND_RAMT ELSE TO_NUMBER(c1.AFTR_RAMT) END,
           		A.BOND_TYPE = CASE WHEN c1.aftr_bond_type = A.BOND_TYPE THEN A.BOND_TYPE ELSE c1.aftr_bond_type END--,
--           		A.BDBT_YMD  = CASE WHEN c1.AFTR_BDBT_YMD=A.BDBT_YMD THEN A.BDBT_YMD ELSE c1.AFTR_BDBT_YMD END,
--           	    A.LAST_RECV_YMD =CASE WHEN c1.AFTR_RECV_YMD=A.LAST_RECV_YMD THEN A.LAST_RECV_YMD ELSE c1.LAST_RECV_YMD END,
--				A.CPLT_LAST_YMD =CASE WHEN c1.AFTR_CPLT_YMD=A.CPLT_LAST_YMD THEN A.CPLT_LAST_YMD ELSE c1.AFTR_CPLT_YMD END
        WHERE    1=1
         AND A.CLNT_ID=c1.clnt_id
         AND A.CONT_NO=c1.cont_no
         AND A.BOND_SEQ=c1.bond_Seq
         AND A.USE_YN   = ' '
         ;

       v_count := v_count + 1;

    END LOOP;

--    COMMIT;
    p_code := sqlcode;
    p_errm := sqlerrm;
    DBMS_OUTPUT.PUT_LINE('총 [' || v_count ||']건의 데이터가 UPDATE처리 되었습니다.');
    DBMS_OUTPUT.PUT_LINE('[p_code]=' || p_code);
    DBMS_OUTPUT.PUT_LINE('[p_errm]=' || p_errm);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_code := sqlcode;
        p_errm := sqlerrm;
        DBMS_OUTPUT.PUT_LINE('EXCEPTION occured.');
        DBMS_OUTPUT.PUT_LINE('[p_code]=' || p_code);
        DBMS_OUTPUT.PUT_LINE('[p_errm]=' || p_errm);
END;


