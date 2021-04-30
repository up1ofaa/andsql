oracle 11g 특징/*
oracle 11g 특징


*/

--1) update select 방법 1

 UPDATE TABLEA A
 SET	(A.COL업데이트 받을 칼럼)= (SELECT B.COL업데이트 할 컬럼
 							FROM 테이블B B
 							WHERE B.NO = '특정번호' )
WHERE A.NO='특정번호'; 	

--2) update select 방법 2
 
UPDATE TABLEA A
SET (A.AA, A.BB) = (SELECT B.AA, B.BB
					FROM TABLEB B
					WHERE B.ID=A.ID )
WHERE EXISTS (SELECT B.AA, B.BB
				FROM TABLEB B
				WHERE B.ID=A.ID)											


 --주의!! Oracle 11g 이상 버전에서는 아래와 같은 힌트를 사용할 수 없다. (과거 Join Update시 사용)
--현재는 Merge into 등을 사용하여 힌트를 대체하거나 사용
--UPDATE /*+ BYPASS_UJVC*/
--
--(
--
--    SELECT A.PHONE C, B.PHONE D
--
--    FROM KIM_IMS_PERSON_BACK A, KIM_IMS_PERSON B
--
--    WHERE A.PER_ID = B.PER_ID
--
--)
--
--SET C = D;

--3)  . 조인되는 2개의 테이블은  1:1, 1:M의 관계,  Update되는 테이블은 M쪽 집합, 
--오라클 11g이후부턴 merge into사용을 권고하고  bypass_ujvc힌트는 없어졌습니다.
	 UPDATE   /*+ BYPASS_UJVC */  
		(SELECT A.AA, B.BB
		FROM TABLEA A, TABLEB B
		WHERE A.ID= B.ID )
    SET B.AA=A.AA		