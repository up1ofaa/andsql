--SELECT
--*
--FROM CM02CODE
--WHERE CODE_ID ='BANK_CODE'
--ORDER BY TO_NUMBER(CODE_VAL)
--
--;

----------------------------------------------------------------------------------------------------------
--ALTER TABLE CA01BOND MODIFY (VTAC_BANK_CODE VARCHAR2(3) );
--COMMENT ON COLUMN CA01BOND.VTAC_BANK_CODE IS
--'가상계좌은행코드![CODE_ID:BANK_CODE CODE_DESC:은행코드]';
--
--ALTER TABLE CA01BOND MODIFY (VTAC2_BANK_CODE VARCHAR2(3) );
--COMMENT ON COLUMN CA01BOND.VTAC2_BANK_CODE IS
--'가상계좌2은행코드![CODE_ID:BANK_CODE CODE_DESC:은행코드]';
--;

--
desc ca01bond ;
--
--
--select
--*
--from cm02code
--where code_id='NEW_BANK_CODE'
--;
--
--select
--*
--from cm02code
--where code_id='BANK_CODE'
;

/*되돌리기*/


--ALTER TABLE CA01BOND MODIFY (VTAC_BANK_CODE VARCHAR2(2) );
--COMMENT ON COLUMN CA01BOND.VTAC_BANK_CODE IS
--'가상계좌은행코드![CODE_ID:BANK_CODE CODE_DESC:은행코드]';
--
--ALTER TABLE CA01BOND MODIFY (VTAC2_BANK_CODE VARCHAR2(2) );
--COMMENT ON COLUMN CA01BOND.VTAC2_BANK_CODE IS
--'가상계좌2은행코드![CODE_ID:BANK_CODE CODE_DESC:은행코드]';
--;
--

--select
--*
--from ca01bond
--where clnt_id='099'      --vtac_bank_code  : 247
--and cust_id='18612150022'  

--select
--*
--from cm02code
--where code_id='VOC_CAUS_BOND'
--;
---- A&D => 당사 로 변경
----
--select
--*
--from cm02code
--where code_id='VOC_ACPT_ORGN'
--;
--소보원 삭제 'D'


/*칼럼 추가*/

--ALTER TABLE VC01VOCA ADD ( VOC_OBJT VARCHAR2(3) );
--COMMENT ON COLUMN VC01VOCA.VOC_OBJT IS '민원대상';
--ALTER TABLE VC01VOCA ADD ( WDRA_YN VARCHAR2(1) DEFAULT 'N' NOT NULL);
--COMMENT ON COLUMN VC01VOCA.WDRA_YN IS '취하여부';
--ALTER TABLE VC01VOCA ADD (CLNT_VLUT_YN VARCHAR2(1) DEFAULT 'Y' NOT NULL);
--COMMENT ON COLUMN VC01VOCA.CLNT_VLUT_YN IS '위탁사평가여부';
DESC VC01VOCA;

SELECT
*
FROM CM02CODE
WHERE CODE_ID='VOC_OBJT'
;

SELECT
*
FROM CM02CODE
WHERE CODE_ID='VOC_ACPT_ORGN'
;


