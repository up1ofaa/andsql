/* toad pl_sql함수 
toad내의 editor에서 dbms output(disabled) 콘솔창에서
빨간버튼을 초록버튼으로 변경하여 사용할것 
*/
declare
i number:=1;
j number:=2;
k number:=3;
total  number:=10;

begin 
    DBMS_OUTPUT.ENABLE(100000);
    for i in 1..100 loop
    total:= total+i+j+k;
    end loop;
  
    DBMS_OUTPUT.PUT_LINE(total);
end;
/     
--------------------------------------------------------------------------
declare
i number:=1;
j number:=2;
k number:=3;
total  number:=10;
l_end_of_pattern_pos  PLS_INTEGER;
exp_test1 PLS_INTEGER;
exp_test2 PLS_INTEGER;
source_str varchar2(200):='경기 수원시 권선구 아자차 1길 535';
source_position  PLS_INTEGER DEFAULT 0;
match_parameter VARCHAR2(2) DEFAULT NULL;


begin 
    DBMS_OUTPUT.ENABLE(100000);
    for i in 1..100 loop
    total:= total+i+j+k;
    end loop;
    
    
    l_end_of_pattern_pos :=owa_pattern.amatch('1232kkd1ad452akak',0,'\d+', 'g');
    exp_test1:=owa_pattern.amatch(source_str, source_position, '경+','g');
    exp_test2:=owa_pattern.amatch(source_str, source_position, '\d+','g');
    
    
  
  --  DBMS_OUTPUT.PUT_LINE(l_end_of_pattern_pos);
  --  DBMS_OUTPUT.PUT_LINE(exp_test1);
     DBMS_OUTPUT.PUT_LINE(exp_test2);
end;
/
