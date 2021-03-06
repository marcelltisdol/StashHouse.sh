# _____ _            _     _    _                            _     
#  / ____| |          | |   | |  | |                          | |    
# | (___ | |_ __ _ ___| |__ | |__| | ___  _   _ ___  ___   ___| |__  
#  \___ \| __/ _` / __| '_ \|  __  |/ _ \| | | / __|/ _ \ / __| '_ \ 
#  ____) | || (_| \__ \ | | | |  | | (_) | |_| \__ \  __/_\__ \ | | |
# |_____/ \__\__,_|___/_| |_|_|  |_|\___/ \__,_|___/\___(_)___/_| |_|
# 2013 Marcell Tisdol | http://tisdol.com | http://eyespeak.com     
# Version 1.0/ NoSQL   

#File Backup

#Are we in root? No?
cd /                                                    
# Make our work Folders
mkdir /dbs3/
mkdir /backup/
mkdir /zips/

#Copy Everything from /vhosts/ to our work directory while excluding certain culprits
rsync -av --progress --exclude-from '/exclude-list.txt' /var/www/vhosts/ /backup/

#For Every directory, zip httpdocs and move it to the root of our work directory
/bin/echo
for dir in `/bin/ls /backup/`;
do
	cd /backup/$dir
		tar -zcvf $dir.tar.gz httpdocs
		mv $dir.tar.gz /zips
	cd /backup
done
/bin/echo

#SQL Backup

#Mount the Plesk Password
PASS="`cat /etc/psa/.psa.shadow` "

#Dump That File
mysqldump -u admin -p$PASS --all-databases > /all-database.sql
/bin/echo
mv /all-database.sql /dbs3

#Let's move /zips/ to s3
cd /
ruby /s3sync/s3sync.rb  -r  /zips/  bucket:key 
ruby /s3sync/s3sync.rb  -r  /database/  bucket:key 

/bin/echo
/bin/rm -rf /dbs3/
/bin/rm -rf /backup/
/bin/rm -rf /zips/
