/*최종우편물직전우편물발송일자

방법1. 최종우편물발송일자 MAX(SEND_YMD)를 제외한 레코드에서 가장큰 SEND_YMD를 구하는 방식
방법2. RANK로 위탁사,고객번호별로 SEND_YMD 순위를 매겨 2위인 값 추출

(1) DENSE_RANK() OVER , RANK() OVER의 차이 : 
  공동순위 다음 값이 연속적인 숫자일경우가 DENSE_RANK() OVER,  => 순위 1,2,3
  공동순위 갯수만큼 다음순위가 커지는것이 RANK() OVER    =>  순위 1,1,1,4
(2) (PATITION BY col1, col2 ORDER BY col3 DESC)
   col1, col2를 그룹화하여(같은값을 가지는) col3값을 내림차순하여 순위를 매긴다   
(3) ,DENSE_RANK() OVER  (PARTITION BY C8.CLNT_ID, C8.CUST_ID ORDER BY C8.SEND_YMD DESC) "RANK"   
   위탁사와 고객아이디가 같은 그룹내에서 발송일자를 순위를 매긴 항목을 "RANK"로 지정
 
 ---날짜 내림차순은 최근값  먼저
 ---금액 내림차순은 큰값    먼저
 -- 채권번호 내림차순  큰값  최근순    
 
 (4)  특정 구분코드를 DECODE로 순위를 만들어 순위매기기
 ,RANK() OVER( PARTITION BY LO01.CLNT_ID, LO01.CONT_NO, LO01.BOND_SEQ 
 				ORDER BY DECODE(LAWS_DIVI, '20', 1, '30', 2, '10', 3, LAWS_DIVI)  ASC, LO03.RQST_NO DESC ) AS RANK_SEQ

*/  



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

-- 방법 1 
SELECT  DISTINCT
		  CA02.CLNT_ID 												AS 위탁사코드
		, CA02.CUST_ID 												AS 고객ID
		,(SELECT  TRIM(MAX(CA08.SEND_YMD))
		  FROM CA08MAIL CA08
		  WHERE CA08.CUST_ID = CA02.CUST_ID
		  AND CA08.USE_YN = ' '
		  AND CA08.CNCL_YN = 'N'
		  AND CA08.SEND_YMD IS NOT NULL
		  AND EXISTS(SELECT 1 FROM CA08MLLN CA09
		                      WHERE CA09.MAIL_ADMN_NO = CA08.MAIL_ADMN_NO
		                       AND CA09.CLNT_ID = CA02.CLNT_ID)
		  AND TRIM(CA08.SEND_YMD)<>(SELECT TRIM(MAX(C8.SEND_YMD)) FROM CA08MAIL C8
		   							WHERE C8.USE_YN=' ' AND C8.CUST_ID=CA02.CUST_ID
		   							AND C8.CNCL_YN='N' AND C8.SEND_YMD IS NOT NULL
		   							AND EXISTS (SELECT 1 FROM CA08MLLN C09
			                        WHERE C09.MAIL_ADMN_NO = C8.MAIL_ADMN_NO
				                        AND C09.CLNT_ID = CA02.CLNT_ID))
		) 	 														AS 최종우편물직전우편물발송일자
FROM CA01BOND CA01, CA02RELN CA02
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND CA01.CLNT_ID IN('004','050','060','090','097')
AND CA01.END_DIVI='00'
AND CA01.TEAM_CODE='8050'  ;


-- 방법 2
SELECT
	  DISTINCT
	  CA02.CLNT_ID AS 위탁사코드
	, CA02.CUST_ID AS 고객ID
	, TMP.SEND_YMD AS 최종우편물직전우편물발송일자
FROM CA01BOND CA01, CA02RELN CA02
	  ,(SELECT
	  				DISTINCT
 		 			 C8.CLNT_ID   AS CLNT_ID
 		 			,C8.CUST_ID   AS CUST_ID
 		 			,C8.SEND_YMD  AS SEND_YMD
 					,DENSE_RANK() OVER  (PARTITION BY C8.CLNT_ID, C8.CUST_ID ORDER BY C8.SEND_YMD DESC) "RANK"
 			FROM CA08MAIL C8, CA02RELN C2 --,CA01BOND CA01
			WHERE 1=1
			AND C2.USE_YN=' '
			AND C8.USE_YN=' '
			AND C8.CNCL_YN = 'N'
			AND C2.CLNT_ID IN('004','050','060','090','097')
			AND C8.CLNT_ID=C2.CLNT_ID
			AND C8.CUST_ID=C2.CUST_ID) TMP
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND CA02.CLNT_ID =TMP.CLNT_ID(+)
AND CA02.CUST_ID=TMP.CUST_ID(+)
AND TMP.RANK(+)=2
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND CA01.CLNT_ID IN('004','050','060','090','097')
AND CA01.END_DIVI='00'
AND CA01.TEAM_CODE='8050'  ;



-- DENSE_RANK , RANK 차이
SELECT 	DISTINCT
		 C8.CLNT_ID   AS CLNT_ID
		,C8.CUST_ID   AS CUST_ID
		,C8.SEND_YMD  AS SEND_YMD
		,DENSE_RANK() OVER  (PARTITION BY C8.CLNT_ID, C8.CUST_ID  ORDER BY C8.SEND_YMD DESC) "RANK"
FROM CA08MAIL C8, CA02RELN C2 --,CA01BOND CA01
WHERE 1=1
AND C2.USE_YN=' '
AND C8.USE_YN=' '
AND C8.CNCL_YN = 'N'
AND C2.CLNT_ID IN('004','050','060','090','097')
AND C8.CLNT_ID=C2.CLNT_ID
AND C8.CUST_ID='12707010001';

SELECT 	DISTINCT
 	    C8.CLNT_ID   AS CLNT_ID
 	   ,C8.CUST_ID   AS CUST_ID
 	   ,C8.SEND_YMD  AS SEND_YMD
 	   ,RANK() OVER  (PARTITION BY C8.CLNT_ID, C8.CUST_ID ORDER BY C8.SEND_YMD) "RANK"
FROM CA08MAIL C8, CA02RELN C2 --,CA01BOND CA01
WHERE 1=1
AND C2.USE_YN=' '
AND C8.USE_YN=' '
AND C8.CNCL_YN = 'N'
AND C2.CLNT_ID IN('004','050','060','090','097')
AND C8.CLNT_ID=C2.CLNT_ID
AND C8.CUST_ID='12407180001';


SELECT
	  				DISTINCT
 		 			 C8.CLNT_ID   AS CLNT_ID
 		 			,C8.CUST_ID   AS CUST_ID
 		 			,C8.SEND_YMD  AS SEND_YMD
 					,RANK(SEND_YMD) OVER  (PARTITION BY C8.CLNT_ID, C8.CUST_ID ORDER BY C8.SEND_YMD) "RANK"
 			FROM CA08MAIL C8, CA02RELN C2 --,CA01BOND CA01
			WHERE 1=1
			AND C2.USE_YN=' '
			AND C8.USE_YN=' '
			AND C8.CNCL_YN = 'N'
			AND C2.CLNT_ID IN('004','050','060','090','097')
			AND C8.CLNT_ID=C2.CLNT_ID
			AND C8.CUST_ID='12407180001';

SELECT  SEND_YMD FROM CA08MAIL WHERE CLNT_ID='004' AND CUST_ID='12707010001' AND CNCL_YN='N' AND USE_YN=' ' ORDER BY SEND_YMD;
SELECT * FROM CA01BOND WHERE CUST_ID='12407180001' AND USE_YN=' ';
SELECT * FROM CA02RELN WHERE CUST_ID='12407180001' AND USE_YN=' ';



SELECT  DISTINCT
		  CA02.CLNT_ID 												AS 위탁사코드
		, CA02.CUST_ID 												AS 고객ID
		,(SELECT  TRIM(MAX(CA08.SEND_YMD))
		  FROM CA08MAIL CA08
		  WHERE CA08.CUST_ID = CA02.CUST_ID
		  AND CA08.USE_YN = ' '
		  AND CA08.CNCL_YN = 'N'
		  AND CA08.SEND_YMD IS NOT NULL
		  AND EXISTS(SELECT 1 FROM CA08MLLN CA09
		                      WHERE CA09.MAIL_ADMN_NO = CA08.MAIL_ADMN_NO
		                       AND CA09.CLNT_ID = CA02.CLNT_ID)
		  AND TRIM(CA08.SEND_YMD)<>(SELECT TRIM(MAX(C8.SEND_YMD)) FROM CA08MAIL C8
		   							WHERE C8.USE_YN=' ' AND C8.CUST_ID=CA02.CUST_ID
		   							AND C8.CNCL_YN='N' AND C8.SEND_YMD IS NOT NULL
		   							AND EXISTS (SELECT 1 FROM CA08MLLN C09
			                        WHERE C09.MAIL_ADMN_NO = C8.MAIL_ADMN_NO
				                        AND C09.CLNT_ID = CA02.CLNT_ID))
		) 	 															AS 최종우편물직전우편물발송일자
FROM CA01BOND CA01, CA02RELN CA02
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND CA01.CLNT_ID IN('004','050','060','090','097')
AND CA01.END_DIVI='00'
AND CA01.TEAM_CODE='8050'  ;



SELECT * FROM CA08MAIL WHERE CLNT_ID='004' AND CUST_ID='12407180001' AND CNCL_YN='N' AND USE_YN=' ';
SELECT * FROM CA01BOND WHERE CUST_ID='12407180001' AND USE_YN=' ';
SELECT * FROM CA02RELN WHERE CUST_ID='12407180001' AND USE_YN=' ';


SELECT
clnt_id, cust_id
,send_ymd
,RANK() OVER(ORDER BY TRIM(SEND_YMD) desc) "rank"
from ca08mail
where clnt_id='090'
and cust_id='15410050088'    --
;

/*      특정 구분코드를 DECODE로 순위를 만들어 순위매기기
 ,RANK() OVER( PARTITION BY LO01.CLNT_ID, LO01.CONT_NO, LO01.BOND_SEQ 
 				ORDER BY DECODE(LAWS_DIVI, '20', 1, '30', 2, '10', 3, LAWS_DIVI)  ASC, LO03.RQST_NO DESC ) AS RANK_SEQ

*/  

SELECT
 *
FROM  CA01BOND CA01
,(SELECT LO01.CLNT_ID
		,LO01.CONT_NO
		,LO01.BOND_SEQ
        ,LO02.CUST_ID
        ,LO02.PROP_SEQ
        ,LO02.PROP_TYPE
		,LO03.RQST_NO
		,LO03.LAWS_DIVI
		,LO03.LAWS_KIND
		,LO03.APLY_DIVI
		,LO03.APLY_YMD
		,LO03.APLY_AMT_DMND_AMT
        ,LO03.PROG_STEP
		,LO03.JRDT_CURT
		,LO03.JRDT_SUPT
		,LO03.LAWS_FIXD_YMD
		,LO03.DCSN_YMD     --판결일자(소송,20), 결정일자(가압류,10), 개시일자(경매, 30)
		,LO03.END_DIVI
		,LO03.END_YMD
		,LO03.ADD_MANG_ATTD_YN																 --소송(20), 경매(30), 가압류(10)
 		,RANK() OVER( PARTITION BY LO01.CLNT_ID, LO01.CONT_NO, LO01.BOND_SEQ ORDER BY DECODE(LAWS_DIVI, '20', 1, '30', 2, '10', 3, LAWS_DIVI)  ASC, LO03.RQST_NO DESC ) AS RANK_SEQ
	FROM LO01BOND LO01, LO02DEBT LO02, LO03LEGL LO03
	WHERE 1=1
	AND LO01.RQST_NO = LO03.RQST_NO
	AND LO01.RQST_NO = LO02.RQST_NO(+)
	AND EXISTS ( SELECT 1
					FROM CA01BOND
					WHERE 1=1
					AND CLNT_ID = LO01.CLNT_ID
					AND CONT_NO = LO01.CONT_NO
					AND BOND_SEQ = LO01.BOND_SEQ
					AND TEAM_CODE IN('8010','2032','2033','4060','4020','4045','4050', '2060')--팀코드(8010: 전략영업팀), 마케팅지원팀2060도 포함
						AND CLNT_ID NOT IN ('001', '002', '003')  	  --전략영업팀 보유 위탁사
					AND END_DIVI = '00'--종결구분(00: 진행)
					AND USE_YN = ' ' )
	AND LO01.USE_YN = ' '
 	AND LO02.USE_YN(+) = ' '
	AND LO03.USE_YN = ' '
 )	LAW  
WHERE  1=1
AND CA01.TEAM_CODE IN('8010','2032','2033','4060','4020','4045','4050', '2060')--팀코드(8010: 전략영업팀), 마케팅지원팀2060도 포함
AND CA01.CLNT_ID NOT IN ('001', '002', '003')  	  --전략영업팀 보유 위탁사
AND CA01.END_DIVI='00' -- 진행
AND LAW.RANK_SEQ(+)='1' 






