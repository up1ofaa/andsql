/*종결 경과건 특이사항 입력하기 위함*/
-- select
--a.num
--,a.bond_no
--,ca01.cust_id
--,a.memo
--from --ca01bond ca01
--ya01temp ca01
--,(select ROWNUM 										NUM
--	,SUBSTR(trim(COL1),1,3) 						CLNT_ID
--	,SUBSTR(trim(COL1), 5,5)						CONT_NO
--	,SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)  BOND_SEQ
--	,trim(COL1)  									BOND_NO
--	--,COMM_FUNC.f_get_cust_id('2',TRIM(COL1))  			CUST_ID
--	,'주채무자'                                     DEBT_DIVI
--	,LTRIM(COL2)      						 		MEMO
--	from imsi_tb_shy1) a
--where ca01.use_yn(+)=' '
--and ca01.clnt_id(+)=a.clnt_id
--and ca01.cont_no(+)=a.cont_no
--and ca01.bond_seq(+)=a.bond_seq
--;

SELECT
TEAM_CODE, STAF_NAME--, TEAM_NAME
FROM CM03STAF
WHERE STAF_ID='34615'
;


/*CA01BOND에서 비교, 주채무자건인지*/
SELECT
 IMSI.NUM
,IMSI.BOND_NO			 AS 채권번호
,CA01.CUST_NAME			 AS 채무자명
,IMSI.CUST_ID			 AS 고객ID
--,IMSI.DEBT_DIVI          AS 채무구분
,IMSI.MEMO 				 AS AFTR_MEMO
--,CASE WHEN CA01.CUST_NAME<>IMSI.CUST_NAME
-- THEN '주채무자건이 아닙니다'
-- ELSE '' END AS ERR
FROM CA01BOND CA01,
(select ROWNUM 										NUM
	,SUBSTR(trim(COL1),1,3) 						CLNT_ID
	,SUBSTR(trim(COL1), 5,5)						CONT_NO
	,SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)  BOND_SEQ
	,trim(COL1)  									BOND_NO
	,COMM_FUNC.f_get_cust_id('2',TRIM(COL1))  		CUST_ID
	,'주채무자'                                     DEBT_DIVI
	,LTRIM(COL2)      						 		MEMO
--	,CASE WHEN TRIM(COL3) IS NOT NULL THEN TRIM(COL3)
--	      ELSE COMM_FUNC.f_get_cust_id('2',TRIM(COL1))
--	      END										 CUST_ID
--	,trim(COL2) 									CUST_NAME
--	,(SELECT CA02.CUST_ID
--		FROM CA02RELN CA02
--		WHERE 1=1
--		AND CA02.USE_YN=' '
--		AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
--		AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
--		AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
--		AND CA02.CUST_NAME=TRIM(COL2)    )   		CUST_ID
--	,LTRIM(COL3)      						 		MEMO
--	,(SELECT COMM_FUNC.F_GET_CODE_NAME('DEBT_DIVI', CA02.DEBT_DIVI)
--		FROM CA02RELN CA02
--		WHERE 1=1
--		AND CA02.USE_YN=' '
--		AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
--		AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
--		AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
--		AND CA02.CUST_NAME=TRIM(COL2))   			DEBT_DIVI

FROM IMSI_TB_SHY1 ) IMSI
WHERE CA01.USE_YN(+)=' '
AND CA01.CLNT_ID(+)=IMSI.CLNT_ID
AND CA01.CONT_NO(+)=IMSI.CONT_NO
AND CA01.BOND_SEQ(+)=IMSI.BOND_SEQ
ORDER BY IMSI.NUM ASC
;
SELECT *
FROM IMSI_TB_SHY1;

/*CA16MEMO*/
SELECT TT.*
FROM
(SELECT
CA16.CLNT_ID
,CA16.CUST_ID
,CA16.INPT_TMSP
,CA16.MEMO
,CA16.INPT_STAF
,CA16.CHNG_PGM_ID
,RANK() OVER (PARTITION BY CA16.CLNT_ID, CA16.CUST_ID ORDER BY CA16.INPT_TMSP DESC) AS LAST_RANK
FROM CA16MEMO CA16
,(select ROWNUM 									NUM
	,SUBSTR(trim(COL1),1,3) 						CLNT_ID
	,SUBSTR(trim(COL1), 5,5)						CONT_NO
	,SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)  BOND_SEQ
	,trim(COL1)  									BOND_NO
--	,(SELECT CUST_ID
--		FROM CA02RELN CA02
--		WHERE CA02.USE_YN=' '
--		AND CA02.CLNT_ID= SUBSTR(trim(COL1),1,3)
--		AND CA02.CONT_NO= SUBSTR(trim(COL1), 5,5)
--		AND CA02.BOND_SEQ=SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)
--		AND CA02.CUST_NAME = TRIM(COL2)
--		AND ROWNUM =1)								CUST_ID
	,COMM_FUNC.f_get_cust_id('2',TRIM(COL1))  		CUST_ID
	,'주채무자'                                     DEBT_DIVI
	,LTRIM(COL2)      						 		MEMO
--	,LTRIM(COL3)      						 		MEMO
--	,CASE WHEN TRIM(COL3) IS NOT NULL THEN TRIM(COL3)
--	      ELSE COMM_FUNC.f_get_cust_id('2',TRIM(COL1))
--	      END										 CUST_ID
FROM IMSI_TB_SHY1 ) IMSI
WHERE CA16.USE_YN=' '
AND CA16.CLNT_ID=IMSI.CLNT_ID
AND CA16.CUST_ID=IMSI.CUST_ID
AND CA16.INPT_TMSP LIKE to_char(sysdate,'yyyymmdd')||'%'
AND CA16.CUST_ID IS NOT NULL and ca16.cust_id <>' '
) TT
WHERE TT.LAST_RANK=1
;

/*중복건 조회*/
SELECT
  A.*
FROM
 (select ROWNUM 										NUM
	,SUBSTR(trim(COL1),1,3) 						CLNT_ID
	,SUBSTR(trim(COL1), 5,5)						CONT_NO
	,SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)  BOND_SEQ
	,trim(COL1)  									BOND_NO
	,COMM_FUNC.f_get_cust_id('2',COL1)  			CUST_ID
	FROM IMSI_TB_SHY1 ) A
WHERE a.CUST_ID IN (
				SELECT CUST_ID
				FROM (select ROWNUM 										NUM
					,SUBSTR(trim(COL1),1,3) 						CLNT_ID
					,SUBSTR(trim(COL1), 5,5)						CONT_NO
					,SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)  BOND_SEQ
					,trim(COL1)  									BOND_NO
					,COMM_FUNC.f_get_cust_id('2',COL1)  			CUST_ID
--					,CASE WHEN TRIM(COL3) IS NOT NULL THEN TRIM(COL3)
--				      ELSE COMM_FUNC.f_get_cust_id('2',TRIM(COL1))
--				      END										 CUST_ID
--	                  ,(SELECT CA02.CUST_ID
--						FROM CA02RELN CA02
--						WHERE 1=1
--						AND CA02.USE_YN=' '
--						AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
--						AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
--						AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
--						AND CA02.CUST_NAME=TRIM(COL2)    )  AS  CUST_ID
					FROM IMSI_TB_SHY1 ) IMSI
					GROUP BY CUST_ID HAVING COUNT(*)>1
				)
and a.cust_id is not null
order by a.num asc
	;

SELECT  *   FROM CM03STAF WHERE STAF_ID='10177';

/* 중복조인 제거 , 입력한 갯수대로 산출*/
SELECT
A.NUM, CA16.CUST_ID,
 CA16.MEMO , CA16.INPT_tMSP
FROM CA16MEMO CA16
, (select ROWNUM 									NUM
	,SUBSTR(trim(COL1),1,3) 						CLNT_ID
	,SUBSTR(trim(COL1), 5,5)						CONT_NO
	,SUBSTR(trim(COL1), 11, LENGTH(trim(COL1))-10)  BOND_SEQ
	,trim(COL1)  									BOND_NO
	,COMM_FUNC.f_get_cust_id('2',COL1)  			CUST_ID
	FROM IMSI_TB_SHY1 ) A
WHERE 1=1
AND CA16.INPT_TMSP LIKE '20161228%'
AND CA16.USE_YN=' '
AND CA16.CLNT_ID=A.CLNT_ID
AND CA16.CUST_ID=COMM_FUNC.f_get_cust_id('2', A.BOND_NO)

;

/*변경건 타당성 검사*/
SELECT
B.NUM
,B.BOND_NO
--,B.CUST_NAME
,B.CLNT_ID
,B.CUST_ID
,B.MEMO
,A.CNT
FROM
(SELECT 		 ROWNUM 								NUM
			,SUBSTR(COL1,1,3) 					CLNT_ID
			,SUBSTR(COL1, 5,5)					CONT_NO
			,SUBSTR(COL1, 11, LENGTH(COL1)-10)  BOND_SEQ
			,COL1  								BOND_NO
			,COMM_FUNC.f_get_cust_id('2', COL1) AS CUST_ID
--			,trim(COL2) 						CUST_NAME
--			,(SELECT CA02.CUST_ID
--				FROM CA02RELN CA02
--				WHERE 1=1
--				AND CA02.USE_YN=' '
--				AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
--				AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
--				AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
--				AND CA02.CUST_NAME=TRIM(COL2)    )   CUST_ID
			,LTRIM(COL2)      						 MEMO
FROM IMSI_TB_SHY1) B
,(select
	 imsi.clnt_id
	,imsi.cust_id
	,count(*)    AS CNT
	from      (
	       	SELECT    rownum as num
				      , SUBSTR(COL1,1,3)   AS CLNT_ID
	                  , SUBSTR(COL1,5,5)   AS CONT_NO
	                  , SUBSTR(COL1,11,LENGTH(COL1)-10)	 AS BOND_SEQ
	                  , COMM_FUNC.f_get_cust_id('2', COL1) AS CUST_ID
--	                  ,(SELECT CA02.CUST_ID
--						FROM CA02RELN CA02
--						WHERE 1=1
--						AND CA02.USE_YN=' '
--						AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
--						AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
--						AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
--						AND CA02.CUST_NAME=TRIM(COL2)    )  AS  CUST_ID
	                  , LTRIM(COL2)			 AS MEMO
	          FROM    IMSI_TB_SHY1
	          ) imsi
	group by imsi.clnt_id, imsi.cust_id) A
WHERE 1=1
AND B.CLNT_ID=A.CLNT_ID
AND B.CUST_ID=A.CUST_ID
ORDER BY B.NUM
;


/*중복건이 없을경우*/

       SELECT DISTINCT
				 A.NUM
				,A.CLNT_ID AS CLNT_ID
				,A.CUST_ID AS CUST_ID
				,A.MEMO    AS MEMO
		FROM (SELECT ROWNUM NUM
					,SUBSTR(TRIM(COL1),1,3) 					CLNT_ID
					,SUBSTR(TRIM(COL1), 5,5)					CONT_NO
					,SUBSTR(TRIM(COL1), 11, LENGTH(TRIM(COL1))-10)  BOND_SEQ
					,TRIM(COL1)  								BOND_NO
--					,COMM_FUNC.f_get_cust_id('2',TRIM(COL1))  CUST_ID
--					,trim(COL2) 						CUST_NAME
					,(SELECT CA02.CUST_ID
						FROM CA02RELN CA02
						WHERE 1=1
						AND CA02.USE_YN=' '
						AND CA02.CLNT_ID=SUBSTR(TRIM(COL1),1,3)
						AND CA02.CONT_NO=SUBSTR(TRIM(COL1), 5,5)
						AND CA02.BOND_SEQ=SUBSTR(TRIM(COL1), 11, LENGTH(TRIM(COL1))-10)
						AND CA02.CUST_NAME=TRIM(COL2)    )   CUST_ID
					,LTRIM(COL3)      						 MEMO
--					,LTRIM(COL2)      						 MEMO
			FROM IMSI_TB_SHY1 ) A
			WHERE A.CUST_ID IS NOT NULL
			ORDER BY A.NUM ASC
 ;
  SELECT DISTINCT
		 A.NUM,
		 A.CLNT_ID
		,a.bond_no
		,A.CUST_NAME
		,case when A.CUST_ID is null
		      then (select cust_id
		            from ca02reln
		            where use_yn=' '
		            and clnt_id=a.clnt_id
		            and cont_no=a.cont_no
		            and bond_seq=a.bond_seq
		            and cust_name=substr(a.cust_name,0,3))
		      else a.cust_id end               as cust_id
		,CASE WHEN A.DEBT_DIVI IS NULL
			  THEN (select COMM_FUNC.F_GET_CODE_NAME('DEBT_DIVI', DEBT_DIVI)
		            from ca02reln
		            where use_yn=' '
		            and clnt_id=a.clnt_id
		            and cont_no=a.cont_no
		            and bond_seq=a.bond_seq
		            and cust_name=substr(a.cust_name,0,3))
		      ELSE A.DEBT_DIVI END             AS  DEBT_DIVI
		,A.MEMO
FROM (SELECT ROWNUM 							NUM
			,SUBSTR(COL1,1,3) 					CLNT_ID
			,SUBSTR(COL1, 5,5)					CONT_NO
			,SUBSTR(COL1, 11, LENGTH(COL1)-10)  BOND_SEQ
			,COL1  								BOND_NO
			,trim(COL2) 						CUST_NAME
			,(SELECT CA02.CUST_ID
				FROM CA02RELN CA02
				WHERE 1=1
				AND CA02.USE_YN=' '
				AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
				AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
				AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
				AND CA02.CUST_NAME=TRIM(COL2)    )   CUST_ID
			,(SELECT COMM_FUNC.F_GET_CODE_NAME('DEBT_DIVI', CA02.DEBT_DIVI)
				FROM CA02RELN CA02
				WHERE 1=1
				AND CA02.USE_YN=' '
				AND CA02.CLNT_ID=SUBSTR(COL1,1,3)
				AND CA02.CONT_NO=SUBSTR(COL1, 5,5)
				AND CA02.BOND_SEQ=SUBSTR(COL1, 11, LENGTH(COL1)-10)
				AND CA02.CUST_NAME=TRIM(COL2)    )   DEBT_DIVI
			,LTRIM(COL3)      						 MEMO
	FROM IMSI_TB_SHY1 ) A
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

       SELECT DISTINCT
				 A.CLNT_ID AS CLNT_ID
				,A.CUST_ID AS CUST_ID
				,A.MEMO    AS MEMO
				,A.STAF_ID AS STAF_ID
				,(SELECT M.TEAM_CODE
						FROM CM03STAF M
						WHERE M.STAF_ID=A.STAF_ID
						AND M.USE_YN=' '
						AND ROWNUM=1 ) AS TEAM_CODE
		FROM (SELECT SUBSTR(TRIM(COL1),1,3) 					CLNT_ID
					,SUBSTR(TRIM(COL1), 5,5)					CONT_NO
					,SUBSTR(TRIM(COL1), 11, LENGTH(TRIM(COL1))-10)  BOND_SEQ
					,TRIM(COL1)  								BOND_NO
					,COMM_FUNC.f_get_cust_id('2',TRIM(COL1))  CUST_ID
--					,CASE WHEN TRIM(COL3) IS NOT NULL THEN TRIM(COL3)
--				      ELSE COMM_FUNC.f_get_cust_id('2',TRIM(COL1))
--				      END										 CUST_ID
--					,trim(COL2) 						CUST_NAME
--					,(SELECT CA02.CUST_ID
--						FROM CA02RELN CA02
--						WHERE 1=1
--						AND CA02.USE_YN=' '
--						AND CA02.CLNT_ID=SUBSTR(TRIM(COL1),1,3)
--						AND CA02.CONT_NO=SUBSTR(TRIM(COL1), 5,5)
--						AND CA02.BOND_SEQ=SUBSTR(TRIM(COL1), 11, LENGTH(TRIM(COL1))-10)
--						AND CA02.CUST_NAME=TRIM(COL2)    )   CUST_ID
--					,LTRIM(COL3)      						 MEMO
					,LTRIM(COL2)      						 MEMO
					,'34208'								 STAF_ID   -- 변경요청 staf_id ex) 34208 (조용수)
			FROM IMSI_TB_SHY1 ) A
            WHERE A.CUST_ID IS NOT NULL and a.cust_id not in (' ')
           ;
BEGIN
    ---------------------------------------------
    -- 작업
    ---------------------------------------------
    v_count := 0;
    FOR c1 IN cur01 LOOP
        -----------------------------------------
        -- 특이사항 CA16MEMO insert
        -- PK :  CLNT_ID, CUST_ID, INPT_TMSP
        -----------------------------------------
        INSERT INTO CA16MEMO
        VALUES(
		        c1.clnt_id
		        , c1.cust_id
				, substr(to_char(systimestamp ,'yyyymmddhh24missxff'), 1, 21)
				, c1.memo
				, c1.team_code
				, c1.staf_id
				, NULL
				, NULL
				,'TOAD'
				, NULL
				, NULL
				, ' '		);

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


