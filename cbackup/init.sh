#!/bin/bash

# если нет cbackup - копируем оригинальный каталог
if [ "$(ls /opt/cbackup)" ];
then
	echo -e "\033[1m cbackup is already installed \033[0m"
else
	echo -e "\033[1m cbackup copy"
        rsync -axHAX /opt/cbackup.orig/ /opt/cbackup/
	echo -e "\033[1m   - done \033[0m"
fi

# инициализируем БД mysql
if [ "$(ls /var/lib/mysql)" ];
then
	echo -e "\033[1m DB sql is already installed \033[0m"
else
	# change pass cbackup user db
	echo -e "\033[1m Change password for user 'cbackup' \033[0m"
	echo "cbackup:${CBACKUP_PASSWORD}" | chpasswd
	echo -e "\033[1m   - done \033[0m"
	echo -e "\033[1m  Initializes SQL data directory  \033[0m"
	service mysql stop
	chown -R mysql /var/lib/mysql
        /usr/bin/mysql_install_db
        service mysql start
        until mysqladmin ping; do sleep 1; done
        mysql -uroot -e "CREATE DATABASE IF NOT EXISTS cbackup CHARSET utf8 COLLATE utf8_general_ci;"
        mysql -uroot -e "CREATE USER IF NOT EXISTS 'cbackup'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
        mysql -uroot -e "GRANT USAGE ON *.* TO cbackup@localhost;"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON cbackup.* TO cbackup@localhost;"
        # mysql_secure_installation с ответами
        echo -e "\ny\ny\nabc\nabc\ny\ny\ny\ny" | ./usr/bin/mysql_secure_installation
	echo -e "\033[1m   - done \033[0m"
fi

systemctl restart cbackup
