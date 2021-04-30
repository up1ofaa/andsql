
#####   삼성 파산면책 변동분 파일 생성   #####

DAY=`date '+%Y%m%d'`
#DAY='20060525'
DAY2=`date '+%Y-%m-%d'`
#DAY2='2006-05-25'
YDAY=`TZ=KST+15 date +%Y%m%d`

##########   Run Batch-Script   ##########
cd /oraweb/batch/classes
#java wp/BWPBB $DAY
#java wp/BWPBD $DAY
#java wp/BWPBE $DAY
java wp/BWPBF $DAY


cd /oraweb/batch/work/out/clnt_ss

ftp -n -v <<EOF
open 122.200.200.55
user ssftp tkatjd!00

#sftp ss_sftp@122.200.200.55 <<EOF

cd test/output

#ren SFNXC01J.TXT SFNXC01J.TXT.$YDAY
#ren FNTBFIT8.TXT FNTBFIT8.TXT.$YDAY
#ren FNTBFIT9.TXT FNTBFIT9.TXT.$YDAY


prompt off


#mput SFNXC01J.TXT
#mput FNTBFIT8.TXT
#mput FNTBFIT9.TXT
mput AND_OVERDUE_"$DAY".TXT

bye
EOF

