# DBBackup cron
## A kubernetes cronjob to take backup from the DB and upload it on the backup server.
### ENVs:
+ **DB_USER**: DataBase username.
+ **DB_PASS**: DataBase password.
+ **DB_HOST**: DataBase hostname.
+ **DB_NAME**: DataBase name.
+ **BACKUP_SERVER**: Backup destication server.
+ **REMOTE_FILE**: Backup file name and directory on Backup server.
+ **FILE_NAME**: Local file name.

### Note:
You should add backup server ssh keys to the container whit mounting these.




