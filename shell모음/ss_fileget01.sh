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
export CLASSPATH=.:$ORACLE_HOME/jdbc/lib/classes12.jar

#####   삼성 공적구제 신청 결과 파일 전송  #####

DAY=`date '+%Y%m%d'`
DATE=`expr $DATE - 1`  
DAYPRE=`TZ=KST+15 date +%Y%m%d`  
DAYPRE2=`TZ=KST+39 date +%Y%m%d`  


#DAY='20080217'

##########   Run Batch-Script   ##########
echo $DAY
echo $DAYPRE
echo $DAYPRE2


## 55번에서 60으로 파일 전송
ftp -n -v <<EOF
open 122.200.200.55
user ssftp tkatjd!00

lcd /oraweb/batch/work/in/clnt_ss
cd input

hash
prompt off

mget "$DAY"_CSV*.TXT
mget "$DAY"_G*.TXT
mget "$DAY"_I*.TXT
mget "$DAY"_J*.TXT

bye
EOF


## 55번에서 64으로 워크아웃 파일 전송
ftp -n -v <<EOF
open 122.200.200.64
user jeus wpdntm!01

lcd /oraweb/batch/work/in/clnt_ss
cd /oraweb/jeus/webroot/download/wp/sswo_file/
hash
prompt off
mput "$DAY"_CSV*.TXT
mput "$DAY"_G*.TXT

bye
EOF


## 55번에서 64으로 개인회생 파일 전송
ftp -n -v <<EOF
open 122.200.200.64
user jeus wpdntm!01

lcd /oraweb/batch/work/in/clnt_ss
cd /oraweb/jeus/webroot/download/wp/sscr_file/
hash
prompt off
mput "$DAY"_I*.TXT

bye
EOF


## 55번에서 64으로 파산면책 파일 전송
ftp -n -v <<EOF
open 122.200.200.64
user jeus wpdntm!01

lcd /oraweb/batch/work/in/clnt_ss
cd /oraweb/jeus/webroot/download/wp/ssps_file
hash
prompt off
mput "$DAY"_J*.TXT

bye
EOF



## 55번에서 65으로 워크아웃 파일 전송
ftp -n -v <<EOF
open 122.200.200.65
user jeus wpdntm!02

lcd /oraweb/batch/work/in/clnt_ss
cd /oraweb/jeus/webroot/download/wp/sswo_file/
hash
prompt off
mput "$DAY"_CSV*.TXT
mput "$DAY"_G*.TXT

bye
EOF


## 55번에서 65으로 개인회생 파일 전송
ftp -n -v <<EOF
open 122.200.200.65
user jeus wpdntm!02

lcd /oraweb/batch/work/in/clnt_ss
cd /oraweb/jeus/webroot/download/wp/sscr_file/
hash
prompt off
mput "$DAY"_I*.TXT

bye
EOF


## 55번에서 65으로 파산면책 파일 전송
ftp -n -v <<EOF
open 122.200.200.65
user jeus wpdntm!02

lcd /oraweb/batch/work/in/clnt_ss
cd /oraweb/jeus/webroot/download/wp/ssps_file
hash
prompt off
mput "$DAY"_J*.TXT

bye
EOF
