/*PL SQL이란?
PL/SQL 은 ORACLE'S PROCEDURAL LANGUAGE EXTENSION TO SQL
변수정의, 조건처리(IF), 반복처리(LOOP, WHILE, FOR)등을 지원하며 오라클 자체내에 내장되어있는 PROCEDURE LANGUAGE
-DECLARE문을 이용하여 정의, 선언문의 사용은 선택사항
-PL/SQL문은 블록 구조로 되어있고 PL/SQL자신이 컴파일 엔진을 가지고 있다.
-BLOCK	구조로 다수의 SQL문을 오라클 DB로 보내 수행속도 향상
-모든 요소는 하나 또는 두개이상의 블록으로 구성하여 모듈화 가능
-VARIABLE, CONSTANT, CURSOR, EXCEPTION 정의
-테이블의 데이터 구조와 컬럼명르 준하여 동적으로 변수를 선언 
*/ 
/*
PL/SQL Block Structure :프로그램을 논리적인 블록으로 나누는 구조화 된 블록언어
블록은 선언부(선택적), 실행부(필수적), 예외처리부(선택적) 구정 BEGIN, END 키워드는 반드시 기술
PL/SQL블록에서 사용하는 변수는 블록에 대해 논리적으로 선언할 수 있고 사용할 수 있다.
*/
--DECLARE   --optional
    	   	--variables, cursors, user-defined exception
--BEGIN    	--mandotory
			--SQL statement
			--PL/SQL statement
--EXCEPTION --Actions to perform when errors occur
--END 		--mandotory			
선언부 : 변수, 상수 coursor, user_define_exception 선언
실행부 : sql문, 반복문, 조건문, BEGIN으로 시작하고 END로 종료(필수)
예외처리 : 일반적 오류 정의하고 처리하는 부분
 /**/
블록내에서 한 문장이 종료할때마다 세미콜론(;)사용
END뒤에는 세미콜론(;) 블록이 끝났다는것을 명시
PL/SQL블록의 작성은 편집기 통해 파일로 작성할수 있고,SQL프롬프트에서 바로 작성할수도있다.   
sqlplus환경에서는 declare나 begin이라는 키워드로 pls/sql블록이 시작하는것을 알수 있다.
여러행주석/**/ 단일행주석--
pl/sql블록은 행에 /가 있으면 종결된다

/*PL SQL블럭의 유형*/
--1) Anonymous(익명블록)
   이름없는 블록, 실행하기 위해 프로그램 안에서 선언되고
   , 실행시에 실행을 위해 PL/SQL엔진으로 전달된다. 
   [DECLARE]
   BEGIN     
   		STATEMENT
   [EXCEPTION]
   END;
--2) procedure(프로시져)
	특정 작업을 수행할 수 있는 이름이 있는 PL/SQL블록, 
	매개변수를 받을수 있고, 반복적으로 사용할수 있다.  
	PROCEDURE name IS
	BEGIN 
		STATEMENT
	[EXCEPTION]
	END;	
--3) function(함수)
    보통 값을 계산하고 반환하고싶을때 사용,
    대부분 구성이 프로시져와 비슷하지만 IN 파라미터만 사용할수 있고,
    반드시 반환 될 값의 데이터 타입을 RETURN문에 선언해야한다.
    FUNCTION name 
    RETURN datatype 
    IS
    BEGIN 
    	STATEMENT
    RETURN value
    [EXCEPTION]
    END;
/*프로시저란
보통 연속 실행 또는 구현이 복잡한 트랜잭션 수행하는 pl/sql block을 데이터베이스에 저장하기 위해 생성 
*/
--1) 문법
CREATE OR REPLACE procedure name   --CREATE OR REPLACE구문으로 생성
IN argument
OUT argument
IN OUT argument
IS                                 --IS로 PL/SQL의 블록을 시작
[변수의 선언]                      --LOCAL변수는 IS와 BEGINS사이에 선언한다
BEGIN                              --필수
[PL/SQL_BLOCK]                     --SQL문장, PL/SQL 제어문장
[EXCEPTION]                        --ERROR발생시 수행하는 문장
END;                               --필수

--2) 예제
CREATE OR REPLACE PROCEDURE update_sal --프로시져명 update_sal
/* IN Parameter */
	(v_empno IN NUMBER)
	IS
	BEGIN
		UPDATE emp
		SET sal=sal*1.1
		WHERE empno=v_empno
		
		COMMIT;
	END update_sal;
	/	
	
/*실전예제	
   procedure back01_ca05clcu  (
        p_ret          out     varchar2,    -- 함수에 들어오는 변수  또는 리턴되는 값을 변수로 명명 및 데이터타입 정의
        p_msg          out     varchar2
    )
    is   -- is이후에 선언되는 변수는 plsql블록내에서만 매개변수로 사용

    cursor inst_list is        -- 매개변수를 리스트화한 cusror 정의
        select *
          from ca05clcu
         where (clnt_id, cust_id) in (
                select clnt_id, cust_id from ca02reln a
                where (a.clnt_id, a.cont_no, a.bond_seq) in (
                select clnt_id, cont_no, bond_seq from ca01bond
                where to_char(end_date, 'yyyymmdd') <= '20081130'
         )
           and not exists(select c.clnt_id from ca01bond b, ca02reln c
                          where b.clnt_id = c.clnt_id
                            and b.cont_no = c.cont_no
                            and b.bond_seq = c.bond_seq
                            and c.clnt_id = a.clnt_id
                            and c.cust_id = a.cust_id
                            and (b.end_date is null or to_char(b.end_date, 'yyyymmdd') > '20081130'))
        ) ;
          
        proc_cnt    number ;  -- 매개변수



    begin


        p_ret := '00' ;
        p_msg := '처리완료' ;

        proc_cnt := 0 ;


        for aa in inst_list loop
            insert into ya05clcu values (
                          aa.CLNT_ID            
                        , aa.CUST_ID            
                        , aa.CLNT_CUST_NO       
                        , aa.MEMO               
                        , aa.HOME_ZIP_NO        
                        , aa.HOME_ZIP_SEQ       
                        , aa.HOME_ZIP_ADDR      
                        , aa.HOME_ADDR          
                        , aa.WKPL_ZIP_NO        
                        , aa.WKPL_ZIP_SEQ       
                        , aa.WKPL_ZIP_ADDR      
                        , aa.WKPL_ADDR          
                        , aa.ETC_ZIP_NO         
                        , aa.ETC_ZIP_SEQ_NO     
                        , aa.ETC_ZIP_ADDR       
                        , aa.ETC_ADDR           
                        , aa.MAIL_SEND_PLAC_DIVI
                        , aa.ADDR_CHNG_YN       
                        , aa.ATCL_XCPT_RESN     
                        , aa.ATCL_XCPT_INPT_DATE
                        , aa.ATCL_XCPT_INPT_STAF
                        , aa.MAIL_XCPT_RESN     
                        , aa.MAIL_XCPT_DATE     
                        , aa.MAIL_XCPT_STAF     
                        , aa.HOME_MAIL_XCPT_YN  
                        , aa.HOME_MAIL_XCPT_DATE
                        , aa.HOME_MAIL_XCPT_STAF
                        , aa.WKPL_MAIL_XCPT_YN  
                        , aa.WKPL_MAIL_XCPT_DATE
                        , aa.WKPL_MAIL_XCPT_STAF
                        , aa.ETC_MAIL_XCPT_YN   
                        , aa.ETC_MAIL_XCPT_DATE 
                        , aa.ETC_MAIL_XCPT_STAF 
                        , aa.CLNT_MEMO_BSNS_DIVI
                        , aa.CLNT_MEMO_RFRC_NO  
                        , aa.CLNT_MEMO_SPCL_ITEM
                        , aa.INPT_DATE          
                        , aa.INPT_STAF          
                        , aa.CHNG_DATE          
                        , aa.CHNG_STAF          
                        , aa.CHNG_PGM_ID        
                        , aa.DELE_DATE          
                        , aa.DELE_STAF          
                        , aa.USE_YN             
                        , aa.HOLR_NAME          
                        , aa.HOME_CHNG_STAF     
                        , aa.WKPL_CHNG_DATE     
                        , aa.WKPL_CHNG_STAF     
                        , aa.ETC_CHNG_DATE      
                        , aa.ETC_CHNG_STAF      
                        , aa.HOME_CHNG_DATE     
                        , aa.CNVS_HOME_ZIP_NO   
                        , aa.CNVS_HOME_ZIP_SEQ  
                        , aa.CNVS_HOME_ZIP_ADDR 
                        , aa.CNVS_HOME_ADDR     
                        , aa.HOME_BLDG_ADMN_NO  
                        , aa.HOME_ADDR_DIVI     
                        , aa.CNVS_HOME_XAXIS    
                        , aa.CNVS_HOME_YAXIS    
                        , aa.HOME_XAXIS         
                        , aa.HOME_YAXIS         
                        , aa.CNVS_WKPL_ZIP_NO   
                        , aa.CNVS_WKPL_ZIP_SEQ  
                        , aa.CNVS_WKPL_ZIP_ADDR 
                        , aa.CNVS_WKPL_ADDR     
                        , aa.WKPL_BLDG_ADMN_NO  
                        , aa.WKPL_ADDR_DIVI     
                        , aa.CNVS_WKPL_XAXIS    
                        , aa.CNVS_WKPL_YAXIS    
                        , aa.WKPL_XAXIS         
                        , aa.WKPL_YAXIS         
                        , aa.CNVS_ETC_ZIP_NO    
                        , aa.CNVS_ETC_ZIP_SEQ   
                        , aa.CNVS_ETC_ZIP_ADDR  
                        , aa.CNVS_ETC_ADDR      
                        , aa.ETC_BLDG_ADMN_NO   
                        , aa.ETC_ADDR_DIVI      
                        , aa.CNVS_ETC_XAXIS     
                        , aa.CNVS_ETC_YAXIS     
                        , aa.ETC_XAXIS          
                        , aa.ETC_YAXIS          
                        , aa.HOME_ERR_CODE      
                        , aa.WKPL_ERR_CODE      
                        , aa.ETC_ERR_CODE       

            )    ;

            proc_cnt := proc_cnt + 1;

            if mod(proc_cnt, 1000)   = 0 then
                commit ;               --1000개씩 commit

            end if ;

        end loop ;


        commit ;

        p_ret := '00' ;
        p_msg := '정상처리완료 : ' || proc_cnt ;

    exception
        when no_data_found then
            p_ret := '00' ;
            p_msg := '정상적으로 저장되었습니다.' ;


        when others then
            rollback ;

            p_ret := '10' ;
            p_msg := '처리시  에러- [' ||SQLCODE||']'|| SQLERRM;

    end;
*/	
--3) 예제 실행
--SQL> EXECUTE update_sal(7368); --7368번 사원의 급여가 10% 인상	
		
		
/* 함수란
보통값을 계산하고 결과 값을 반환하기 위해 사용, IN 파라미터만 사용, 반드시 RETURN문을 통해 결과 값 반환
*/
--1) 문법
CREATE OR REPLACE FUNCTION function_name
	[(argument...)]
	RETURN datatype  --반환되는 값의 dataype이다
IS
	[변수선언부분]
BEGIN 
	[PL/SQL Block]
	RETURN 변수; --리턴문이 꼭 존재해야한다.
END;
--2) 예제
CREATE OR REPLACE FUNCTION FC_update_sal
	(v_empno IN NUMBER)
	RETURN NUMBER
IS
--%type 변수가 사용(스칼라 데이터 타입을 꼭 정의해야한다)
	v_sal emp.sal%type;
	BEGIN
	
	UPDATE emp
	SET sal=sal*1.1
	WHERE empno=v_empno;
	
	--리턴문이 꼭 존재해야한다.
	RETURN v_sal;
END;
/   
--3) 예제 실행
--SQL> VAR salary NUMBER;

--EXECUTE :salary := FC_update_sal(7900);

--PRINT문을 사용하여 출력
--SQL > PRINT salary;
--	
--	SALARY
---------------------
--	1045
--또는 SELECT문장에서도 사용 가능
-- SELECT ename, FC_update_sal(sal) FROM emp;   

/* 스칼라 데이터타입 : 일반단일 데이터타입, %type 데이터형 변수가 있다. */

--1) 일반변수 선언 문법
identifier [CONSTANT] 데이터타입 [NOT NULL] [:=상수값이나 표현식];
identifier(변수)의 이름은 sql의 object명과 동일한 규칙
identifier를 상수로 지정하고 싶은 경우는 CONSTANT라는 KEYWORD 명시하고 반드시 초기값 할당
NOTNULL이 정의되어 있으면 반드시 초기값을 설정, 정의되어있지 않으면 생략가능 
초기값은 할당 연산자(:=)를 사용하여 정의한다.
초기값을 정의하지 않으면 identifier는 null값을 가지게 된다.
일반적으로 한 줄에 한 개의 identifier를 정의한다.
--2) 일반변수 선언 예제
--숫자형 상수 선언(변할 수 없다)
v_price CONSTANT NUMBER(4,2) := 12.34 -- NUMBER(4,2) 4자리 숫자, 소숫점 2자리까지
v_name VARCHAR2(20) ;
v_Bir_Type CHAR(1) ;
--NOT NULL의 TRUE로 초기화
v_flag BOOLEAN NOT NULL := TRUE;
v_birthday DATE;
--3) TYPE 데이터형
테이블의 컬럼 데이터 타입을 모를 경우 사용
이미 선언된 다른 변수나 데이터베이스 컬럼의 데이터 타입을 이용하여 선언
DB column definition이 변경 되어도 다시 pl/sql을 고칠 필요가 없다. 
--4) %TYPE 사용예제
SQL > 
CREATE OR REPLACE PROCEDURE emp_info
-- IN Parameter
	(e_empno IN emp.empno%TYPE )
IS
-- %TYPE 데이터형 변수 선언
	v_empno emp.empno%TYPE;   
	v_ename emp.ename%TYPE;
	v_sal emp.sal%TYPE;
		
	BEGIN
	DBMS_OUTPUT.ENABLE;
--%TYPE 데이터형 변수 사용
	SELECT empno,ename,sal
	INTO v_empno, v_ename, v_sal
	FROM emp
	WHERE empno=p_empno;
--결과값 출력
	DBMS_OUTPUT.PUT_LINE('사원번호 : '||v_empno);
	DBMS_OUTPUT.PUT_LINE('사원이름 : '||v_ename);
	DBMS_OUTPUT.PUT_LINE('사원급여 : '||v_sal);
	END;
	/	
--	DBMS_OUTPUT 결과값을 화면에 출력 하기위해
SQL> SET SERVEROUTPUT ON;

-- 실행결과
SQL> EXECUTE emp_info(7369);
사원번호 : 7369
사원이름 : SMITH
사원급여 : 880
	






	

		