#!/usr/bin/ksh

#### Oracle Setting
export LANG=ko
export ORACLE_BASE=/oraweb/oracle
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
export PATH=$ORACLE_HOME/bin:/usr/ucb/cc:$PATH:$ORACLE_HOME/OPatch
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/oraweb/jeus/ncrm/lib/lib:/oraweb/jeus/ncrm/lib/iconv/lib/hpux32:$ORACLE_HOME/lib32:$ORACLE_HOME/lib:$ORACLE_HOME/lib64:$ORACLE_HOME/network/lib:/usr/lib
export CLASSPATH=.:/oraweb/jeus/jeus6/lib/application/issacweb.jar:/oraweb/jeus/GateWay/stcph.jar:/oraweb/jeus/jeus6/lib/datasource/ojdbc14.jar:/oraweb/jeus/webroot/WEB-INF/classes:/oraweb/batch/classes/ca:/oraweb/batch/classes/lo


#####   웹스크래핑 파일 생성   #####

DAY=`date '+%Y%m%d'`
#DAY=`TZ=KST+15 date +%Y%m%d`  
#DAY='20180105'
##롯데
LC='600'
##위탁3사
CLNT='999'

##########   Run Batch-Script   ##########

cd /oraweb/batch/classes

## 웹스크래핑 INPUT 파일 생성, 당일건
java lc/BLCDA $DAY 600
java lc/BLCDA $DAY 999







