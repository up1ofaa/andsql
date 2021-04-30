/* DML/DDL/DCL

1) DML(조작어 MANIPATURATION) : INSERT, UPDATE
								, DELETE(delete data with undo and will be necessary to commit), MERGE
2) DDL(정의어 DEFINITION): CREATE, ALTER, DROP(delete table without undo, commit)
							, RENAME, TRUNCATE(delete data without undo,commit)
3) 트랜잭션 제어(TCL) (COMMIT, ROLLBACK, SAVEPOINT)
4) DCL(제어어 CONTROLL) : GRANT, REVOKE
   */
   
--(1) MERGE   : UPDATE와 INSERT중 조건에 따라 알맞은 것을 선택
--(2) RENAME
--(3) TRUNCATE
--(4) SAVEPOINT
--(5) GRANT
--(6) REVOKE
   
--MERGE INTO DS01STAT                                                                                                                                                                                           
--USING DUAL                                                                                                                                                                                                    
--ON (clnt_id  = '&clnt_id'                                                                                                                                                                                     
--and cont_no  = '&cont_no' 												                                                                                                                                      
--and bond_seq = '&bond_seq'         										                                                                                                                                      
--      WHEN MATCHED THEN                                                                                                                                                                                       
--               UPDATE SET                                                                                                                                                                                     
--                                 PRSC_STAT          = '&prsc_stat'                                                                                                                                            
--                                ,PRSC_RCKN_YMD      = '&prsc_rckn_ymd'                                                                                                                                        
--                                ,PRSC_EXPR_YMD      = '&prsc_expr_ymd'                                                                                                                                        
--                                ,PRSC_STOP_YMD      = '&prsc_stop_ymd'                                                                                                                                        
--                                ,PRSC_STOP_RESN     = '&prsc_stop_resn'                                                                                                                                       
--                                ,PRSC_COMP_YMD      = '&prsc_comp_ymd'                                                                                                                                        
--                                ,PRSC_COMP_RESN     = '&prsc_comp_resn'                                                                                                                                       
--                                ,CHNG_DATE          = sysdate                                                                                                                                                 
--                                ,CHNG_STAF          = '90000'                                                                                                                                                 
--                                ,CHNG_PGM_ID        = 'BCAAE'                                                                                                                                                 
--       WHEN NOT MATCHED THEN                                                                                                                                                                                  
--               INSERT (                                                                                                                                                                                       
--                             CLNT_ID                                                                                                                                                                          
--                            ,CONT_NO                                                                                                                                                                          
--                            ,BOND_SEQ                                                                                                                                                                         
--                            ,PRSC_STAT                                                                                                                                                                        
--                            ,PRSC_RCKN_YMD                                                                                                                                                                    
--                            ,PRSC_EXPR_YMD                                                                                                                                                                    
--                            ,PRSC_STOP_YMD                                                                                                                                                                    
--                            ,PRSC_STOP_RESN                                                                                                                                                                   
--                            ,PRSC_COMP_YMD                                                                                                                                                                    
--                            ,PRSC_COMP_RESN                                                                                                                                                                   
--                            ,INPT_DATE                                                                                                                                                                        
--                            ,INPT_STAF                                                                                                                                                                        
--                            ,CHNG_DATE                                                                                                                                                                        
--                            ,CHNG_STAF                                                                                                                                                                        
--                            ,CHNG_PGM_ID                                                                                                                                                                      
--                            ,USE_YN                                                                                                                                                                           
--                         )                                                                                              
--               VALUES (                                                                                                                                                                                       
--                             '&clnt_id'                                                                                                                                                                       
--                            ,'&cont_no'                                                                                                                                                                       
--                            ,'&bond_seq'                                                                                                                                                                      
--                            ,'&prsc_stat'                                                                                                                                                                     
--                            ,'&prsc_rckn_ymd'                                                                                                                                                                 
--                            ,'&prsc_expr_ymd'                                                                                                                                                                 
--                            ,'&prsc_stop_ymd'                                                                                                                                                                 
--                            ,'&prsc_stop_resn'                                                                                                                                                                
--                            ,'&prsc_comp_ymd'                                                                                                                                                                 
--                            ,'&prsc_comp_resn'                                                                                                                                                                
--                            ,sysdate                                                                                                                                                                          
--                            ,'90000'                                                                                                                                                                          
--                            ,sysdate                                                                                                                                                                          
--                            ,'90000'                                                                                                                                                                          
--                            ,'BCAAE'                                                                                                                                                                          
--                            ,' '                    			                                                                                                                                              
--                         )    

MERGE INTO TABLEA A       --UPDATE 또는 INSERT할 테이블명 뷰
USING TABLEB B            --만일 참조할(값비교 또는 가져올) 테이블이 없다면 DUAL 사용
ON ( A.COL1=B.COL2 AND A.COL2=B.COL2 AND A.COL3=B.COL3 ) -- 삽입또는 수정할 테이블의 항목(칼럼)조건
WHEN MATCHED THEN  --일치되는경우 UPDATE
UPDATE SET         --조인조건(ON)절에 사용한 컬럼은 UPDATE가 불가하다
 A.COL4=B.COL4
,A.COL5=B.COL5
,A.COL6='AAAAA'
,A.COL7=SYSDATE
WHEN NOT MATCHED THEN   --일치안되는경우 INSERT   
INSERT ( A.COL1
		,A.COL2
		,A.COL3
		,A.COL4
		,A.COL5
		,A.COL6
		,A.COL7)
VALUES ( ''
		,''
		,''
		,''
		,''
		,''
		,'')
; 
-- 즉 A테이블을 B테이블로 업데이트
merge into imsi_tb_shy1 a
using  imsi_tb_shy2 b
on (a.col1=b.col1
	and a.col2=b.col2)
when matched then
update  set
a.col3=b.col3
,a.col4=b.col4
,a.col5=sysdate
when not matched then
insert (a.col1
		,a.col2
		,a.col3
		,a.col4
		,a.col5)
values(b.col1
	  ,b.col2
	  ,b.col3
	  ,b.col4
	  ,sysdate)
	  ;




--부서번호 20,30의 사원이 존재하면 급여를 10%인상하고, 
--존재하지 않으면 급여가 1000보다 큰 사원정보를 등록     

--사원이 존재하면 급여를 10% 인상하고, 없으면 INSERT 한다
MERGE INTO emp_merge_test m
USING (SELECT empno, deptno, sal  		--USING 절에 뷰가 올 수 있다.
		FROM emp
		WHERE deptno IN(20,30)) e
ON (m.empno=e.empno)
WHEN MATCHED THEN 
	UPDATE SET m.sal=ROUND(m.sal*1.1)
WHEN NOT MATCHED THEN                 	
	INSERT (m.empno, m.deptno, m.sal)
	VALUES (e.empno, e.deptno, e.sal)
WHERE e.sal > 1000                    	--INSERT 절의 조건절도 지정이 가능하다
;                                                                             


--부서번호 10의 사원급여를 10% 인상하고, 
--부서번호 20의 사원정보는 삭제하며,
--부서번호 30의 사원급여는 20% 인상한다.
MERGE INTO emp_merge_test m
USING emp e
ON (m.empno=e.empno)
WHEN MATCHED THEN
     UPDATE SET m.sal=ROUND(m.sal*1.1) 
     WHERE m.deptno=20
	 DELETE WHERE m.deptno=20
WHEN NOT MATCHED THEN
	 INSERT (m.empno, m.deptno, m.sal )
	 VALUES (e.empno, e.deptno, ROUND(e.sal*1.2))
;

--업데이트나 입력 하나만 실행할수도 있습니다
--존재하면 아무것도 하지않고 , 없으면 입력하려려면 다음과 같이 합니다.
MERGE INTO TB_SCORE S
  USING DUAL
    ON (S.COURSE_ID ='C1' AND S.STUDENT_ID='S1')
    WHEN NOT MATCHED THEN
    INSERT (S.COURSE_ID, S.STUDENT_ID, S.SCORE)
    VALUES('C1','S1',20)
;    



--RENAME
--ALTER TALBE old_table RENAME new_table

--RENAME TABLE old_table TO tmp_table,
--			 new_table TO old_table,  
--			 tmp_table TO new_table; 

--RENAME TABLE current_db.tbl_name TO other_db.tbl_name;

 
			 
--TRUNCATE  
--해당 테이블의 데이터를 모두 삭제하는 명령어
--DROP이 테이블의 정의를 삭제하는 것과 다르게 테이블은 남겨놓고 데이터를 삭제해 버린다.
--이 명령어를 수행한 이후 테이블은 초기 생성 상태로 남게 된다.
--DDL 문장이므로 ROLLBACK할 수 없다.
--TRUNCATE TABLE TABLEA;  
--truncate removese all rows form a table.the operation cannot be rolled back and
--no triggers will be fired. as such, trucated is faster and deosen't use as much undo space as a delete    

--DROP
--the drop cmmand removes a table from database . all the tables' reows, indexes and privileges
--will also be removed. no dml triggers will be fired. 
--the operation cannot be rolled back.

--언두 데이터(UNDO DATE)
--언두 데이터란 데이터베이스의 데이터가 변경 될때 변경 되기 이전의 값
--오라클에서는 데이터베이스의 데이터가 변경될때 변경된 값을 저장하는 것이 아니라 변경하기 전의 값을 저장                    
--언두 데이터를 이요하면 COMMIT 이나 ROLLBACK을 하기 전에 갑자기 오류가 나서 
--비정상적인 종료 등으로 실패한 트랙젝션을 RECOVERY할 수 있다   
--TRUNCATE가 DELETE보다 작업속도가 빠르고, UNDO DATA를 만들지 않음
--TRUNCATE 역시 해당테이블이 참조되고 있으면 수행할수 없다.
--TRUNCATE는 CASCADE가 존재하지 않기 때문에 참조하는 테이블을 찾아서 FK를 제거해야한다.

/*
오라클 버젼확인방법
*/
select * from v$version;               

/*제약조건 변경*/ 
--ALTER TABLE MEMBER DROP CONSTRAINT MEMBER_JUMIN_NN  --제약조건지우고
--ALTER TABLE MEMBER MODIFY JUMIN VARCHAR2(12) CONSTRAINT MEMBER_JUMIN_NN NOT NULL --제약조건추가
--;
--                                                                                                                                                                               