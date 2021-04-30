#################   삼성 공적구제 파일 FTP 전송   ######################
#!/usr/bin/ksh

#################   백업파일 생성   ######################
DAY=`date '+%Y%m%d'`

cd /oraweb/jeus/webroot/upload/wp/ssfile
mkdir $DAY

cp  *.prn /oraweb/jeus/webroot/upload/wp/ssfile/$DAY

#################   Run FTP-Script   ######################

## FTP 전송
ftp -inv 122.200.200.55 <<ENDOFFTP
user ssftp tkatjd!00
hash
prompt off
lcd /oraweb/jeus/webroot/upload/wp/ssfile
cd /output

mput *.prn

bye
ENDOFFTP

## 전송후 파일 삭제
rm /oraweb/jeus/webroot/upload/wp/ssfile/*.prn
