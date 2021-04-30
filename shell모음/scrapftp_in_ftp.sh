################# 웹스크래핑 파일 FTP 결과파일 수신   ######################
#!/usr/bin/ksh

#################   백업파일 생성   ######################
#DAY=`date '+%Y%m%d'`
DAY=`TZ=KST+15 date +%Y%m%d`

#################   Run FTP-Script   ######################

## FTP 전송
ftp -n -v <<EOF
open 122.200.200.36
user scrapftp scrap!36
lcd /oraweb/batch/work/in/clnt_lc
cd /RESULT
hash
prompt off
mget OUT_IC_RGGJ_*_"$DAY"*.txt
bye
EOF