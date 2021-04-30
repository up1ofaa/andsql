/*위탁사	채권번호	당월신규여부	대출번호	해촉구분
금액구분	종결일자	종결월	종결구분	담당부서	담당자
채무구분	채무자	활동그룹	이수최종일	응당일자
최종회수금입금일자	시효기산일	시효완성일	시효완성월	시효도래구분
수임일	수임액	당월기초	당월기말

  해촉구분 : 당월초에 자료를 출력하고자하면 전월로 설정
  금액구분 :  현잔고기준 5백만미만, 1천만미만, 1천만이상, 3천만이상, 5천만이상 으로 구분하여 기재 요청
  시효기산일 : 해촉일자(이수최종일), 최종회수금입금일자,법무결정일,법무확정일자중 가장최근일자 기입 요청
  시효완성일 : 시효기산일 + 5년하루전일자 기입요청(단, 법무결정일 또는 법무확정일자의 경우 +10년하루전일자 기입요청)
  시효도래구분 : 	1. 시효완성추정('15.12월1일이전)
					2. '15.12월시효도래
					3. '16.01월시효도래
					4. '16.02월시효도래
					5. '16.03월이후시효도래
					위항목에 해당하는 값으로 구분하여 기입요청 
	--전략영업팀보유, 위탁3사를 제외한 지점,마케팅지원팀 포함 전건
*/


-- GREATEST와 LEAST사용하기

	SELECT distinct
	   TT.위탁사
      ,TT.채권번호
	  ,TT.당월신규여부
	  ,TT.대출번호
	  ,TT.이수최종일
	  ,TT.응당일
	  ,TT."시효기산일1"
	  ,TT.시효기산일
	  ,case when TT."시효기산일1"=TT.시효기산일
	  		THEN '' ELSE '1' END AS 시효기산일일치
	  ,case when TT."시효기산일1" ='20080229' THEN '20130228'
	        when TT."시효기산일1" ='20120229' THEN '20170228'
	        when TT."시효기산일1"  ='20160229' THEN '20210228'
            ELSE TT."시효완성일1" END AS "시효완성일1"
	  ,case when TT.시효기산일 ='20080229' THEN '20130228'
	        when TT.시효기산일 ='20120229' THEN '20170228'
	        when TT.시효기산일 ='20160229' THEN '20210228'
            ELSE TT.시효완성일 END AS 시효완성일
      ,case when TT."시효완성일1"=TT.시효완성일
      		THEN '' ELSE '1' END AS 시효완성일일치
	  ,case when TT."시효기산일1"  ='20080229' THEN '201302'
	        when TT."시효기산일1"  ='20120229' THEN '201702'
	        when TT."시효기산일1"  ='20160229' THEN '202102'
            ELSE SUBSTR(TT."시효완성일1", 1,6) END  AS "시효완성년월1"
      	  ,case when TT.시효기산일 ='20080229' THEN '201302'
	        when TT.시효기산일 ='20120229' THEN '201702'
	        when TT.시효기산일 ='20160229' THEN '202102'
            ELSE SUBSTR(TT.시효완성일, 1,6) END  AS 시효완성년월
	  ,case when (TT."시효완성일1" is null AND TT."시효기산일1" NOT IN ('20080229','20120229','20160229')) then ''
		  when (TT."시효완성일1" between '20160501' and '99999999' ) then '16.05월이후시효도래'
		  when (TT."시효완성일1" between '20160401' and '20160430' ) then '16.04월시효도래'
		  when (TT."시효완성일1" between '20160301' and '20160331' ) then '16.03월시효도래'
		  when (TT."시효완성일1" between '20160201' and '20160229' ) then '16.02월시효도래'
		  when (TT."시효완성일1" between '00000001' and '20160131' ) then '시효완성추정'
	      else '' end as "시효도래구분1"
	,case when (TT.시효완성일 is null AND TT.시효기산일 NOT IN ('20080229','20120229','20160229')) then ''
		  when (TT.시효완성일 between '20160501' and '99999999' ) then '16.05월이후시효도래'
		  when (TT.시효완성일 between '20160401' and '20160430' ) then '16.04월시효도래'
		  when (TT.시효완성일 between '20160301' and '20160331' ) then '16.03월시효도래'
		  when (TT.시효완성일 between '20160201' and '20160229' ) then '16.02월시효도래'
		  when (TT.시효완성일 between '00000001' and '20160131' ) then '시효완성추정'
	      else '' end as 시효도래구분
	  ,TT.수임일
	  ,TT.수임액
	  ,TT.기초채권잔액
	  ,TT.기말채권잔액

FROM
(
SELECT distinct
       COMM_FUNC.F_GET_CLNT_NAME(CA02.CLNT_ID) 			    		 AS 위탁사
      ,COMM_FUNC.F_GET_STAF_NAME ('1', CA01.STAF_ID) 				 AS 담당자명
	  ,COMM_FUNC.F_GET_TEAM_NAME('1', CA01.TEAM_CODE)                AS 담당부서 
      ,CA01.CLNT_ID || '-' || CA01.CONT_NO || '-' || CA01.BOND_SEQ   AS 채권번호
      ,CA01.LOAN_NO 												 AS 대출번호
      ,case when ca01.cont_no like '1601%' then 'Y' else 'N' end     AS 당월신규여부
	  ,CA01.RQST_YMD												 AS 수임일
      ,ATAP_AMT_PAMT+ATAP_AMT_INT+ATAP_AMT_EAMT						 as 수임액
      ,ca01.CPLT_LAST_YMD											 as 이수최종일
      ,CA01.DYMD													 AS 응당일
        ,CASE WHEN (NVL(CA01.CPLT_LAST_YMD,0)>= NVL(CA01.LAST_rECV_YMD,0)
  			 AND	NVL(CA01.CPLT_LAST_YMD,0)>=NVL(LAW.DCSN_YMD,0)
  			 AND	NVL(CA01.CPLT_LAST_YMD,0)>=NVL(LAW.LAWS_FIXD_YMD,0))
  		THEN CA01.CPLT_LAST_YMD
        WHEN (NVL(CA01.LAST_rECV_YMD,0)>=NVL(CA01.CPLT_LAST_YMD,0)
        	 AND NVL(CA01.LAST_rECV_YMD,0)>=NVL(LAW.DCSN_YMD,0)
        	 AND NVL(CA01.LAST_rECV_YMD,0)>=NVL(LAW.LAWS_FIXD_YMD,0))
        THEN CA01.LAST_RECV_YMD
        WHEN (NVL(LAW.DCSN_YMD,0)>=NVL(CA01.CPLT_LAST_YMD,0)
       		 AND NVL(LAW.DCSN_YMD,0)>=NVL(CA01.LAST_RECV_YMD,0)
       		 AND NVL(LAW.DCSN_YMD,0)>=NVL(LAW.LAWS_FIXD_YMD,0))
        THEN LAW.DCSN_YMD
        WHEN(NVL(LAW.LAWS_FIXD_YMD,0)>=NVL(CA01.CPLT_LAST_YMD,0)
        	 AND NVL(LAW.LAWS_FIXD_YMD,0)>=NVL(CA01.LAST_RECV_YMD,0)
        	 AND NVL(LAW.LAWS_FIXD_YMD,0)>=NVL(LAW.DCSN_YMD,0))
        THEN LAW.LAWS_FIXD_YMD
        WHEN (CA01.CPLT_LAST_YMD IS NULL AND CA01.LAST_rECV_YMD IS NULL AND LAW.DCSN_YMD IS NULL AND LAW.LAWS_FIXD_YMD IS NULL AND CA01.DYMD IS NOT NULL)
        THEN CA01.DYMD
		ELSE ' '  	END 									AS "시효기산일1"
      ,CASE WHEN (NVL(CA01.CPLT_LAST_YMD,0)>= NVL(CA01.LAST_rECV_YMD,0)
      			 AND	NVL(CA01.CPLT_LAST_YMD,0)>=NVL(LAW.DCSN_YMD,0)
      			 AND	NVL(CA01.CPLT_LAST_YMD,0)>=NVL(LAW.LAWS_FIXD_YMD,0)
      			 AND LENGTH(CA01.CPLT_LAST_YMD)='8'  AND CA01.CPLT_LAST_YMD  NOT IN ('20080229','20120229','20160229'))
      		THEN TO_CHAR((TO_DATE(CA01.CPLT_LAST_YMD, 'YYYYMMDD') + (INTERVAL '5' YEAR)- (INTERVAL '1' DAY) ), 'YYYYMMDD')
            WHEN (NVL(CA01.LAST_rECV_YMD,0)>=NVL(CA01.CPLT_LAST_YMD,0)
            	 AND NVL(CA01.LAST_rECV_YMD,0)>=NVL(LAW.DCSN_YMD,0)
            	 AND NVL(CA01.LAST_rECV_YMD,0)>=NVL(LAW.LAWS_FIXD_YMD,0)
            	 AND LENGTH(CA01.LAST_RECV_YMD)='8' AND CA01.LAST_RECV_YMD  NOT IN ('20080229','20120229','20160229'))
            THEN TO_CHAR((TO_DATE(CA01.LAST_RECV_YMD, 'YYYYMMDD') + (INTERVAL '5' YEAR)- (INTERVAL '1' DAY) ), 'YYYYMMDD')
            WHEN (NVL(LAW.DCSN_YMD,0)>=NVL(CA01.CPLT_LAST_YMD,0)
           		 AND NVL(LAW.DCSN_YMD,0)>=NVL(CA01.LAST_RECV_YMD,0)
           		 AND NVL(LAW.DCSN_YMD,0)>=NVL(LAW.LAWS_FIXD_YMD,0)
           		 AND LENGTH(LAW.DCSN_YMD)='8' AND LAW.DCSN_YMD  NOT IN ('20080229','20120229','20160229'))
            THEN TO_CHAR((TO_DATE(LAW.DCSN_YMD, 'YYYYMMDD') + (INTERVAL '10' YEAR)- (INTERVAL '1' DAY) ), 'YYYYMMDD')
            WHEN (NVL(LAW.LAWS_FIXD_YMD,0)>=NVL(CA01.CPLT_LAST_YMD,0)
            	 AND NVL(LAW.LAWS_FIXD_YMD,0)>=NVL(CA01.LAST_RECV_YMD,0)
            	 AND NVL(LAW.LAWS_FIXD_YMD,0)>=NVL(LAW.DCSN_YMD,0)
            	 AND LENGTH(LAW.LAWS_FIXD_YMD) ='8' AND LAW.LAWS_FIXD_YMD  NOT IN ('20080229','20120229','20160229'))
            THEN TO_CHAR((TO_DATE(LAW.LAWS_FIXD_YMD , 'YYYYMMDD') + (INTERVAL '10' YEAR)- (INTERVAL '1' DAY) ), 'YYYYMMDD')
            ELSE ' ' END 									AS "시효완성일1"
      ,CASE WHEN GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0),NVL(LAW.DCSN_YMD,0),NVL(LAW.LAWS_FIXD_YMD,0))=0
      		THEN ''
      		ELSE GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0),NVL(LAW.DCSN_YMD,0),NVL(LAW.LAWS_FIXD_YMD,0)) END AS 시효기산일
      ,CASE WHEN GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0),NVL(LAW.DCSN_YMD,0),NVL(LAW.LAWS_FIXD_YMD,0)) IN (NVL(LAW.LAWS_FIXD_YMD,0),NVL(LAW.DCSN_YMD,0))
            	 AND LENGTH(GREATEST(NVL(LAW.DCSN_YMD,0),NVL(LAW.LAWS_FIXD_YMD,0))) ='8'
            	 AND GREATEST(NVL(LAW.DCSN_YMD,0),NVL(LAW.LAWS_FIXD_YMD,0))  NOT IN ('20080229','20120229','20160229')
            THEN TO_CHAR((TO_DATE( GREATEST(NVL(LAW.DCSN_YMD,0),NVL(LAW.LAWS_FIXD_YMD,0)) , 'YYYYMMDD') + (INTERVAL '10' YEAR)- (INTERVAL '1' DAY) ), 'YYYYMMDD')
            ELSE CASE WHEN  GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0)) IN (NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0))
                      		AND LENGTH(GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0))) ='8'
                     		AND GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0))  NOT IN ('20080229','20120229','20160229')
                      THEN	TO_CHAR((TO_DATE(GREATEST(NVL(CA01.CPLT_LAST_YMD,0), NVL(CA01.LAST_RECV_YMD,0)), 'YYYYMMDD') + (INTERVAL '5' YEAR)- (INTERVAL '1' DAY) ), 'YYYYMMDD')
                      ELSE '' END
            END 									AS 시효완성일
     , (SELECT ST01.BASE_BOND_RAMT	FROM  M_ST01BASE@ANDDW_LINK  ST01 -- 채권  기본 DW테이블
			    WHERE ST01.STDD_YYMM = '&STDD_YYMM' -- 기준월
			    AND ST01.CLNT_ID   = CA02.CLNT_ID
			   AND ST01.CONT_NO   = CA02.CONT_NO
			   AND ST01.BOND_SEQ  = CA02.BOND_SEQ  )					AS 기초채권잔액
	, (SELECT ST01.CURR_BOND_RAMT	FROM  M_ST01BASE@ANDDW_LINK ST01  -- 채권  기본 DW테이블
			    WHERE ST01.STDD_YYMM = '&STDD_YYMM' -- 기준월
			   AND ST01.CLNT_ID   = CA02.CLNT_ID
			   AND ST01.CONT_NO   = CA02.CONT_NO
			   AND ST01.BOND_SEQ  = CA02.BOND_SEQ  )					AS 기말채권잔액

	,RANK() OVER( PARTITION BY  CA02.CUST_ID, CA02.CLNT_ID ORDER  BY trim(COMM_FUNC.f_get_ppd(CA02.CLNT_ID, CA02.CONT_NO, CA02.BOND_SEQ)) desc, ca02.debt_divi asc, ca01.bond_ramt desc) as "RANK_SEQ2"

FROM
       CA01BOND CA01
     , CA02RELN CA02
,(
	SELECT LO01.CLNT_ID
		,LO01.CONT_NO
		,LO01.BOND_SEQ
        ,lo02.cust_id
        ,LO02.PROP_SEQ
        ,LO02.PROP_TYPE
		,LO03.RQST_NO
		,LO03.LAWS_DIVI
		,LO03.laws_kind
		,LO03.APLY_DIVI
		,LO03.APLY_YMD
		,LO03.APLY_AMT_DMND_AMT
        ,LO03.PROG_STEP
		,LO03.JRDT_CURT
		,LO03.JRDT_SUPT
		,LO03.LAWS_FIXD_YMD
		,LO03.DCSN_YMD
		,LO03.END_DIVI
		,LO03.END_YMD
		,LO03.add_mang_attd_yn

 		,RANK() OVER( PARTITION BY LO01.clnt_id, lo01.cont_no, lo01.bond_seq, LO02.CUST_ID ORDER BY decode(laws_divi, '10', 1, '30', 2, '20', 3, laws_divi)  asc, LO03.rqst_no desc ) as RANK_SEQ



	FROM LO01BOND LO01
	,LO02DEBT LO02
	,LO03LEGL LO03

	WHERE 1=1
	AND LO01.RQST_NO = LO03.RQST_NO
	AND LO01.RQST_NO = LO02.RQST_NO(+)

	AND EXISTS (
		SELECT 1
		FROM CA01BOND
		WHERE 1=1
		AND CLNT_ID = LO01.CLNT_ID
		AND CONT_NO = LO01.CONT_NO
		AND BOND_SEQ = LO01.BOND_SEQ

		AND (TEAM_CODE in ('8010','2032','2033','4060','4020','4045','4050','2060')--팀코드(8010: 전략영업팀), 마케팅지원팀2060도 포함
	 --	AND END_DIVI = '00'--종결구분(00: 진행)
		and clnt_id not in ('001','002','003'))

		AND USE_YN = ' '
	)

	AND LO01.USE_YN = ' '
 	AND LO02.USE_YN(+) = ' '
	AND LO03.USE_YN = ' '


)	LAW
WHERE  1=1


AND CA02.CLNT_ID  = LAW.CLNT_ID(+)
AND CA02.CONT_NO  = LAW.CONT_NO(+)
AND CA02.BOND_SEQ = LAW.BOND_SEQ(+)
AND CA02.CUST_ID  = LAW.CUST_ID(+)


AND CA01.CLNT_ID  = CA02.CLNT_ID
AND CA01.BOND_SEQ = CA02.BOND_SEQ
AND CA01.CONT_NO  = CA02.CONT_NO


AND (CA01.TEAM_CODE in  ('8010', '2032', '2033', '4060', '4020', '4045', '4050','2060')--팀코드(8010: 전략영업팀)
and ca01.clnt_id not in ('001','002','003'))


AND CA01.USE_YN = ' '
AND CA02.USE_YN = ' '

and law.rank_seq(+)='1'
)TT
WHERE 1=1

group by
  	   TT.위탁사
      ,TT.채권번호
	  ,TT.당월신규여부
	  ,TT.대출번호
	  ,TT.이수최종일
	  ,TT.응당일
	  ,TT.시효기산일
      ,TT.시효완성일
      ,TT."시효기산일1"
      ,TT."시효완성일1"
	  ,TT.수임일
	  ,TT.수임액
	  ,TT.기초채권잔액
	  ,TT.기말채권잔액

ORDER BY TT.대출번호 ASC, TT.채권번호 ASC
;


SELECT * FROM IMSI_TB_SHY1
;

SELECT * FROM IMSI_tB_SHY2
;

SELECT ROWNUM
,IMSI.COL1
,IM.COL1
,CASE WHEN IMSI.COL1=IM.COL1
      THEN '' ELSE '1' END  AS 일치여부
,IMSI.COL2
,IM.COL2
,CASE WHEN IMSI.COL2=IM.COL2
      THEN '' ELSE '1' END AS 일칭
FROM (SELECT ROWNUM AS ORD
			,COL1
			,COL2
		FROM IMSI_TB_SHY1) IMSI,
	(SELECT ROWNUM  AS OD
			,COL1
			,COL2
		FROM  IMSI_TB_SHY2) IM
WHERE IMSI.ORD=IM.OD
;
