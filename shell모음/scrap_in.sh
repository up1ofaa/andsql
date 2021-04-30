#!/usr/bin/ksh


#### Oracle Setting
export LANG=ko
export ORACLE_BASE=/oracle
export ORACLE_HOME=$ORACLE_BASE/app/product/102
export ORACLE_SID=SSORADB
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
export CLASSPATH=.:/oraweb/jeus/jeus6/lib/application/issacweb.jar:/oraweb/jeus/GateWay/stcph.jar:/oraweb/jeus/jeus6/lib/datasource/ojdbc14.jar:/oraweb/jeus/webroot/WEB-INF:/oraweb/jeus/webroot/WEB-INF/classes:/oraweb/jeus/webroot/WEB-INF/config:/oraweb/batch/classes/ca:/oraweb/batch/classes/lo:/oraweb/jeus/webroot/WEB-INF/classes/com/and/util/stcph.jar:/oraweb/jeus/webroot/WEB-INF/lib/ssli_jms.jar:/oraweb/jeus/webroot/WEB-INF/lib/com.stc.jmsis.jar:/oraweb/jeus/webroot/WEB-INF/lib/jms.jar:/oraweb/jeus/webroot/WEB-INF/lib/rts.util.jar:/oraweb/jeus/webroot/WEB-INF/lib/ssli_common.jar:/oraweb/jeus/webroot/WEB-INF/lib/log4j-1.2.11.jar:/oraweb/jeus/webroot/WEB-INF/lib/co-pjt-vo.jar:/oraweb/jeus/webroot/WEB-INF/lib/activation.jar:/oraweb/jeus/webroot/WEB-INF/lib/anyframe-enterprise-runtime-1.0.0.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-beanutils-1.8.0.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-codec-1.3.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-collections-3.2.1.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-httpclient-3.1.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-io-1.4.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-lang-2.4.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-logging-1.1.1.jar:/oraweb/jeus/webroot/WEB-INF/lib/commons-net-1.4.1-ad.jar:/oraweb/jeus/webroot/WEB-INF/lib/cos.jar:/oraweb/jeus/webroot/WEB-INF/lib/ehcache-1.6.2.jar:/oraweb/jeus/webroot/WEB-INF/lib/ezmorph-1.0.5.jar:/oraweb/jeus/webroot/WEB-INF/lib/gson-1.4-sli.jar:/oraweb/jeus/webroot/WEB-INF/lib/http_client.jar:/oraweb/jeus/webroot/WEB-INF/lib/jdom.jar:/oraweb/jeus/webroot/WEB-INF/lib/json-lib-2.2.2-jdk15.jar:/oraweb/jeus/webroot/WEB-INF/lib/log4j-1.2.15.jar:/oraweb/jeus/webroot/WEB-INF/lib/sapjco.jar:/oraweb/jeus/webroot/WEB-INF/lib/servlet.jar:/oraweb/jeus/webroot/WEB-INF/lib/sli_eai_client.jar:/oraweb/jeus/webroot/WEB-INF/lib/sli_eai_common.jar:/oraweb/jeus/webroot/WEB-INF/lib/sliframe-runtime-1.0.0.jar:/oraweb/jeus/webroot/WEB-INF/lib/smartupload.jar:/oraweb/jeus/webroot/WEB-INF/lib/co-pjt-vo2.jar:/oraweb/jeus/webroot/WEB-INF/lib/co-pjt-vo3.jar:


#####   삼성 개인회생 일괄 처리   #####

DAY=`date '+%Y%m%d'`
#DAY='20060107'
YDAY=`TZ=KST+15 date +%Y%m%d`
#YDAY='20051007'

##########   Run Batch-Script   ##########



cd /oraweb/batch/classes

#####   웹스크래핑 전일자 파일 반영   #####
java lc/BLCDB 600 $YDAY 	   
java lc/BLCDB 999 $YDAY       

java -DeaiConfigRoot=/oraweb/jeus/webroot/WEB-INF -cp $CLASSPATH lc/BLCDC $YDAY 
java -DeaiConfigRoot=/oraweb/jeus/webroot/WEB-INF -cp $CLASSPATH lc/BLCDD $YDAY 
java lc/BLCDE $YDAY 
java lc/BLCDF $YDAY 
java lc/BLCDG $YDAY 
java lc/BLCDH $YDAY 
java lc/BLCDJ $YDAY
java lc/BLCDK $YDAY 

