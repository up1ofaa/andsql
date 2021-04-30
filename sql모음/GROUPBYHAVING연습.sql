
SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ, CA01.CONT_NO, CA01.BOND_SEQ
FROM CA01BOND CA01, CA02RELN CA02, WP01WOAA WP01
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND WP01.CLNT_ID=CA02.CLNT_ID
AND WP01.CUST_ID=CA02.CUST_ID
AND WP01.CLNT_ID=CA01.CLNT_ID
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND ROWNUM <100
GROUP BY WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ, CA01.CONT_NO, CA01.BOND_SEQ
HAVING COUNT(*) >1;

SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ, WP01.LOAN_NO, CA01.CONT_NO, CA01.BOND_SEQ
FROM CA01BOND CA01, CA02RELN CA02, WP01WOAA WP01
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND WP01.CLNT_ID=CA02.CLNT_ID
AND WP01.CUST_ID=CA02.CUST_ID
AND WP01.CLNT_ID=CA01.CLNT_ID
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND WP01.CLNT_ID='001'
AND WP01.CUST_ID='14103300002'
AND WP01.SEQ='1';


SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ ,
AND ROWNUM <100
AND WP01.CLNT_ID='003'
AND WP01.CUST_ID='14012300004'
AND WP01.SEQ='1';

-- 워크아웃원장에서 같은 위탁사와 고객아이디, 순번에 2개이상의 대출번호를 가지고 있는 레코드 출력
SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ
FROM WP01WOAA WP01
WHERE 1=1
AND ROWNUM <100
GROUP BY WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ
HAVING COUNT(*) >1  ;

SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ ,WP01.LOAN_NO
FROM WP01WOAA WP01
WHERE 1=1
AND ROWNUM <100
AND WP01.CLNT_ID='003'
AND WP01.CUST_ID='14009230003'
AND WP01.SEQ='1';


SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ ,WP01.LOAN_NO
FROM CA01BOND CA01, CA02RELN CA02, WP01WOAA WP01
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND WP01.CLNT_ID=CA02.CLNT_ID
AND WP01.CUST_ID=CA02.CUST_ID
AND WP01.CLNT_ID=CA01.CLNT_ID
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND WP01.CLNT_ID='001'
AND WP01.CUST_ID='14205030002'
AND WP01.SEQ='1'
AND ROWNUM <100;



SELECT  WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ ,WP01.LOAN_NO
FROM CA01BOND CA01, CA02RELN CA02, WP01WOAA WP01
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND WP01.CLNT_ID=CA02.CLNT_ID
AND WP01.CUST_ID=CA02.CUST_ID
AND WP01.CLNT_ID=CA01.CLNT_ID
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND WP01.CLNT_ID='001'
AND WP01.CUST_ID='14205230003'
AND WP01.SEQ='1'
AND ROWNUM <100;






--GROUP BY WP01.CLNT_ID, WP01.CUST_ID, WP01.SEQ
--HAVING COUNT(*) >3;

select cust_ssno from  ca04cust
where cust_id ='14705220001';

--GmdsG+DLo1u+jvZw48dB8Q==
--select xx1.dec_varchar2_sel('GmdsG+DLo1u+jvZw48dB8Q==', 10, 'SSN')    from dual; --ca04cust ca04;

--SELECT xx1.enc_varchar2_ins('1470522000100', 10,'SSN')from dual ;      --WMKaGVFkWZIfZKKPG6GEag==


SELECT *
FROM CA02RELN CA02, CA01BOND CA01
WHERE 1=1
AND CA01.CLNT_ID=CA02.CLNT_ID
AND CA01.CONT_NO=CA02.CONT_NO
AND CA01.BOND_SEQ=CA02.BOND_SEQ
AND CA02.WKOT_STEP IS NOT NULL
AND CA02.CLNT_ID='001'
AND CA01.END_DIVI='00'
AND CA01.USE_YN=' '
AND CA02.USE_YN=' '
AND ROWNUM<30;

select * from ca02reln
where clnt_id='001'
and cont_no='02041'
and bond_seq='8670'   ;

  
/* having 뒤에 and 및 다른 조건*/
select
a.col1,
a.col2
from a
where 1=1
and a.col1='2'
group by a.col1, a.col2
having count(*)=1
and a.col2='3'
;
-- a.col1=2인 리스트가 1건이고 col2='3'인건들
-- having 뒤에 나오는 and는 group by 결과이후의 where 조건을 더 주는 의미이다    
-- 따라서 having 전에 where절에 조건을 주는것과 결과가 다를수 있음
-- 그룹바이이후에 조건이므로
-- 참조   owpdb03.owpdb03_i001  

select clnt_id                         as clnt_id
                  ,cont_no                        as cont_no
                  ,bond_seq                        as bond_seq
                  ,loan_no                        as loan_no
                  ,cust_id                         as cust_id
                  ,cust_name                    as cust_name
                  ,mnth_repy_prrm_amt            as mnth_repy_prrm_amt
from (select comm_func.f_get_code_name('PSRS_JRDT_CURT',wp20.JRDT_CURT)    as jrdt_curt     -- 법원
                         ,ca01.clnt_id                                                  as clnt_id
                         ,ca01.cont_no                                                  as cont_no
                         ,ca01.bond_seq                                                        as bond_seq       -- 채권번호
                         ,ca01.loan_no                                                    as loan_no
                         ,ca02.cust_id                                                    as cust_id     -- 고객번호
                         ,ca02.cust_name                                                as cust_name     -- 고객명
                       --  ,wb20.MNTH_REPY_PRRM_AMT                                        as MNTH_REPY_PRRM_AMT --월변제액
                         ,case when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM1) and MAX(wp21.END_YYMM1) then nvl(wb20.COND1_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                          when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM2) and MAX(wp21.END_YYMM2) then nvl(wb20.COND2_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                          when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM3) and MAX(wp21.END_YYMM3) then nvl(wb20.COND3_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                          when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM4) and MAX(wp21.END_YYMM4) then nvl(wb20.COND4_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                          when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM5) and MAX(wp21.END_YYMM5) then nvl(wb20.COND5_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                          when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM6) and MAX(wp21.END_YYMM6) then nvl(wb20.COND6_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                          else wb20.MNTH_REPY_PRRM_AMT

                         end as MNTH_REPY_PRRM_AMT

                         --,mod(p_recp_amt , nvl(wb20.MNTH_REPY_PRRM_AMT , 0 ))                as mod_mnth_repy     -- 입금액 / 월변제액 의 나머지
                         ,count(*)                                                        as cnt
                         ,max(rownum)                                                  as rownums
           from  ca01bond ca01
                 ,ca02reln ca02
                 ,wp20prab wb20
                 ,wp20praa wp20
                 ,WP21PRDB wp21
           where wp20.clnt_id  = '003'
                     and wp20.CASE_NO  = '20'||substr(p_memo , 1 , 2) ||'-'||substr(p_memo , 3 , 2)||'-'||to_number(substr(p_memo , 5))
                     and wp20.use_yn   = ' '
                     and wb20.CUST_ID  = wp20.cust_id
                     and wb20.CLNT_ID  = wp20.clnt_id
                     and wb20.SEQ      = wp20.seq
                     and wb20.use_yn   = wp20.use_yn
                     and ca02.clnt_id  = wp20.clnt_id
                     and ca02.cust_id  = wp20.cust_id
                     and ca02.use_yn   = ' '
                     and ca01.clnt_id  = ca02.clnt_id
                     and ca01.cont_no  = ca02.cont_no
                     and ca01.bond_seq = ca02.bond_seq
                     and ca01.loan_no  = wb20.loan_no
                     and ca01.inpt_date = (select max(inpt_date) from ca01bond where clnt_id = ca01.clnt_id and loan_no = ca01.loan_no and use_yn = ' ')
                     and ca01.use_yn   = ' '

                     and wp20.clnt_id = wp21.clnt_id(+)
                     and wp20.cust_id = wp21.cust_id(+)
                     and wp20.seq = wp21.seq(+)
                  group by wp20.JRDT_CURT
                          ,ca01.clnt_id
                          ,ca01.cont_no
                          ,ca01.bond_seq
                          ,ca01.loan_no
                          ,ca02.cust_id
                          ,ca02.cust_name
                          ,wb20.MNTH_REPY_PRRM_AMT

                          ,wb20.COND1_MNTH_REPY
                          ,wb20.COND2_MNTH_REPY
                          ,wb20.COND3_MNTH_REPY
                          ,wb20.COND4_MNTH_REPY
                          ,wb20.COND5_MNTH_REPY
                          ,wb20.COND6_MNTH_REPY
                   having count(*) = 1
                           --and mod(p_recp_amt , nvl(wb20.MNTH_REPY_PRRM_AMT , 0 )) = 0
                        and mod(p_recp_amt , nvl((case when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM1) and MAX(wp21.END_YYMM1) then nvl(wb20.COND1_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                                    when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM2) and MAX(wp21.END_YYMM2) then nvl(wb20.COND2_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                                    when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM3) and MAX(wp21.END_YYMM3) then nvl(wb20.COND3_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                                    when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM4) and MAX(wp21.END_YYMM4) then nvl(wb20.COND4_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                                    when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM5) and MAX(wp21.END_YYMM5) then nvl(wb20.COND5_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                                    when to_char(sysdate,'yyyymm') between MAX(wp21.STRT_YYMM6) and MAX(wp21.END_YYMM6) then nvl(wb20.COND6_MNTH_REPY,wb20.MNTH_REPY_PRRM_AMT)
                                    else wb20.MNTH_REPY_PRRM_AMT
                               end),0)) = 0


                           and comm_func.f_get_code_name('PSRS_JRDT_CURT',wp20.JRDT_CURT) like p_brch_name||'%'
                     order by rownums desc
                ) TMP



