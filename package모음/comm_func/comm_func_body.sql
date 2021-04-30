CREATE OR REPLACE PACKAGE BODY OPARSE.Comm_Func
--------------------------------------------------------------------------------
-- package 기능 : 자주 쓰이는 공통적인 함수를 모아둠
-- 작성일자     : 2006/06/20
-- 작성자       : 전산팀
--------------------------------------------------------------------------------
-- 수정일자     : 2007/11/15
-- 수정자       : 손현정
-- 수정내용     : 시스템 신용 여부 조회 function 수정 (대한 item_code 변경. 4번째 0추가)
--------------------------------------------------------------------------------
/*******************************************************************
<<변수 이름규칙>>
- 데이타타입+사용변수명
 (데이타타입: c - char, n - number, d - date, r - record, t - table,
              b - boolean, e - exception)
/*******************************************************************
<<함수의 순수레벨>>
PRAGMA RESTRICT_REFERENCES (FUNCTION_NAME,
                            WNDS, -> 테이블 수정불가(필수레벨)
                            WNPS, -> 패키지변수 수정불가
                            RNPS, -> 공용 패키지변수 참조불가
                            RNDS  -> 테이블 질의불가
                           );
*******************************************************************/
IS
--------------------------------------------------------------------
-- 코드아이디, 코드값으로 코드명 조회
--------------------------------------------------------------------
    FUNCTION f_get_code_name (
        p_code_id                 IN     CM02CODE.code_id%TYPE,
        p_code_val                IN     CM02CODE.code_val%TYPE
    ) RETURN CM02CODE.code_name%TYPE
    IS
        c_code_name  CM02CODE.code_name%TYPE;

    BEGIN
	    c_code_name  := ' ';

         IF p_code_id = 'DH_INTF_MSG' THEN

             SELECT code_name
              INTO c_code_name
              FROM CM02CODE
		     WHERE code_id  = p_code_id
		       AND TO_NUMBER(code_val) = p_code_val
               AND ROWNUM = 1;

        ELSE
            SELECT code_name
              INTO c_code_name
              FROM CM02CODE
		     WHERE code_id  = p_code_id
		       AND code_val = p_code_val  ;
        END IF;


        RETURN c_code_name;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_code_name;


--------------------------------------------------------------------
-- 코드아이디, 코드값으로 코드명 조회
--------------------------------------------------------------------
    FUNCTION f_get_crp_code_name (
        p_code_id                 IN     CM02CODE.code_id%TYPE,
        p_code_val                IN     CM02CODE.code_val%TYPE
    ) RETURN CM02CODE.code_name%TYPE
    IS
        c_code_name  CM02CODE.code_name%TYPE;
		c_code_id    CM02CODE.code_id%TYPE;

    BEGIN
	    c_code_name  := ' ';

		    if p_code_id = '03' or p_code_id = '04' or p_code_id = '05' or p_code_id = '06' then
			   c_code_id := '12';
			else
			   c_code_id := p_code_id;
			end if ;

            SELECT code_name
              INTO c_code_name
              FROM CM02CODE
		     WHERE code_id  = c_code_id
		       AND code_val = p_code_val  ;



        RETURN c_code_name;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_crp_code_name;


--------------------------------------------------------------------
-- 코드아이디, 코드명 으로 코드값 조회
--------------------------------------------------------------------
    FUNCTION f_get_code_val (
        p_code_id                 IN     CM02CODE.code_id%TYPE,
        p_code_name               IN     CM02CODE.code_name%TYPE
    ) RETURN CM02CODE.code_val%TYPE
    IS
        c_code_val  CM02CODE.code_val%TYPE;

    BEGIN
	    c_code_val  := ' ';

        SELECT code_val
          INTO c_code_val
          FROM CM02CODE
		 WHERE code_id   = p_code_id
		   AND code_name = p_code_name  ;

        RETURN c_code_val;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_code_val;




--------------------------------------------------------------------
-- 팀/부서명 가져오기
-- 구분값 1: 팀코드 2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식), 4.사번
--------------------------------------------------------------------
    FUNCTION f_get_team_name (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CM03ORGN.team_name%TYPE
    IS
        c_name  CM03ORGN.team_name%TYPE;

    BEGIN
	    c_name  := ' ';

        SELECT team_name
		  INTO c_name
		  FROM (
		        SELECT team_name
				  FROM CM03ORGN
				 WHERE p_divi  = '1'
		           AND p_key   = team_code
				UNION ALL
                SELECT a.team_name
                  FROM CM03ORGN a,
		               CA01BOND b
		         WHERE p_divi      = '2'
		           AND a.team_code = b.team_code
		           AND b.clnt_id   = SUBSTR(p_key,1 , 3)
		           AND b.cont_no   = SUBSTR(p_key,5 , 5)
		           AND b.bond_seq  = SUBSTR(p_key,11   )
		         UNION ALL
                SELECT a.team_name
                  FROM CM03ORGN a,
		               CA01BOND b
		         WHERE p_divi       = '3'
		           AND a.team_code  = b.team_code
		           AND b.clnt_id    = SUBSTR(p_key,1, 3)
		           AND b.cont_no    = SUBSTR(p_key,4, 5)
		           AND b.bond_seq   = SUBSTR(p_key,9   )
				UNION ALL
				SELECT a.team_name
                  FROM CM03ORGN a,
				       CM03STAF b
		         WHERE p_divi       = '4'
		           AND a.team_code  = b.team_code
		           AND p_key        = b.staf_id
			   )
		;

        RETURN c_name;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_team_name  ;




--------------------------------------------------------------------
-- 팀코드 가져오기
-- 사번으로 조회
--------------------------------------------------------------------
    FUNCTION f_get_team_code (
        p_staf_id                    IN     VARCHAR2
    ) RETURN CM03ORGN.team_code%TYPE
    IS
        c_code  CM03ORGN.team_code%TYPE;

    BEGIN
	    c_code  := ' ';

        SELECT team_code
		  INTO c_code
		  FROM CM03STAF
		 WHERE staf_id  = p_staf_id ;

        RETURN c_code;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_team_code  ;

--------------------------------------------------------------------
-- 사원명 가져오기
-- 구분값 1: 사번 2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--------------------------------------------------------------------
    FUNCTION f_get_staf_name (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CM03STAF.staf_name%TYPE
    IS
        c_name  CM03STAF.staf_name%TYPE;

    BEGIN
	    c_name  := ' ';

        SELECT staf_name
		  INTO c_name
		  FROM (
		        SELECT staf_name
                  FROM CM03STAF
		         WHERE p_divi  = '1'
		           AND p_key   = staf_id
		         UNION ALL
                SELECT staf_name
                  FROM CM03STAF a,
		               CA01BOND b
		         WHERE p_divi     = '2'
		           AND a.staf_id  = b.staf_id
		           AND b.clnt_id  = SUBSTR(p_key,1 , 3)
		           AND b.cont_no  = SUBSTR(p_key,5 , 5)
		           AND b.bond_seq = SUBSTR(p_key,11   )
		         UNION ALL
                SELECT staf_name
                  FROM CM03STAF a,
		               CA01BOND b
		         WHERE p_divi     = '3'
		           AND a.staf_id  = b.staf_id
		           AND b.clnt_id  = SUBSTR(p_key,1, 3)
		           AND b.cont_no  = SUBSTR(p_key,4, 5)
		           AND b.bond_seq = SUBSTR(p_key,9   )
			   )
		;

        RETURN c_name;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_staf_name ;



--------------------------------------------------------------------
-- 사번으로 사원전화번호 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_staf_tel (
        p_staf_id                 IN     CM03STAF.staf_id%TYPE
    ) RETURN CM03STAF.wkpl_tel%TYPE
    IS
        c_wkpl_tel  CM03STAF.wkpl_tel%TYPE ;

    BEGIN
	    c_wkpl_tel  := ' ';

        SELECT wkpl_tel AS wkpl_tel
		  INTO c_wkpl_tel
		  FROM CM03STAF
		 WHERE staf_id   = p_staf_id  ;

        RETURN c_wkpl_tel;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_staf_tel ;


--------------------------------------------------------------------
-- 사번으로 사원팩스번호 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_staf_fax (
        p_staf_id                 IN     CM03STAF.staf_id%TYPE
    ) RETURN CM03STAF.fax_no%TYPE
    IS
        c_fax_no  CM03STAF.fax_no%TYPE ;

    BEGIN
	    c_fax_no  := ' ';

        SELECT fax_no
		  INTO c_fax_no
		  FROM CM03STAF
		 WHERE staf_id   = p_staf_id  ;

        RETURN c_fax_no;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_staf_fax ;


--------------------------------------------------------------------
-- 주민번호가져오기
-- 구분값  1. 고객아이디, 2.채권번호, 3.대출번호
--------------------------------------------------------------------
    FUNCTION f_get_cust_ssno (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CA04CUST.cust_ssno%TYPE
    IS
        c_cust_ssno  CA04CUST.cust_ssno%TYPE;

    BEGIN
	    c_cust_ssno  := ' ';

        SELECT xx1.dec_varchar2_sel(cust_ssno,10,'SSN')         AS cust_ssno
        --SELECT  cust_ssno         AS cust_ssno
		  INTO c_cust_ssno
		  FROM (
		        SELECT cust_ssno
                  FROM CA04CUST
		         WHERE p_divi  = '1'
		           AND p_key   = cust_id
		         UNION ALL
                SELECT a.cust_ssno
                  FROM CA04CUST a,
		               CA01BOND b
		         WHERE p_divi     = '2'
		           AND a.cust_id  = b.cust_id
		           AND b.clnt_id  = SUBSTR(p_key,1 , 3)
		           AND b.cont_no  = SUBSTR(p_key,5 , 5)
		           AND b.bond_seq = SUBSTR(p_key,11   )
		         UNION ALL
                SELECT a.cust_ssno
                  FROM CA04CUST a,
		               CA01BOND b
		         WHERE p_divi     = '3'
		           AND a.cust_id  = b.cust_id
		           AND b.clnt_id  = SUBSTR(p_key,1, 3)
		           AND b.cont_no  = SUBSTR(p_key,4, 5)
		           AND b.bond_seq = SUBSTR(p_key,9   )
		         UNION ALL
                SELECT a.cust_ssno
                  FROM CA04CUST a,
		               CA01BOND b
		         WHERE p_divi     = '4'
		           AND a.cust_id  = b.cust_id
		           AND b.loan_no  = p_key
				   AND b.rqst_ymd = (SELECT MAX(rqst_ymd)
				                       FROM CA01BOND
									  WHERE b.loan_no = loan_no )
				  AND ROWNUM = 1
			   )
		;



        RETURN c_cust_ssno ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_cust_ssno  ;


--------------------------------------------------------------------
-- 고객명(채무자명) 가져오기
-- 구분값  1. 고객아이디, 위탁사아이디  2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--         4. 대출번호
--------------------------------------------------------------------
    FUNCTION f_get_cust_name (
        p_divi                    IN     VARCHAR2,
        p_key1                    IN     VARCHAR2,
        p_key2                    IN     VARCHAR2
    ) RETURN CA02RELN.cust_name%TYPE
    IS
        c_cust_name  CA02RELN.cust_name%TYPE;

    BEGIN
	    c_cust_name  := ' ';

        SELECT cust_name
		  INTO c_cust_name
		  FROM (
		        SELECT cust_name
                  FROM CA02RELN
		         WHERE p_divi   = '1'
		           AND p_key1   = cust_id
		           AND p_key2   = clnt_id
				   AND ROWNUM   = 1

		         UNION ALL

                SELECT cust_name
                  FROM CA01BOND
		         WHERE p_divi     = '2'
		           AND clnt_id  = SUBSTR(p_key1, 1 , 3)
		           AND cont_no  = SUBSTR(p_key1, 5 , 5)
		           AND bond_seq = SUBSTR(p_key1, 11   )

		         UNION ALL

                SELECT cust_name
                  FROM CA01BOND
		         WHERE p_divi     = '3'
		           AND clnt_id  = SUBSTR(p_key1, 1, 3)
		           AND cont_no  = SUBSTR(p_key1, 4, 5)
		           AND bond_seq = SUBSTR(p_key1, 9   )

		         UNION ALL

                SELECT a.cust_name
                  FROM CA01BOND a
		         WHERE p_divi     = '4'
		           AND loan_no  = p_key1
				   AND a.rqst_ymd = (SELECT MAX(rqst_ymd)
				                       FROM CA01BOND
							  		  WHERE a.loan_no = loan_no )
			   )
		;

        RETURN c_cust_name ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_cust_name  ;





--------------------------------------------------------------------
-- 고객아이디 가져오기
-- 구분값  1. 주민번호, 2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--         4. 대출번호
--------------------------------------------------------------------
    FUNCTION f_get_cust_id (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CA04CUST.cust_id%TYPE

	IS
        c_cust_id  CA04CUST.cust_id%TYPE ;

    BEGIN
	    c_cust_id  := ' ';

        SELECT cust_id
		  INTO c_cust_id
		  FROM (
		        SELECT cust_id
   		          FROM CA04CUST
		         WHERE p_divi     = '1'
		           AND cust_ssno  = xx1.enc_varchar2_ins(p_key, 10, 'SSN')
				   AND ROWNUM     = 1

		         UNION ALL

                SELECT cust_id
                  FROM CA01BOND
		         WHERE p_divi     = '2'
		           AND clnt_id  = SUBSTR(p_key, 1 , 3)
		           AND cont_no  = SUBSTR(p_key, 5 , 5)
		           AND bond_seq = SUBSTR(p_key, 11   )

		         UNION ALL

                SELECT cust_id
                  FROM CA01BOND
		         WHERE p_divi     = '3'
		           AND clnt_id  = SUBSTR(p_key, 1, 3)
		           AND cont_no  = SUBSTR(p_key, 4, 5)
		           AND bond_seq = SUBSTR(p_key, 9   )

		         UNION ALL

                SELECT a.cust_id
                  FROM CA01BOND a
		         WHERE p_divi     = '4'
		           AND loan_no  = p_key
				   AND ROWNUM	= 1
				   AND a.rqst_ymd = (SELECT MAX(rqst_ymd)
				                       FROM CA01BOND
							  		  WHERE a.loan_no = loan_no )
			   )
		;

        RETURN c_cust_id ;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_cust_id  ;


--------------------------------------------------------------------
-- 현재PPD조회
--
--------------------------------------------------------------------
    FUNCTION f_get_ppd (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE,
        p_cont_no                 IN     CA01BOND.cont_no%TYPE,
        p_bond_seq                IN     CA01BOND.bond_seq %TYPE
    ) RETURN NUMBER
    IS
        n_ppd              NUMBER     ;
        c_bond_type        VARCHAR2(2);
        c_dymd             VARCHAR2(8);
        c_ovrd_occr_ymd    VARCHAR2(8);
        c_cplt_last_ymd    VARCHAR2(8);
        c_bdbt_dymd        VARCHAR2(8);
        c_bdbt_ymd         VARCHAR2(8);
        c_bdbt_ppd         NUMBER;
        c_last_expr_ymd    VARCHAR2(8);

    BEGIN
        n_ppd  := 0 ;

        SELECT   NVL(bond_type     , ' ')
               , NVL(dymd          , ' ')
               , NVL(nvl(ovrd_occr_ymd_befr,ovrd_occr_ymd) , ' ')
               , NVL(cplt_last_ymd , ' ')
               , NVL(bdbt_dymd     , ' ')
               , NVL(bdbt_ymd      , ' ')
               , NVL(bdbt_ppd      , 0)
               , NVL(last_expr_ymd      , ' ')
          INTO   c_bond_type
               , c_dymd
               , c_ovrd_occr_ymd
               , c_cplt_last_ymd
               , c_bdbt_dymd
               , c_bdbt_ymd
               , c_bdbt_ppd
               , c_last_expr_ymd
          FROM CA01BOND
         WHERE clnt_id  = p_clnt_id
           AND cont_no  = p_cont_no
           AND bond_seq = p_bond_seq  ;

       --- DBMS_OUTPUT.PUT_LINE('채권번호 : '||p_clnt_id||'-'||p_cont_no||'-'||p_bond_seq);

        -- 일반채권, 삼성, 대한, 흥국, 동부
        IF ( c_bond_type     = '10'         AND
             LENGTH(c_dymd)  = 8            AND
             c_dymd          != '00010101'  AND
             p_clnt_id       IN ('001','003','004','050','090','094' , '097')   ) THEN
            IF p_clnt_id IN ('001','004','050','090','094' , '097') THEN --삼성,흥국,동부,한화손보,한국산업은행, 흥국화재 는 응당일 기준
                n_ppd := 1+CEIL(MONTHS_BETWEEN(TO_DATE(SUBSTR(TO_CHAR(SYSDATE,'yyyymmss'),1,6),'yyyymm'),
                                               TO_DATE(SUBSTR(c_dymd,1,6),'yyyymm'))) ;

            ELSIF  p_clnt_id = '003' THEN --대생
                IF (c_cplt_last_ymd IS NOT NULL AND c_last_expr_ymd < c_cplt_last_ymd) THEN
                    n_ppd := 1+MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'yyyymm')||'01','YYYYMMDD'),
                                              TO_DATE(SUBSTR(NVL(c_last_expr_ymd,TO_CHAR(SYSDATE,'yyyymm')+1||'01'),1,6)||'01','YYYYMMDD'));

                ELSIF (c_cplt_last_ymd IS NULL OR c_dymd>=c_cplt_last_ymd) THEN
                    n_ppd := 1+MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'yyyymm')||'01','YYYYMMDD'),
                                              TO_DATE(SUBSTR(NVL(c_dymd,TO_CHAR(SYSDATE,'yyyymm')+1||'01'),1,6)||'01','YYYYMMDD'));


                ELSIF (c_cplt_last_ymd IS NOT NULL AND c_dymd < c_cplt_last_ymd) THEN
                    n_ppd := 1+MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'yyyymm')||'01','YYYYMMDD'),
                                              TO_DATE(SUBSTR(NVL(c_cplt_last_ymd,TO_CHAR(SYSDATE,'yyyymm')+1||'01'),1,6)||'01','YYYYMMDD'));

                END IF;
            END IF;

            IF (n_ppd < 0) THEN
                n_ppd  := '0';
            END IF;

        -- 교보(연체발생일 있는 경우)
        ELSIF p_clnt_id = '002' AND LENGTH(c_ovrd_occr_ymd) = 8 AND c_ovrd_occr_ymd != '00010101' THEN
           n_ppd := 1+CEIL(MONTHS_BETWEEN(TO_DATE(SUBSTR(TO_CHAR(SYSDATE,'yyyymmss'),1,6),'yyyymm'), TO_DATE(SUBSTR(c_ovrd_occr_ymd,1,6),'yyyymm')));


        --교보(연체발생일 없는 경우 ==> 응당일 사용)
        ELSIF p_clnt_id = '002' AND LENGTH(c_dymd) = 8 AND c_dymd != '00010101' THEN
           n_ppd := 1+CEIL(MONTHS_BETWEEN(TO_DATE(SUBSTR(TO_CHAR(SYSDATE,'yyyymmss'),1,6),'yyyymm'), TO_DATE(SUBSTR(c_dymd,1,6),'yyyymm')));


        --CJ개발(응당일 없는 경우 ==> 이수최종일 사용) 20071026 손현정추가
        ELSIF (p_clnt_id = '037' OR p_clnt_id = '038' OR p_clnt_id = '039') AND LENGTH(c_cplt_last_ymd) = 8 AND c_cplt_last_ymd != '00010101' THEN
           n_ppd := 1+CEIL(MONTHS_BETWEEN(TO_DATE(SUBSTR(TO_CHAR(SYSDATE,'yyyymmss'),1,6),'yyyymm'), TO_DATE(SUBSTR(c_cplt_last_ymd,1,6),'yyyymm')));


        -- 특수채권
        ELSIF ( (c_bond_type = '20' OR c_bond_type = '30')  AND c_bdbt_dymd != '00010101') THEN   --특수
            IF p_clnt_id = '003' THEN --대생
                IF LENGTH(c_bdbt_dymd) = 8 THEN
                    n_ppd := 1+MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'yyyymm')||'01','YYYYMMDD'),
                                              TO_DATE(SUBSTR(c_bdbt_dymd,1,6)||'01','YYYYMMDD'));

                ELSIF LENGTH(c_bdbt_ymd) = 8 THEN
                    n_ppd := 1+MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE,'yyyymm')||'01','YYYYMMDD'),
                                              TO_DATE(SUBSTR(c_bdbt_ymd,1,6)||'01','YYYYMMDD'));
                END IF;

            ELSE
                n_ppd  := 0;

            END IF;

        ELSIF (p_clnt_id = '060') THEN
            n_ppd := c_bdbt_ppd;

        --기타건
        ELSE
            n_ppd  := 0;

        END IF;



        IF n_ppd > 999
            THEN n_ppd := 999 ;
        ELSIF n_ppd < -999
            THEN n_ppd := -999 ;
        END IF ;



        RETURN n_ppd  ;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 999 ;

        WHEN OTHERS THEN RETURN 999;
    END  f_get_ppd;




--------------------------------------------------------------------
-- 현재PPD조회
-- 대출번호로 ppd 조회
--------------------------------------------------------------------
    FUNCTION f_get_ppd_loan_no (
        p_loan_no                 IN     CA01BOND.loan_no%TYPE
    ) RETURN NUMBER
    IS
        n_ppd            NUMBER     ;
	    c_clnt_id        CA01BOND.clnt_id%TYPE;
	    c_cont_no        CA01BOND.cont_no%TYPE;
	    c_bond_seq       CA01BOND.bond_seq%TYPE;

    BEGIN
	    n_ppd  := 0 ;

        -- 채권번호 조회
		SELECT   clnt_id
               , cont_no
               , bond_seq
          INTO   c_clnt_id
               , c_cont_no
               , c_bond_seq
          FROM CA01BOND
         WHERE loan_no  = p_loan_no
		   AND end_divi = '00'
		   AND use_yn   = ' '
		   AND ROWNUM   = 1  ;



		-- 조회한 채권번호로 ppd조회
		SELECT f_get_ppd(c_clnt_id, c_cont_no, c_bond_seq)
		  INTO n_ppd
		  FROM dual ;

        RETURN n_ppd ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN 999 ;

        WHEN OTHERS THEN RETURN 999;
    END  f_get_ppd_loan_no;

--------------------------------------------------------------------
-- 위탁사명 조회
-- input : 위탁사아이디
--------------------------------------------------------------------
    FUNCTION f_get_clnt_name (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
    ) RETURN CA04CLNT.clnt_name%TYPE

	IS
        c_clnt_name  CA04CLNT.clnt_name%TYPE ;

    BEGIN

	    c_clnt_name  := ' ';

        SELECT clnt_name
		  INTO c_clnt_name
		  FROM CA04CLNT
		 WHERE clnt_id = p_clnt_id
		   AND ROWNUM = '1' ;

        RETURN c_clnt_name ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_clnt_name  ;

--------------------------------------------------------------------------------
--- 우편번호로 우편주소 가져오기
--------------------------------------------------------------------------------
    FUNCTION find_zip_addr(
        p_zip_no         IN      VARCHAR2
    ) RETURN VARCHAR2
    IS
        n_cnt          NUMBER;
        c_code_addr    VARCHAR2(200);

    BEGIN
        SELECT COUNT(*)
          INTO n_cnt
          FROM CM01ZIPC
         WHERE zip_no = p_zip_no
		   AND use_yn = ' ';

        IF n_cnt = 0 THEN
            RETURN ' ';
        ELSE
            SELECT  city_gun||' '||gu||' '||twmd || ' ' || larg_dlvr_plac
            INTO    c_code_addr
            FROM    CM01ZIPC
            WHERE   zip_no = p_zip_no
			  AND   use_yn = ' '
			  AND 	ROWNUM 	 = 1;

            RETURN  c_code_addr;
        END IF;
    END find_zip_addr;


--------------------------------------------------------------------
-- 채권번호로 대출번호 조회
--------------------------------------------------------------------
    FUNCTION f_get_loan_no (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
    ) RETURN CA01BOND.loan_no%TYPE

	IS
        c_loan_no  CA01BOND.loan_no%TYPE ;

    BEGIN

	    c_loan_no  := ' ';

        SELECT  loan_no
		  INTO  c_loan_no
		  FROM  CA01BOND
		 WHERE  clnt_id = p_clnt_id
		   AND  cont_no	= p_cont_no
		   AND  bond_seq= p_bond_seq;

        RETURN c_loan_no ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_loan_no  ;



--------------------------------------------------------------------
-- 대출번호로  채권번호 조회
--------------------------------------------------------------------
    FUNCTION f_get_bond_no (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_loan_no                 IN     CA01BOND.loan_no%TYPE
    ) RETURN  VARCHAR2

	IS
        c_bond_no  VARCHAR2(20) ;

    BEGIN

	    c_bond_no  := ' ';

        SELECT clnt_id||'-'||cont_no||'-'||bond_seq
        INTO  c_bond_no
        FROM ca01bond
        WHERE clnt_id = p_clnt_id
        AND loan_no = p_loan_no
        AND cont_no||lpad(bond_seq,6,'0') =  (select MAX(cont_no||lpad(bond_seq,6,'0'))
                                                         from ca01bond
                                                         where clnt_id = p_clnt_id
                                                         and loan_no = p_loan_no
                                                         and use_yn = ' '
                                                         );

        RETURN c_bond_no ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_bond_no  ;





--------------------------------------------------------------------
-- 채권번호로 가상계좌 번호 조회
--------------------------------------------------------------------
    FUNCTION f_get_virt_bank (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
    ) RETURN VARCHAR2

	IS
        c_virt_bank  VARCHAR(60) ;

    BEGIN

	    c_virt_bank  := ' ';

        SELECT  f_get_code_name('BANK_CODE', VTAC_BANK_CODE) || '/' || VTAC_NO
		  INTO  c_virt_bank
		  FROM  CA01BOND
		 WHERE  clnt_id = p_clnt_id
		   AND  cont_no	= p_cont_no
		   AND  bond_seq= p_bond_seq;

        RETURN c_virt_bank ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_virt_bank   ;




--------------------------------------------------------------------
-- 전화번호 포멧지정
--------------------------------------------------------------------
    FUNCTION f_tel_no_format (
        p_tel_no                  IN     VARCHAR2
    ) RETURN VARCHAR2

	IS
        c_tel_no  VARCHAR(60) ;
        i_tel_no  VARCHAR(60) ;

         n_len     	NUMBER  :=  LENGTH(p_tel_no);	 --src의 length
	     n_curr_len	NUMBER  :=  1;	 			 --src의 length

    BEGIN

	    c_tel_no  := ' ';


	    WHILE  n_curr_len <= n_len  LOOP
	        IF SUBSTR(p_tel_no,n_curr_len,1) BETWEEN '0' AND '9' THEN
		        i_tel_no :=  i_tel_no || SUBSTR(p_tel_no,n_curr_len,1);
		    END IF ;

		    n_curr_len := n_curr_len + 1;

		END LOOP;


				SELECT   DECODE(SUBSTR(i_tel_no ,1,2),'02',DECODE(LENGTHB(i_tel_no ), 9,SUBSTR(i_tel_no ,1,2)||'-'||SUBSTR(i_tel_no ,3,3)||'-'||SUBSTR(i_tel_no ,6),  SUBSTR(i_tel_no ,1,2)||'-'||SUBSTR(i_tel_no ,3,4)||'-'||SUBSTR(i_tel_no ,7))
                              ,DECODE(LENGTHB(i_tel_no ),10,SUBSTR(i_tel_no ,1,3)||'-'||SUBSTR(i_tel_no ,4,3)||'-'||SUBSTR(i_tel_no ,7),  SUBSTR(i_tel_no ,1,3)||'-'||SUBSTR(i_tel_no ,4,4)||'-'||SUBSTR(i_tel_no ,8)))
				  INTO c_tel_no
				  FROM dual;

		IF c_tel_no = '--' THEN
		    c_tel_no := ' ' ;
		END IF ;

        RETURN c_tel_no ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_tel_no_format   ;

--------------------------------------------------------------------
-- 채권번호 및 고객 아이디로 채무구분 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_debt_divi (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
       ,p_cust_id                 IN     CA02RELN.cust_id%TYPE
    ) RETURN VARCHAR2

    IS
       c_debt_divi  VARCHAR(10);

    BEGIN

        SELECT Comm_Func.f_get_code_name('DEBT_DIVI',debt_divi)
          INTO c_debt_divi
          FROM CA02RELN
         WHERE clnt_id  = p_clnt_id
           AND cont_no  = p_cont_no
           AND bond_seq = p_bond_seq
           AND cust_id  = p_cust_id
           AND use_yn   = ' '
         ;

         RETURN c_debt_divi;

          EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_debt_divi   ;

--------------------------------------------------------------------
-- 담당자 지정여부 check
--------------------------------------------------------------------
    FUNCTION check_staf_allo(
        p_clnt_id               IN      VARCHAR2,
        p_cont_no             IN      VARCHAR2,
        p_bond_seq             	IN      VARCHAR2
    ) RETURN VARCHAR2
    IS
        n_cnt    NUMBER;
		result   VARCHAR2(22) := ' ' ;
    BEGIN
        SELECT  COUNT(*)
        INTO    n_cnt
        FROM    CA01BOND A, CM03STAF B
        WHERE   A.staf_id = B.staf_id
		  AND   clnt_id   = p_clnt_id
          AND   cont_no = p_cont_no
          AND   bond_seq  = p_bond_seq
	--	  and  	A.DEPT_CODE is not null
		  AND 	A.TEAM_CODE IS NOT NULL;

        IF  n_cnt = 0 THEN
            result := 'e';
        END IF;

        RETURN result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'e';
        WHEN OTHERS THEN
            RETURN 'e';

    END check_staf_allo;


--------------------------------------------------------------------
-- 채권번호로 우편물 발송건수 가져오기 (20061120.hjson)
--------------------------------------------------------------------
    FUNCTION f_get_mail_cnt (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
       ,p_cust_id                 IN     CA01BOND.cust_id%TYPE
    ) RETURN NUMBER

	IS
        c_mail_cnt  NUMBER ;

    BEGIN

	    c_mail_cnt  := 0;

        SELECT  COUNT(mail_admn_no)
		  INTO  c_mail_cnt
		  FROM  CA08MAIL
		 WHERE  clnt_id = p_clnt_id
		   AND  cont_no	= p_cont_no
		   AND  bond_seq= p_bond_seq
		   AND  cust_id = p_cust_id
		   AND  curr_step = '04'
		   AND  cncl_yn = 'N'
		   AND  use_yn = ' ';

        RETURN c_mail_cnt ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN 999 ;
        WHEN OTHERS THEN RETURN 999;
    END f_get_mail_cnt   ;


--------------------------------------------------------------------
-- 당일이전 영업일 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_befo_wotk_date (
        p_stdd_ymd            IN      VARCHAR2,
        p_day             	  IN      NUMBER
    ) RETURN VARCHAR2
    IS
		s_result   VARCHAR2(8);
    BEGIN
		SELECT stdd_ymd
		  INTO s_result
		FROM (
				SELECT /*+INDEX_DESC(CM09CALD PK_CM09CALD)*/ stdd_ymd
					   , ROWNUM rnum
				FROM CM09CALD
				WHERE hday_yn = 'N'
				AND   stdd_ymd < p_stdd_ymd
				AND   wkct NOT IN ('1', '7')
			)
		WHERE rnum = p_day;

        RETURN s_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN p_stdd_ymd;
        WHEN OTHERS THEN
            RETURN p_stdd_ymd;

    END f_get_befo_wotk_date;


--------------------------------------------------------------------
-- 당일이후 영업일 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_futr_wotk_date (
        p_stdd_ymd            IN      VARCHAR2,
        p_day             	  IN      NUMBER
    ) RETURN VARCHAR2
    IS
		s_result   VARCHAR2(8);
    BEGIN

		SELECT stdd_ymd
		  INTO s_result
		FROM (
				SELECT /*+INDEX_ASC(CM09CALD PK_CM09CALD)*/ stdd_ymd
					   , ROWNUM rnum
				FROM CM09CALD
				WHERE hday_yn = 'N'
				AND   stdd_ymd > p_stdd_ymd
				AND   wkct NOT IN ('1', '7')
			)
		WHERE rnum = p_day;

        RETURN s_result;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN p_stdd_ymd;
        WHEN OTHERS THEN
            RETURN p_stdd_ymd;

    END f_get_futr_wotk_date;






--------------------------------------------------------------------
-- 시스템 대출 확인
--------------------------------------------------------------------
    FUNCTION f_get_syst_loan_yn (
        p_clnt_id            IN      VARCHAR2,
        p_item_code           IN      VARCHAR2
    ) RETURN VARCHAR2

    IS
        s_result   VARCHAR2(1);
    BEGIN

        s_result := 'N' ;

        IF p_clnt_id = '001' AND
           ( p_item_code = '08101' OR
             p_item_code = '08102' OR
             p_item_code = '08103' OR
             p_item_code = '8101'  OR
             p_item_code = '8102'  OR
             p_item_code = '8103'  OR
             p_item_code = '09110' OR
             p_item_code = '10102' OR
             p_item_code = '10103' OR
             p_item_code = '10104' OR
             p_item_code = '10105' OR
             p_item_code = '10106' OR
             p_item_code = '10109' OR
             p_item_code = '11101' OR
             p_item_code = '11107' OR
             p_item_code = '11109' OR
             p_item_code = '11102' OR
             p_item_code = '11103' OR
             p_item_code = '11116' OR
             p_item_code = '08105' OR
             p_item_code = '8105' OR
             p_item_code = '08107' OR
             p_item_code = '8107' OR
             p_item_code = '11128') THEN

                 s_result := 'Y' ;

        ELSIF p_clnt_id = '002' AND
           ( p_item_code = '104007' OR
             p_item_code = '104008' OR
             p_item_code = '104012'      ) THEN

                 s_result := 'Y' ;

        ELSIF p_clnt_id = '003' AND
           ( p_item_code = '301010' OR
             p_item_code = '301011' OR
             p_item_code = '301031' OR
             p_item_code = '301032' OR
             p_item_code = '101005' OR
             p_item_code = '301055' OR
             p_item_code = '301056' OR
             p_item_code = '301044' OR
             p_item_code = '301043'     ) THEN

                 s_result := 'Y' ;

        ELSE
            s_result := 'N' ;
        END IF ;


        RETURN s_result;

    EXCEPTION

        WHEN OTHERS THEN
            RETURN s_result;

    END f_get_syst_loan_yn;

--------------------------------------------------------------------
-- 우편번호에 해당하는 관할부서 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_zip_team_code (
        p_zip_no             IN     VARCHAR2
    ) RETURN CA01BOND.team_code%TYPE

    IS
		s_result  CA01BOND.team_code%TYPE;
    BEGIN
        s_result := '';

        SELECT    NVL(a.and_link_team_code, '')    AS team_code
          INTO    s_result
          FROM    CM01ZIPC a
         WHERE    a.zip_no = p_zip_no
           AND    a.use_yn = ' '
           AND    ROWNUM = 1;

        RETURN s_result;

    EXCEPTION

        WHEN OTHERS THEN
            RETURN s_result;

    END f_get_zip_team_code;

--------------------------------------------------------------------
-- 수납내역 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_recp_amt (
        p_clnt_id             IN     VARCHAR2,
		p_cont_no             IN     VARCHAR2,
		p_bond_seq             IN     number
    ) RETURN number

    IS
		n_result  number;
    BEGIN
        n_result := 0;

        SELECT    nvl(sum(get_pamt+get_int), 0)
          INTO    n_result
          FROM    su02resu a
         WHERE    a.clnt_id = p_clnt_id
		   AND    a.cont_no = p_cont_no
		   AND    a.bond_seq = p_bond_seq
		   AND    a.dlng_ymd between to_char(add_months(sysdate, -6), 'yyyymmdd') and to_char(sysdate, 'yyyymmdd')
           AND    a.use_yn = ' ';

        RETURN n_result;

    EXCEPTION

        WHEN OTHERS THEN
            RETURN 0;

    END f_get_recp_amt;


--------------------------------------------------------------------
-- 민원 변제기일가져오기
--------------------------------------------------------------------
    FUNCTION  f_get_repy_tmlm (
        p_clnt_id             IN     VARCHAR2,
		p_cont_no             IN     VARCHAR2,
		p_bond_seq             IN     NUMBER
    ) RETURN VARCHAR2

    IS
		n_result  VARCHAR2(8);

    BEGIN
        n_result := '';

        SELECT     CASE WHEN a.bond_type = '10' THEN CASE WHEN NVL(a.dymd, '99991231') > NVL(a.LAST_EXPR_YMD, '99991231') THEN a.LAST_EXPR_YMD ELSE a.dymd END
				   			  ELSE a.LAST_RECV_YMD
						  END
          INTO    n_result
          FROM    CA01BOND a
         WHERE    a.clnt_id = p_clnt_id
		   AND    a.cont_no = p_cont_no
		   AND    a.bond_seq = p_bond_seq
--		   AND    a.dlng_ymd BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE, -6), 'yyyymmdd') AND TO_CHAR(SYSDATE, 'yyyymmdd')
           AND    a.use_yn = ' ';

        RETURN n_result;

    EXCEPTION

        WHEN OTHERS THEN
            RETURN '';

    END f_get_repy_tmlm;

--------------------------------------------------------------------
-- 대출번호로 위탁사 조회
--------------------------------------------------------------------
   FUNCTION f_get_clnt_id (
        p_loan_no                 IN     CA01BOND.loan_no%TYPE
    ) RETURN CA01BOND.clnt_id%TYPE

	IS
        c_clnt_id  CA01BOND.clnt_id%TYPE ;

    BEGIN

	    c_clnt_id  := ' ';

        SELECT  clnt_id
		  INTO  c_clnt_id
		  FROM  CA01BOND
		 WHERE  loan_no = p_loan_no
		   and   rownum = 1;

        RETURN c_clnt_id ;

    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN ' ' ;
        WHEN OTHERS THEN RETURN ' ';
    END f_get_clnt_id  ;

--------------------------------------------------------------------
--CB정보 결과
--------------------------------------------------------------------
    FUNCTION f_get_cb (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE,
        p_cust_id                 IN     CA01BOND.cust_id%TYPE,
        p_code                    IN     VARCHAR2
    ) RETURN CA10RVHS.revs_resl%TYPE
    IS
        c_code_name  CA10RVHS.revs_resl%TYPE;

    BEGIN
	    c_code_name  := '99';

                 SELECT /*+ INDEX_DESC (ca10rvhs, pk_ca10rvhs) */
                        revs_resl
                   INTO c_code_name
                   FROM CA10RVHS
                  WHERE cust_id   = p_cust_id
                    AND (clnt_id   = p_clnt_id OR clnt_id IS NULL)
                    AND revs_divi = p_code
                    AND ROWNUM    = 1;


        RETURN c_code_name;
    EXCEPTION
	    WHEN NO_DATA_FOUND THEN RETURN '99' ;
        WHEN OTHERS THEN RETURN '99';
    END f_get_cb;
    
    
--------------------------------------------------------------------
--사망여부 
--------------------------------------------------------------------
    FUNCTION f_get_dead_yn (
        p_cust_id                 IN     CA04cust.cust_id%TYPE
    ) RETURN CA04CUST.dead_yn%TYPE
    
    IS
        c_dead_yn  CA04CUST.dead_yn%TYPE;

    BEGIN
        c_dead_yn  := 'N';

        select case when c04.dead_yn = 'Y'
                        or c04.NADN_RESI_DIVI = '사망'
                        or (select count(*) 
                              from ca01bond c01
                             where c01.cust_id = p_cust_id
                               and ((c01.clnt_id = '001' and  c01.TRAN_RESN = '05')  --삼성 이관사유 : 사망
                                    or (c01.clnt_id = '002' and  c01.TRAN_RESN = '93') --교보 이관사유 : 사망
                                    or (c01.clnt_id = '003' and  c01.TRAN_RESN = '03') --한화 이관사유 : 사망
                                    or (c01.clnt_id = '500' and  c01.TRAN_RESN = '09') --카카오 이관사유 : 사망
                                   )
                           ) > 0 
                    then 'Y'
                    else 'N'
               end
          into c_dead_yn 
          from ca04cust c04 
         where cust_id = p_cust_id
           and use_yn  = ' '; 
        RETURN c_dead_yn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 'N' ;
        WHEN OTHERS THEN RETURN 'N';
    END f_get_dead_yn;
    
    
--------------------------------------------------------------------
--65세이상 고령자 
--------------------------------------------------------------------
    FUNCTION f_get_age_65_abov_yn (
        p_cust_id                 IN     CA04cust.cust_id%TYPE
    ) RETURN CA04CUST.age_65_abov_yn%TYPE
    
    IS
        c_age_65_abov_yn  CA04CUST.age_65_abov_yn%TYPE;

    BEGIN
        c_age_65_abov_yn  := 'N';

        select case when c04.age_65_abov_yn = 'Y' 
                           or case when length(xx1.dec_varchar2_sel(c04.cust_ssno,10,'SSN')) = 13 and substr(xx1.dec_varchar2_sel(c04.cust_ssno,10,'SSN')  , 7, 1) in ('1','2') and substr(c04.cust_id , 1,1)in ('1','2')
                    	   	       then trunc(MONTHS_BETWEEN(sysdate,  ADD_MONTHS(to_date('19'||substr(c04.cust_id , 2,6), 'yyyymmdd'),1))/12,0)
                    	           when length(xx1.dec_varchar2_sel(c04.cust_ssno,10,'SSN')) = 13 and substr(xx1.dec_varchar2_sel(c04.cust_ssno,10,'SSN')  , 7, 1) in ('3','4') and substr(c04.cust_id , 1,1)in ('1','2')
                    	  	       then trunc(MONTHS_BETWEEN(sysdate,  ADD_MONTHS(to_date('20'||substr(c04.cust_id , 2,6), 'yyyymmdd'),1))/12,0)
                    	  	       else 1
                    	      end	>= 65
                      then 'Y'
                      else 'N'
               end
          into c_age_65_abov_yn
          from ca04cust c04 
         where cust_id = p_cust_id
           and use_yn  = ' ';


        RETURN c_age_65_abov_yn;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN 'N' ;
        WHEN OTHERS THEN RETURN 'N';
    END f_get_age_65_abov_yn;    




--------------------------------------------------------------------------------------------
-- 수임안내장 3영업일 경과 여부  
--(마케팅 백운기 차장님 요청으로 종합카드 수임미발송 체크 로직과 일치시킴, 20160706)
--------------------------------------------------------------------------------------------
    FUNCTION f_get_mail_3_work_futr_yn (
        p_clnt_id             IN     VARCHAR2,
        p_cont_no             IN     VARCHAR2,
        p_bond_seq            IN     VARCHAR2,
        p_loan_no             IN     VARCHAR2,
        p_cust_id             IN     VARCHAR2
        
    ) RETURN VARCHAR2    
    IS
    
    c_mail_3_work_futr_yn CA04CUST.age_65_abov_yn%TYPE;        
    p_key     VARCHAR2(30) ;
    n_cnt     NUMBER       ;
    
    v_stdd_ymd VARCHAR2(8);
    v_rqst_ymd VARCHAR2(8);
    v_mail_ckeck_yn VARCHAR2(1);


    -- 수임사실 안내장 발송 여부
    BEGIN

        select case when rqst_ymd < '20160203' then '00010101' else rqst_ymd end
             , case when ca01.clnt_id in('001','002','003','004','050','060','097','090','094') and ca01.bond_type = '10' and ca01.team_code <> '4090' then 'Y' else 'N' end
          into v_rqst_ymd,v_mail_ckeck_yn 
          from ca01bond ca01
         where ca01.clnt_id = p_clnt_id
           and ca01.cont_no = p_cont_no
           and ca01.bond_seq = p_bond_seq;
        

        SELECT COUNT(*)
          INTO p_key
          FROM CA08MLLN n08
              ,CA08MAIL c08
        WHERE c08.cust_id = p_cust_id
          AND c08.clnt_id = p_clnt_id
          AND c08.mail_kind IN ('01' , '02', '03', '04', '05' ,'06', '47', '48', '51', '99', '68','77','87','90','106','107')
          AND c08.mail_aply_ymd >= '20090807'
         -- and c08.send_ymd is not null
          AND c08.curr_step NOT IN ('02','05')
          AND c08.CNCL_YN = 'N'
          AND c08.use_yn  = ' '
          AND n08.mail_admn_no = c08.mail_admn_no
          AND n08.send_lmit_resn_code = '01'
          AND n08.loan_no = p_loan_no
          AND (c08.MAIL_RCNT_PROG_STEP is null or c08.MAIL_RCNT_PROG_STEP = '20')
          AND comm_func.f_get_futr_wotk_date(c08.send_ymd, 3) <= to_char(sysdate, 'yyyymmdd')
          AND ((v_mail_ckeck_yn = 'Y' and to_char(to_date(v_rqst_ymd, 'yyyymmdd')-95, 'yyyymmdd') < c08.send_ymd) or v_mail_ckeck_yn = 'N')
          AND ROWNUM = 1;
        

       --주채무/연대보증인 외는 체크하지 않음(허충범 과장 요청 (2012-02-17))
       SELECT COUNT(*)
         INTO n_cnt
         FROM CA01BOND C01, CA02RELN C02
       WHERE C01.clnt_id = p_clnt_id
         AND C01.cont_no = p_cont_no
         AND C01.bond_seq = p_bond_Seq
         AND C02.use_yn  = ' '
         AND C01.clnt_id = C02.clnt_id
         AND C01.cont_no = C02.cont_no
         AND C01.bond_Seq = C02.bond_seq
         AND C01.rqst_ymd >= '20090807'
         AND C01.team_code <> '4090'
         AND C01.end_divi = '00'
         AND ((p_clnt_id IN ('001', '002' , '003') AND C01.bond_type = '10') OR (p_clnt_id NOT IN ('001', '002' , '003'))
                or comm_mail.f_get_wkot_cnt(c01.clnt_id, c01.cont_no, c01.bond_seq, c02.cust_id) > 0)
         AND (C01.mail_xcpt_chng_pgm is null or C01.mail_xcpt_chng_pgm <> 'ATAPMAIL')
         AND C01.use_yn  = ' '
         AND C02.cust_id = p_cust_id
         AND (C02.debt_divi in ('11', '12', '13', '18', '21', '25') or (C01.clnt_id in ('162','163','164','165','166','167','168','169','170','171') and C02.debt_divi = '19') )
         ;

        IF n_cnt > 0 THEN
            IF p_key > 0 THEN
              c_mail_3_work_futr_yn   := 'Y' ;
            ELSE
              c_mail_3_work_futr_yn  := 'N' ;
            END IF ;
        ELSE
           c_mail_3_work_futr_yn   := 'Y' ;
        END IF ;

        RETURN c_mail_3_work_futr_yn;

        EXCEPTION    
    
        WHEN NO_DATA_FOUND THEN RETURN 'N' ;
        WHEN OTHERS THEN RETURN 'N';
        
    END f_get_mail_3_work_futr_yn;   


END;