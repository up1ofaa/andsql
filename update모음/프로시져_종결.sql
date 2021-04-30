SELECT * FROM IMSI_TB_SHY1;
SELECT * FROM CM03STAF
WHERE USE_YN=' '
AND STAF_ID='10029'
 ;

 SELECT
A.NUM
,CA01.CLNT_ID||'-'||CA01.CONT_NO||'-'||CA01.BOND_SEQ
,A.LOAN_NO
,CA01.CUST_NAME
,ca01.end_divi
,ca01.end_date
,A.COL2
,A.COL3
FROM (select clnt_id
			,cont_no
			,bond_Seq
			,loan_no
			,cust_id
			,cust_name
			,end_date
			,end_divi
			,rqst_ymd
			,use_yn
			,rank() over(partition by loan_no order by rqst_ymd desc, cont_no desc, bond_seq desc ) rk
		from	CA01BOND) CA01
,(SELECT ROWNUM NUM
			,TRIM(COL1) LOAN_NO
			,TRIM(COL2) COL2
			,TRIM(COL3) COL3
	FROM IMSI_TB_SHY1 ) A
WHERE CA01.USE_YN(+)=' '
AND CA01.LOAN_NO(+)=A.LOAN_NO
--AND CA01.END_DIVI(+)='00'
--and to_char(ca01.end_date(+),'yyyymmdd')='20180326'
AND CA01.RK(+)=1
ORDER BY A.NUM
;

/* CA01BOND */
SELECT    distinct
		    A.NUM
		  ,	B.LOAN_NO     		 AS LOAN_NO
          , B.CLNT_ID            AS CLNT_ID
          , B.CONT_NO            AS CONT_NO
          , B.BOND_SEQ           AS BOND_SEQ
          , B.CUST_ID            AS CUST_ID
          , B.END_DIVI           AS BEFO_END_DIVI
          , replace(B.CUST_NAME,' ','')          AS CUST_NAME
          , B.END_STAF_ID 		 AS BEFO_END_STAF_ID
          , B.END_DATE    		 AS BEFO_END_DATE
          , B.CHNG_DATE   		 AS BEFO_CHNG_DATE
          , B.CHNG_PGM_ID        AS BEFO_CHNG_PGM_ID
          ,'02'           		 AS AFTR_END_DIVI
          ,CASE WHEN A.CUST_NAME<>replace(B.CUST_NAME,' ','') THEN 'ERR' ELSE '' END AS CUST_ERR
--          ,CASE WHEN A.LOAN_NO<>B.LOAN_NO THEN 'ERR' ELSE '' END 	 AS LOAN_ERR
  FROM   ( SELECT ROWNUM AS NUM
  			,TRIM(COL1)  BOND_NO
  			,SUBSTR(TRIM(COL1),1,3) CLNT_ID
  			,SUBSTR(TRIM(COL1),5,5) CONT_NO
  			,SUBSTR(TRIM(COL1),11,LENGTH(TRIM(COL1))-10) BOND_SEQ
  			,TRIM(COL2) LOAN_NO
  			,TRIM(COL3) CUST_NAME
  			FROM IMSI_TB_SHY1)  A
          ,CA01BOND B
 WHERE    B.CLNT_ID  = A.CLNT_ID
   AND    B.CONT_NO  = A.CONT_NO
   AND    B.BOND_SEQ = A.BOND_SEQ
--   AND    B.END_DIVI = '00'
   AND    B.USE_YN   = ' '
--   AND B.CLNT_ID||'-'||B.CONT_NO||'-'||B.BOND_SEQ='&BOND_NO'
   ORDER BY A.NUM ASC
   ;


/* CA11CHNG */
SELECT imsi.num,IMSI.COL1
	,CA.*
FROM CA11CHNG CA ,
( SELECT ROWNUM AS NUM
  			,TRIM(COL1) COL1
  			FROM IMSI_TB_SHY1) IMSI
WHERE 1=1--CA01.USE_YN=' '
AND CA.CLNT_ID=SUBSTR(imsi.COL1,1,3)
AND CA.CONT_NO=SUBSTR(imsi.COL1,5,5)
AND CA.BOND_SEQ=SUBSTR(imsi.COL1,11,LENGTH(imsi.COL1)-10)
AND TO_CHAR(CA.DLNG_DATE,'YYYYMMDD') LIKE  to_char(sysdate,'yyyymm')||'%'--BETWEEN '20160201' AND '20160427'--16%'
AND (CA.CHNG_AFTR_CTEN LIKE '%종결%'
		OR CA.CHNG_AFTR_CTEN LIKE '%완결%'
		OR CA.CHNG_AFTR_CTEN LIKE '%시효%'
		OR CA.CHNG_AFTR_CTEN LIKE '%완성%'
		OR CA.CHNG_AFTR_CTEN LIKE '%면책%'
		OR CA.CHNG_AFTR_CTEN LIKE '%추심%'
		OR CA.CHNG_AFTR_CTEN LIKE '%정상화%'
		OR CA.CHNG_AFTR_CTEN LIKE '%위탁사매각%'
	 )
--order by imsi.num asc
;--AND INPT_STAF='34615';


select * from ca11chng
where clnt_id='200'
and cont_no='15092'
and bond_Seq='61'
;

/* 중복건조회*/
SELECT TRIM(COL1), COUNT(*)
FROM IMSI_TB_SHY1
WHERE 1=1 	GROUP BY TRIM(COL1) HAVING COUNT(*) >1 -- 변경채권이 리스트에 1건만 존재하는것만
;

/******************************************************************************
 *
 * 제 목 : SR 2008041511932 현대스위스 요청종결 처리
 * 내 용 : SR 오 올라온 현대스위스 요청종결처리를 한다.
 *
   파일작업 : 보통 채권번호/대출번호/고객명/종결코드명 으로 엑셀로 파일을 준다.
              이 파일을 대출번호/위탁사ID/계약번호/채권SEQ/고객명/종결코드 순으로 변경하여준다
              ( 순서만 바꾸며, 채권번호를 나누기하면 3개로 나뉨)
              CSV형식으로 저장하며, 저장된 파일은 Golden 을 통해 import 를 한다.

 * 작업순서 : 01. 올라온 잔액은 IMSI_TB_SHY1 테이블에 INSERT 한후 작업한다.
 *            (COL1:위탁사ID, COL2:계약번호, COL3:채권SEQ)
 *            02. CURSOR SQL 로 변경할 건수를 테스트한다.
 *            03. 이 SQL 을 수행하여 데이터를 UPDATE 한다.
 *            04. UPDATE 후에 확인한다. (CA01BOND 종결코드, 채권변경사항 INSERT)
 *
 *****************************************************************************/
DECLARE
    p_code           VARCHAR2(50);               -- error code
    p_errm           VARCHAR2(5000);             -- error message
    v_count          NUMBER(5);                  -- 갯수
    v_befr_cten      CA11CHNG.CHNG_BEFO_CTEN%TYPE;
    v_aftr_cten      CA11CHNG.CHNG_AFTR_CTEN%TYPE;

    ---------------------------------------------
    -- request SR bond_ramt working list
    -- 현재진행중인 건만 종결처리함.
    ---------------------------------------------
    CURSOR cur01 IS
        SELECT    distinct B.LOAN_NO              AS LOAN_NO
                  , B.CLNT_ID            AS CLNT_ID
                  , B.CONT_NO            AS CONT_NO
                  , B.BOND_SEQ           AS BOND_SEQ
                  , B.CUST_ID            AS CUST_ID
                  , B.END_DIVI           AS END_DIVI
                  , B.CUST_NAME          AS CUST_NAME
                  , '34208'				 AS STAF_ID    --34208
                  , '02' 	             AS CHNG_END_DIVI --변경할,입력할 종결사유
                  										  --01:변제완결, 02:요청종결, 06:시효완성, 03:추심중단 , 05:정상화, 13:위탁사매각S
                  										  --08:면책결정
          FROM    IMSI_TB_SHY1  A
                  , CA01BOND B
         WHERE    B.CLNT_ID  = SUBSTR(TRIM(A.COL1),1,3)
           AND    B.CONT_NO  = SUBSTR(TRIM(A.COL1),5,5)
           AND    B.BOND_SEQ = SUBSTR(TRIM(A.COL1),11,LENGTH(TRIM(A.COL1))-10)
           AND    B.END_DIVI = '00'
           AND    B.USE_YN   = ' '
           ;

BEGIN
    ---------------------------------------------
    -- 작업
    ---------------------------------------------
    v_count := 0;

    FOR c1 IN cur01 LOOP
        -----------------------------------------
        -- 종결 update
        -- CA01BOND : CLNT_ID, CONT_NO, BOND_SEQ
        -----------------------------------------
        UPDATE    CA01BOND A
           SET    A.END_DIVI      = c1.CHNG_END_DIVI
                  , A.END_STAF_ID = c1.STAF_ID   --종결요청자 사번
                  , A.END_DATE    = SYSDATE
                  , A.CHNG_DATE   = SYSDATE
                  , A.CHNG_PGM_ID = 'TOAD'
         WHERE    A.CLNT_ID  = c1.clnt_id
           AND    A.CONT_NO  = c1.cont_no
           AND    A.BOND_SEQ = c1.bond_seq
           AND    A.END_DIVI = '00'
           AND    A.USE_YN   = ' ';

        -----------------------------------------
        -- 변경내용 구성
        -----------------------------------------
        v_befr_cten := c1.END_DIVI || ' ' || COMM_FUNC.F_GET_CODE_NAME('END_DIVI', c1.END_DIVI);
        v_aftr_cten := c1.CHNG_END_DIVI || ' ' || COMM_FUNC.F_GET_CODE_NAME('END_DIVI', c1.CHNG_END_DIVI);

        --------------------------------------------------------------
        -- 채권변경이력에 INSERT
        -- CA11CHNG : CLNT_ID, CONT_NO, BOND_SEQ, DLNG_DATE
        --------------------------------------------------------------
     INSERT INTO CA11CHNG VALUES (
        c1.clnt_id,  c1.cont_no,  c1.bond_seq,   SYSDATE,     '08',    --02.담당자변경 03.보증인정보변경  08.위탁종결
        v_befr_cten, '',          '',            v_aftr_cten,    '',
        '',          c1.STAF_ID ,    'TOAD',        ' '                --종결요청자 사번
      );
      v_count := v_count + 1;
   -- COMMIT;
    END LOOP;

   -- COMMIT;
    p_code := sqlcode;
    p_errm := sqlerrm;
    DBMS_OUTPUT.PUT_LINE('총 [' || v_count ||']건의 데이터가 종결처리 되었습니다.');
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
