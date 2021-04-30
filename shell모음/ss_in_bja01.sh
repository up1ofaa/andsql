#!/usr/bin/ksh

# Oracle Setting
export LANG=ko
export ORACLE_BASE=/oracle
export ORACLE_HOME=$ORACLE_BASE/app/product/920
export ORACLE_SID=ORADB1
export ORACLE_OWNER=oracle
export ORACLE_TERM=vt100
export TMPDIR=$ORACLE_BASE/tmp
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
export NLS_LANG=American_america.ko16KSC5601
export NLS_DATE_FORMAT='yyyy-mm-dd'
export TMPDIR=$ORACLE_BASE/tmp
export PATH=$ORACLE_HOME/bin:/usr/ucb/cc:$PATH:$ORACLE_HOME/OPatch:.
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/lib64:$ORACLE_HOME/network/lib:/usr/lib
export CLASSPATH=.:$ORACLE_HOME/jdbc/lib/classes12.jar:/oraweb/batch/lib/jdom.jar

#####   삼성 원장, 원장변동분, 수납내역 등 반영   #####

DAY=`date '+%Y%m%d'`
#DAY='20130831'
DAY2=`date '+%Y-%m-%d'`
DAYPRE=`TZ=KST+15 date +%Y%m%d`  
#DAYPRE='20110618' 

#DAY='20080217'

##########   Run Batch-Script   ##########
cd /oraweb/batch/classes

## 실적관련 : 원장변동분, 수납내역
##java ca/BCAEG $DAY
##java su/BSUCB $DAY

## 신규수관관련
java ja/BJADL $DAY   ## 삼성 정상화종결 처리 2007.04.26 추가 Y
java ja/BJADG $DAY
java ca/BCAEG $DAY  ## 원장 -> 원장변동분 순으로 변경[2008.10.13]

java su/BSUCB $DAY  ## 삼성수납 원장변동분 이후로 작업순서 변경(2008.12.31)

java ja/BJADA $DAY
java ja/BJADB $DAY
java ja/BJADC $DAY
java ja/BJADF $DAY
java ja/BJADE $DAY
java ja/BJADH $DAY
java ja/BJADI $DAY
java ja/BJADJ $DAY
java ca/BCAEE $DAY
java ja/BJADK $DAY   ##삼성 화보 만기일 수정 2007.04.26추가 
