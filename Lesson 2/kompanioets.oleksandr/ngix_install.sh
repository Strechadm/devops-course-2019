#!/bin/bash

if [[ $(id -u) -ne 0 ]]; 
then
  echo "Please run script as root"
  exit 1
fi

set -x

#  1. Вывести список установленных программ и проверить, если в этом списке nginx. 
	nginx_setup=$(apt list --installed | grep nginx)
#  1.1. Если он есть. Удалить и вывести текст об удалении. Также указать, какая версия была удалена. 
#  1.2. Если его нет, вывести текст что он не установлен в системе.
if [ "$nginx_setup" != "" ];
then
	echo "Check version nginx"
	nginx_version=$(nginx -v)
	echo "$Nginx verion is $nginx_version"
	apt purge -y nginx*
	echo "$nginx_version is remooved"
	exit 1
else
	#2. Добавить внешнее репо nginx: (документация на репо. http://nginx.org/en/linux_packages.html#Ubuntu) и установить nginx 1.14.2.
	echo "connect repo"
	apt update && apt install -y curl gnupg2 ca-certificates lsb-release
	echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
	echo "to import key"
	curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
	apt-key fingerprint ABF5BD827BD9BF62
	echo "Install nginx"
	apt update && apt install -y nginx=1.14.2-1~bionic
#	service nginx start
fi
	echo "nginx installed"

#  2.1. Добавить папки sites-available и sites-enabled в корень конфигурационной папки nginx. Добавить папку sites-enabled в nginx.conf. 
#	mkdir /etc/nginx/sites-available
#	mkdir /etc/nginx/sites-enabled
#	echo "folders sites-available and sites-enabled is added"
#	echo "-------------------------------------------------"
#	echo "add folder sites-enabled in nginx.conf."
#	echo "include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf
#	sed -i 'include /etc/nginx/sites-enabled/\*.conf' /etc/nginx/nginx.conf
#  2.2. Перенести файл default.conf в папку sites-available  и сделать симлинк этого файла в папку sites-enabled.
#	cp /etc/nginx/nginx.conf /etc/nginx/conf.d/default.conf
#	mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-available/
#	ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/
	cd /etc/nginx/;
	cp nginx.conf conf.d/default.conf
	mkdir sites-available/ sites-enabled/;
	sed -i 'include /etc/nginx/sites-enabled/\*.conf' /etc/nginx/nginx.conf
	# -i for line breaks
	mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-available
	#if the file in conf.d you need to use this line of code
	ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/;
#    После чего перезапустить nginx.

	service nginx restart

# 2.3. Сделать запрос к nginx и получить в результате выполнения скрипта: “Welcome to nginx!”

#	request_to_nginx=`echo wget localhost:80 -O -`
#	echo "$request_to_nginx"

	curl -X GET 127.0.0.1 | grep -o "Welcome to nginx!" | head -1

#3. Узнать и вывести PID nginx master process. Сделать это с помощью awk.

	pid_nginx=$(ps -ax | grep nginx | awk '{print $1}')

#   Результат форматировать:  “Nginx main process have a PID: {число} “
	echo "Nginx main process have a PID: $pid_nginx"
#  3.1. Так же вывести количество запущенных nginx worker process. 
#    Форматировать так же как в задании 3, но число процессов должны быть красным.
	RED=$(\033[0;31m) #set red color
	NC='\033[0m'	#set no color
	process_count=$(ps -lfC nginx | grep worker | wc -l)
	echo "Nginx worker process: ${RED}$process_count${NC}"
	echo "the end script/n______________________________"
	echo ""
