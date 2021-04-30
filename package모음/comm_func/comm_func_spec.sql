CREATE OR REPLACE PACKAGE OPARSE.Comm_Func
--------------------------------------------------------------------------------
-- package 기능 : 자주 쓰이는 공통적인 함수를 모아둠
-- 작성일자     : 2006/06/20
-- 작성자       : 전산팀
--------------------------------------------------------------------------------
-- 수정일자     :
-- 수정자       :
-- 수정내용     :
--------------------------------------------------------------------------------
IS
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
--------------------------------------------------------------------
-- 코드아이디, 코드값으로 코드명 조회
--------------------------------------------------------------------
    FUNCTION f_get_code_name (
        p_code_id                 IN     CM02CODE.code_id%TYPE,
        p_code_val                IN     CM02CODE.code_val%TYPE
    ) RETURN CM02CODE.code_name%TYPE;
    PRAGMA RESTRICT_REFERENCES( f_get_code_name,WNDS);

--------------------------------------------------------------------
-- 코드아이디, 코드값으로 코드명 조회
--------------------------------------------------------------------
    FUNCTION f_get_crp_code_name (
        p_code_id                 IN     CM02CODE.code_id%TYPE,
        p_code_val                IN     CM02CODE.code_val%TYPE
    ) RETURN CM02CODE.code_name%TYPE;
    PRAGMA RESTRICT_REFERENCES( f_get_code_name,WNDS);

--------------------------------------------------------------------
-- 코드아이디, 코드명 으로 코드값 조회
--------------------------------------------------------------------
    FUNCTION f_get_code_val (
        p_code_id                 IN     CM02CODE.code_id%TYPE,
        p_code_name               IN     CM02CODE.code_name%TYPE
    ) RETURN CM02CODE.code_val%TYPE;
    PRAGMA RESTRICT_REFERENCES( f_get_code_val,WNDS);



--------------------------------------------------------------------
-- 팀/부서명 가져오기
-- 구분값 1: 팀코드 2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식), 4.사번
--------------------------------------------------------------------
    FUNCTION f_get_team_name (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CM03ORGN.team_name%TYPE;
    PRAGMA RESTRICT_REFERENCES(f_get_team_name,WNDS);




--------------------------------------------------------------------
-- 팀코드 가져오기
-- 사번으로 조회
--------------------------------------------------------------------
    FUNCTION f_get_team_code (
        p_staf_id                    IN     VARCHAR2
    ) RETURN CM03ORGN.team_code%TYPE;
    PRAGMA RESTRICT_REFERENCES(f_get_team_code,WNDS);


--------------------------------------------------------------------
-- 사원명 가져오기
-- 구분값 1: 사번 2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--------------------------------------------------------------------
    FUNCTION f_get_staf_name (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CM03STAF.staf_name%TYPE;
    PRAGMA RESTRICT_REFERENCES(f_get_staf_name ,WNDS);


--------------------------------------------------------------------
-- 사번으로 사원전화번호 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_staf_tel (
        p_staf_id                 IN     CM03STAF.staf_id%TYPE
    ) RETURN CM03STAF.wkpl_tel%TYPE;
    PRAGMA RESTRICT_REFERENCES(f_get_staf_tel,WNDS);

	--------------------------------------------------------------------
-- 사번으로 사원팩스번호 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_staf_fax (
        p_staf_id                 IN     CM03STAF.staf_id%TYPE
    ) RETURN CM03STAF.fax_no%TYPE;
    PRAGMA RESTRICT_REFERENCES(f_get_staf_fax,WNDS);

--------------------------------------------------------------------
-- 주민번호가져오기
-- 구분값  1. 고객아이디,  2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--         4. 대출번호
--------------------------------------------------------------------
    FUNCTION f_get_cust_ssno (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CA04CUST.cust_ssno%TYPE;
   -- PRAGMA RESTRICT_REFERENCES(f_get_cust_ssno,WNDS);


--------------------------------------------------------------------
-- 고객명(채무자명) 가져오기
-- 구분값  1. 고객아이디, 위탁사아이디  2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--         4. 대출번호
--------------------------------------------------------------------
    FUNCTION f_get_cust_name (
        p_divi                    IN     VARCHAR2,
        p_key1                    IN     VARCHAR2,
        p_key2                    IN     VARCHAR2
    ) RETURN ca02reln.cust_name%TYPE;
    PRAGMA RESTRICT_REFERENCES(f_get_cust_name,WNDS);




--------------------------------------------------------------------
-- 고객아이디 가져오기
-- 구분값  1. 주민번호, 2. 채권번호(001-02041-1234 형식), 3 채권번호 (001020411234 형식)
--         4. 대출번호
--------------------------------------------------------------------
    FUNCTION f_get_cust_id (
        p_divi                    IN     VARCHAR2,
        p_key                     IN     VARCHAR2
    ) RETURN CA04CUST.cust_id%TYPE;
   -- PRAGMA RESTRICT_REFERENCES(f_get_cust_id,WNDS);



--------------------------------------------------------------------
-- 현재PPD조회
-- 채권번호로 ppd 조회
--------------------------------------------------------------------
    FUNCTION f_get_ppd (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE,
        p_cont_no                 IN     CA01BOND.cont_no%TYPE,
        p_bond_seq                IN     CA01BOND.bond_seq %TYPE
    ) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(f_get_ppd,WNDS);


--------------------------------------------------------------------
-- 현재PPD조회
-- 대출번호로 ppd 조회
--------------------------------------------------------------------
    FUNCTION f_get_ppd_loan_no (
        p_loan_no                 IN     CA01BOND.loan_no%TYPE
    ) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(f_get_ppd_loan_no,WNDS);

--------------------------------------------------------------------
-- 위탁사명 조회
-- input : 위탁사아이디
--------------------------------------------------------------------
    function f_get_clnt_name (
        p_clnt_id                 in     ca01bond.clnt_id%type
    ) return ca04clnt.clnt_name%type;
    PRAGMA RESTRICT_REFERENCES( f_get_clnt_name,WNDS);


--------------------------------------------------------------------------------
--- 우편번호로 우편주소 가져오기
--------------------------------------------------------------------------------
    function find_zip_addr(
        p_zip_no          in      varchar2
    ) return varchar2;
    pragma restrict_references(find_zip_addr,WNDS);


--------------------------------------------------------------------
-- 채권번호로 대출번호 조회
--------------------------------------------------------------------
    FUNCTION f_get_loan_no (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
    ) RETURN CA01BOND.loan_no%TYPE;
    PRAGMA RESTRICT_REFERENCES( f_get_loan_no,WNDS);


--------------------------------------------------------------------
-- 대출번호로 채권번호 조회
--------------------------------------------------------------------
    FUNCTION f_get_bond_no (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_loan_no                 IN     CA01BOND.loan_no%TYPE
    ) RETURN  VARCHAR2;
    PRAGMA RESTRICT_REFERENCES( f_get_bond_no,WNDS);




--------------------------------------------------------------------
-- 채권번호로 가상계좌 번호 조회
--------------------------------------------------------------------
    FUNCTION f_get_virt_bank (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
    ) RETURN varchar2 ;
    PRAGMA RESTRICT_REFERENCES( f_get_virt_bank,WNDS);


--------------------------------------------------------------------
-- 채권번호 및 고객 아이디로 채무구분 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_debt_divi (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
       ,p_cust_id                 IN     CA02RELN.cust_id%TYPE
    ) RETURN varchar2 ;
    PRAGMA RESTRICT_REFERENCES( f_get_virt_bank,WNDS);

--------------------------------------------------------------------
-- 전화번호 포멧지정
--------------------------------------------------------------------
    FUNCTION f_tel_no_format (
        p_tel_no                  IN     varchar2
    ) RETURN varchar2 ;
   -- PRAGMA RESTRICT_REFERENCES( f_tel_no_format ,WNDS);
--------------------------------------------------------------------
-- 담당자 지정여부 check
--------------------------------------------------------------------
    function check_staf_allo(
        p_clnt_id               in      varchar2,
        p_cont_no             in      varchar2,
        p_bond_seq             	in      varchar2
    ) return varchar2;
    pragma restrict_references(check_staf_allo,WNDS);

--------------------------------------------------------------------
-- 채권번호로 우편물 발송건수 가져오기 (20061120.hjson)
--------------------------------------------------------------------
    function f_get_mail_cnt(
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE
       ,p_cont_no                 IN     CA01BOND.cont_no%TYPE
       ,p_bond_seq                IN     CA01BOND.bond_seq%TYPE
       ,p_cust_id                 IN     CA01BOND.cust_id%TYPE
    ) return number;
    pragma restrict_references(f_get_mail_cnt,WNDS);

--------------------------------------------------------------------
-- 당일이전 영업일 가져오기
--------------------------------------------------------------------
    function f_get_befo_wotk_date (
        p_stdd_ymd            in      varchar2,
        p_day             	  in      number
    ) return varchar2;
    pragma restrict_references(f_get_befo_wotk_date,WNDS);

--------------------------------------------------------------------
-- 당일이후 영업일 가져오기
--------------------------------------------------------------------
    function f_get_futr_wotk_date (
        p_stdd_ymd            in      varchar2,
        p_day             	  in      number
    ) return varchar2;
    pragma restrict_references(f_get_futr_wotk_date,WNDS);





--------------------------------------------------------------------
-- 시스템 대출 확인
--------------------------------------------------------------------
    function f_get_syst_loan_yn (
        p_clnt_id            in      varchar2,
        p_item_code      	 in      varchar2
    ) return varchar2;
    pragma restrict_references(f_get_syst_loan_yn,WNDS);

--------------------------------------------------------------------
-- 우편번호에 해당하는 관할부서 가져오기
--------------------------------------------------------------------
    function f_get_zip_team_code (
        p_zip_no             in     varchar2
    ) return ca01bond.team_code%type;
    pragma restrict_references(f_get_zip_team_code,WNDS);

--------------------------------------------------------------------
-- 수납내역 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_recp_amt (
        p_clnt_id             IN     VARCHAR2,
		p_cont_no             IN     VARCHAR2,
		p_bond_seq             IN     number
    ) RETURN number;
	pragma restrict_references(f_get_recp_amt,WNDS);
--------------------------------------------------------------------
-- 민원변제기일 가져오기
--------------------------------------------------------------------
    FUNCTION f_get_repy_tmlm (
        p_clnt_id             IN     VARCHAR2,
		p_cont_no             IN     VARCHAR2,
		p_bond_seq             IN     NUMBER
    ) RETURN VARCHAR2;

	PRAGMA RESTRICT_REFERENCES(f_get_repy_tmlm,WNDS);

--------------------------------------------------------------------
-- 대출번호로 위탁사 조회
--------------------------------------------------------------------
FUNCTION f_get_clnt_id (
        p_loan_no                 IN     CA01BOND.loan_no%TYPE
    ) RETURN CA01BOND.clnt_id%TYPE ;
    PRAGMA RESTRICT_REFERENCES( f_get_clnt_id,WNDS);

--------------------------------------------------------------------
--CB정보 결과
--------------------------------------------------------------------
    FUNCTION f_get_cb (
        p_clnt_id                 IN     CA01BOND.clnt_id%TYPE,
        p_cust_id                 IN     CA01BOND.cust_id%TYPE,
        p_code                    IN     VARCHAR2
    ) RETURN CA10RVHS.revs_resl%TYPE;
    PRAGMA RESTRICT_REFERENCES( f_get_cb,WNDS);
    
--------------------------------------------------------------------
--사망여부 
--------------------------------------------------------------------
    FUNCTION f_get_dead_yn (
        p_cust_id                 IN     CA04cust.cust_id%TYPE
    ) RETURN CA04CUST.dead_yn%TYPE;
      
    
--------------------------------------------------------------------
--65세이상 고령자  
--------------------------------------------------------------------
    FUNCTION f_get_age_65_abov_yn (
        p_cust_id                 IN     CA04cust.cust_id%TYPE
    ) RETURN CA04CUST.age_65_abov_yn%TYPE;    


--------------------------------------------------------------------
--수임안내장 3영업일 경과 여부  
--------------------------------------------------------------------
    FUNCTION f_get_mail_3_work_futr_yn (
        p_clnt_id             IN     VARCHAR2,
        p_cont_no             IN     VARCHAR2,
        p_bond_seq            IN     VARCHAR2,
        p_loan_no             IN     VARCHAR2,
        p_cust_id             IN     VARCHAR2

    ) RETURN VARCHAR2;

    PRAGMA RESTRICT_REFERENCES(f_get_mail_3_work_futr_yn,WNDS);


END; -- Package spec