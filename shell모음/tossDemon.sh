################# 웹스크래핑 파일 FTP 전송   ######################
#!/usr/bin/ksh

DAY=`date '+%Y%m%d'`

#################   Run FTP-Script   ######################

## FTP 전송
ftp -n -v <<EOF
open 122.200.200.36
user scrapftp scrap!36
lcd /oraweb/batch/work/out/clnt_lc
cd /ECFS/data/bzin
hash
prompt off
mput IN_IC_RGGJ_"$DAY".txt
bye
EOF

