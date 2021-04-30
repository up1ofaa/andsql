SELECT *
 FROM ALL_PROCEDURES
WHERE OBJECT_NAME = 'OCEAB01'
 ;

select * from all_source where name = upper('OCEAB01');
;

select  name , type, line, replace(replace(replace(A.text,chr(13),' '),chr(10),' '),chr(9),' ') text from all_source a where name = upper('OCEAB01');
;

/*패키지 에러확인하기*/
select * FROM all_errors
 where type ='PACKAGE BODY'
  AND NAME='BTOIN01'
