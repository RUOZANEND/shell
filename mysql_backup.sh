#!/bin/bash

db_user="user"
db_password="password"
db_host="host"
db_names="db1 db2"
backup_path="/data/backup/db"
temp_path=${backup_path}/sql
time=$(date +"%Y-%m-%d")
db_back_log="/data/backup/db_back.log"

test ! -d ${backup_path} && mkdir -p ${backup_path}
test ! -d ${temp_path} && mkdir -p ${temp_path}
:> ${db_back_log}

mysql_backup()
{
    for db in ${db_names}
    do
        backfile=${temp_path}/${db}-${time}.sql
        echo "------ 开始备份 ${db} --------" >>${db_back_log}
        mysqldump --user=${db_user} --password=${db_password} --host=${db_host} ${db} > ${backfile} 2>>${db_back_log} 2>&1
    done

    tar -zcvf ${backup_path}/DB-${time}.tar.gz ${temp_path} 2>>${db_back_log} 2>&1
    rm -rf ${temp_path}
}

del_old_file()
{
    echo "------ 正在清理过时备份 --------" >>${db_back_log}
    find $backup_path -mtime +7 -type f |xargs rm -f
}

start_backup()
{
    echo "------ start --------" >>${db_back_log}
    mysql_backup
    del_old_file
    echo "------ end --------" >>${db_back_log}
}

start_backup
