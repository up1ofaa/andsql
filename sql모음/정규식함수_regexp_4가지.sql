/*
정규식 함수 4가지
1. regexp_like
2. regexp_substr
3. regexp_instr
4. regexp_replace
5. regexp_count

*/

select cust_id, cust_name, bond_ramt
from ca01bond
where clnt_id='003'
and (cust_name like '%임%'
 or cust_name like '%윤%')
 ;
/*
이름에 '임' 또는 '진' 또는 '윤'을 포함하는 경우
*/

select cust_id, cust_name, bond_ramt
from ca01bond
where clnt_id='003'
and regexp_like(cust_name , '(임|진|윤)')
;


/*
이름의 첫글자가 '김'으로 시작하고 끝글자가 '현' 또는 '수'로
끝나는 고객들의 이름 출력
*/

select cust_id, cust_name, bond_ramt
from ca01bond
where clnt_id='003'
and cust_name like '김%'
and (cust_name like '%현'
   or cust_name like '%수')
;

select cust_id, cust_name, bond_ramt
from ca01bond
where clnt_id='003'
and regexp_like(cust_name, '^김..+(현|수)$');
/*
^ 시작
$ 끝
| OR
. 자릿수
*/

/*
이름, 채권잔액 출력하는데 잔액이 0 대신에 *로 출력
*/
select cust_name , replace(bond_ramt, 0, '*')
from ca01bond
where clnt_id='003'
and end_divi='00'
and rownum <100;

/*
이름을 출력하는데 이름의 철자를 한칸씩 띄어서 출력
*/
select cust_name, regexp_replace(cust_name, '(.)','\1 ') nicname
from ca01bond
where clnt_id='003'
and end_divi='00'
and rownum <100;

/*
cust_name, '(.)', '\1 '
한글자마다 한칸씩 더 띄고 싶으면 regexp_replace(cust_name, '(.)','\1<여기 칸을 늘림>')
두글자마다 한칸씩 띄고 싶으면 regexp_replace(cust_name, '(..)','\1 ')

*/

select cust_name, regexp_replace(cust_name, '(..)','\1 ') nicname
from ca01bond
where clnt_id='003'
and end_divi='00'
and rownum <100;

