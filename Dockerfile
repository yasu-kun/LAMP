#以下は変更すること
#Docker
#username
#user_password

FROM ubuntu:18.04

#aptを使う時に，とってくるサーバーを日本に変えている
RUN perl -p -i.bak -e 's%https?://(?!security)[^ \t]+%http://jp.archive.ubuntu.com/ubuntu/%g' /etc/apt/sources.list

RUN apt-get update 
RUN apt-get upgrade -y
RUN apt-get install python3 python3-pip -y
RUN apt-get install -y software-properties-common
RUN apt-get install curl emacs wget sudo -y --fix-missing

# ユーザーを作成
RUN useradd -m username
# ルート権限を付与
RUN gpasswd -a username sudo
# パスワードはpassに設定(ファイル上に書くので適当なPWにする)
RUN echo 'username:user_password' | chpasswd

WORKDIR /home/username

#RUN pip3 install flask

#Nginxのインストール
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y nginx

#PHPのインストール
RUN apt-get install -y software-properties-common 
RUN apt-add-repository ppa:ondrej/php
RUN apt-get install -y php7.3-fpm php-curl php7.3-bcmath php7.3-gd php7.3-mbstring php7.3-mysql php7.3-xml php7.3-zip

#MySQL
RUN apt-get install -y mysql-server mysql-client

#Wordpressのインストール
RUN mkdir /var/www/html
RUN wget -P /var/www/html https://ja.wordpress.org/latest-ja.tar.gz 
RUN tar xvf /var/www/html/latest-ja.tar.gz -C /var/www/html
RUN chmod 775 -R /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress

#wp-config-sample.php を使ってもいいけど，新しいconfigを作る
RUN cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

RUN sed -i -e  's/index index.html index.htm index.nginx-debian.html;/#index index.html index.htm index.nginx-debian.html; \n\tindex index.html index.htm index.nginx-debian.html index.php;/g' /etc/nginx/sites-available/default

RUN /etc/init.d/nginx restart

#==========emacs==========
RUN echo "(setq make-backup-files nil)" >> ~username/.emacs
RUN echo "(set-default-coding-systems 'utf-8-unix)" >> ~username/.emacs

RUN echo "export LC_CTYPE='C.UTF-8'" >> ~username/.bashrc
RUN . ~username/.bashrc

RUN chown username:username /home/username/.emacs
