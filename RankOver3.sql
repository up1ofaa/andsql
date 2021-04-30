(SELECT NVL(EASY_EYE, ' ')
  FROM     M_ST01BASE@ANDDW_LINK A
  WHERE    A.STDD_YYMM = '&STDD_YYMM'
  AND CLNT_ID=CA01.CLNT_ID
  AND CONT_NO=CA01.CONT_NO
  AND BOND_SEQ=CA01.BOND_SEQ ) ;


  SELECT
   CASE WHEN (A.VILI_GRDE BETWEEN 'A' AND 'E') AND A.CTAR_ADMN_DIVI IN ('가족','본인')         THEN 'A'
       	WHEN (A.VILI_GRDE BETWEEN 'A' AND 'E') AND A.CTAR_ADMN_DIVI IN ('확인대상','연락처무') THEN 'B'
        WHEN (A.VILI_GRDE BETWEEN 'F' AND 'I') AND A.CTAR_ADMN_DIVI IN ('가족','본인')         THEN 'C'
        WHEN (A.VILI_GRDE BETWEEN 'F' AND 'I') AND A.CTAR_ADMN_DIVI IN ('확인대상','연락처무') THEN 'D'
        WHEN (A.VILI_GRDE > 'I')               AND A.CTAR_ADMN_DIVI IN ('가족','본인')         THEN 'E'
        WHEN (A.VILI_GRDE > 'I')               AND A.CTAR_ADMN_DIVI IN ('확인대상','연락처무') THEN 'F'
   ELSE 'Z' END
  FROM    M_ST01BASE@ANDDW_LINK A
  WHERE    A.STDD_YYMM = '&STDD_YYMM'
   AND    A.CUST_ID   = '17907230047'
   AND    A.CLNT_ID   = '108'
   AND    ROWNUM      = 1
   ;

   SELECT
   CUST_ID
   , VILI_GRDE
   FROM CA01BOND
   WHERE
   CLNT_ID||'-'||CONT_NO||'-'||BOND_SEQ='108-15064-1'  ; --17907230047

   SELECT   CLNT_ID||'-'||CONT_NO||'-'||BOND_SEQ
   ,VILI_GRDE
   FROM CA01BOND
   WHERE
   VILI_GRDE IS NOT NULL
   AND ROWNUM<2;


