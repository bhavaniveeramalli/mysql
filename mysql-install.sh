#!/bin/bash 
# Download and Install the Latest Updates for the OS
echo "input received: $1"
apt-get update && apt-get upgrade -y

# Set the Server Timezone to CST
echo "America/Chicago" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Enable Ubuntu Firewall and allow SSH & MySQL Ports
#ufw enable 
#ufw allow 3306

# Install essential packages
apt-get -y install zsh htop

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
apt-get -y install mysql-server-5.7


# Run the MySQL Secure Installation wizard
mysql_secure_installation

sudo sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
#sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
#sed -i 's/0\.0\.0\.0/0\.0\.0\.0/g' /etc/mysql/my.cnf
mysql -uroot -proot -e 'USE mysql; UPDATE `user` SET `Host`="%" WHERE `User`="root" AND `Host`="localhost"; DELETE FROM `user` WHERE `Host` != "%" AND `User`="root"; FLUSH PRIVILEGES;'

service mysql restart


MYSQL_DB_USER="root"
MYSQL_DB_PASS="root"
MYSQL_DB_NAME="testdb"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" -e "CREATE DATABASE "$MYSQL_DB_NAME"" >> /tmp/mysql.log
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "CREATE TABLE users (id int(11) NOT NULL,name varchar(255) NOT NULL,email varchar(255) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" >> /tmp/mysql.log
rc=$?
if [ $rc -eq 0 ]
then
  mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "ALTER TABLE users ADD PRIMARY KEY (id)" >>/tmp/mysql.log
  mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "ALTER TABLE users MODIFY id int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1" >>/tmp/mysql.log
  mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "COMMIT" >>/tmp/mysql.log
  mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "GRANT ALL ON *.* to 'web_user'@'0.0.0.0'" >>/tmp/mysql.log
  mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "INSERT INTO users (id,name,email) VALUES (1,'datamart','datamart@gmail.com'),(2,'hadoop','hadoop@gmail.com')" >>/tmp/mysql.log
  echo "The script ran ok"
  exit 0
else
  echo "The  script ran sucessfully" >&2
  exit 0
fi
