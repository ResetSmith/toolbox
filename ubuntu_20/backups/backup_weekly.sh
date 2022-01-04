#! /usr/bin/env bash

#Backup Script
#Creates two weeks of weekly backups

#variable locations
#oursites.txt=/var/backups/

#Script should be run from /var/backups/scripts
#The most current backup for a site lives in /var/backups/$domain/current
#Old backups live in /var/backups/$domain/weekly
#logs for each backup job are in /var/backups/logs/weekly

#cleans up existing temp log files
#	rm ./logs/temp/*.log

#checks if weekly log folder already exists
#if not then it creates it
	if [ ! -d ../logs/weekly ]; then
		mkdir -p ../logs/weekly
	fi	;
	if [ ! -d ../logs/temp ]; then
		mkdir -p ../logs/temp
	fi	;
	if [ ! -d ../logs/diskuse ]; then
		mkdir -p ../logs/diskuse
	fi	;

#looks for /var/backups/oursites.txt and pulls list into array
#uses array to run this script into a loop until completion
	IFS=$'\r\n' GLOBIGNORE='*' command eval  'domains=($(cat ../oursites.txt))'
		for domain in "${domains[@]}";
		do

#checks to see if a domain backup folder already exists
#if not then it creates one and the sub-folders
		if [ ! -d ../$domain/weekly ]; then
			mkdir -p ../$domain/weekly
		fi	;
		if [ ! -d ../$domain/current ]; then
			mkdir -p ../$domain/current
		fi	;
		if [ ! -d ../$domain/temp ]; then
			mkdir -p ../$domain/temp
		fi	;

#handles moving copies of weekly backups around
		if [ -d ../$domain/weekly/backup.4 ]; then
			mv ../$domain/weekly/backup.4				../$domain/temp/backup.tmp
		fi	;
		if [ -d ../$domain/weekly/backup.3 ]; then
			mv ../$domain/weekly/backup.3 				../$domain/weekly/backup.4
		fi	;
		if [ -d ../$domain/weekly/backup.2 ]; then
			mv ../$domain/weekly/backup.2				../$domain/weekly/backup.3
		fi	;
		if [ -d ../$domain/weekly/backup.1 ]; then
			mv ../$domain/weekly/backup.1				../$domain/weekly/backup.2
		fi	;

#rsync pulls copies of html and apache2 folders from target domain
#output is sent to log file number sequentially so that the order is constant in the main log
#UPDATE SSH KEYFILE WHEN MOVING
		rsync -avzhR --delete -e "ssh -i /home/ubuntu/.ssh/id_rsa" root@$domain:{/var/www/html,/etc/apache2} ../$domain/current/backup.current > ../logs/temp/$domain.log

#hard-link copies existing current backup and overwrites backup.tmp
#	rm -R ./$domain/temp/backup.tmp	-Need to watch over time and see if this line is neccesary
		cp -alf ../$domain/current/backup.current		../$domain/temp/backup.tmp
		mv ../$domain/temp/backup.tmp					../$domain/weekly/backup.1

#adds some formatting to each domain log to help keep main log readable
		sed -i '1s/^/-----'$domain'-----\n/' 			../logs/temp/$domain.log
		echo '------------------------------' >> 		../logs/temp/$domain.log
#checks disk usage and prints it to a temp file
		du -sh ../$domain/	|	sort -h	>				../logs/temp/$domain.tmp

#completes loop
		done

#concatenates the log files, timestamps them, and  cleans up unneeded tmp files
	cat ../logs/temp/*.tmp >>							../logs/diskuse/$(date +%Y%m%d).log
	echo '--------TOTAL USE' >>							../logs/diskuse/$(date +%Y%m%d).log
	du -sh /var/backups/	|	sort -h	>				../logs/temp/total.tmp
	cat ../logs/temp/total.tmp >>						../logs/diskuse/$(date +%Y%m%d).log
	rm ../logs/temp/total.tmp
	cat ../logs/temp/*.log >> 							../logs/weekly/$(date +%Y%m%d).log

#combines logs into a txt file for emails
	cat ../logs/weekly/$(date +%Y%m%d).log ../logs/diskuse/$(date +%Y%m%d).log > ../logs/temp/summary.txt

#uses mailgun to send weekly summary message to webmaster account
curl -s --user 'api_KEY_GOES_HERE' \
https://api.mailgun.net/v3/casat.org/messages \
-F from='Webmaster <EMAIL_GOES_HERE>' \
-F to='TARGET_EMAIL_GOES_HERE' \
-F subject='Weekly Backup Summary' \
-F text='Automated message generated from ' \
-F attachment=@../logs/temp/summary.txt

#add this line to the target server inside /root/.ssh/authorized_keys
#from="52.36.41.78" SSH_KEY_GOES_HERE root@ip-172-26-12-55
