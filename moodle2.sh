#!/bin/bash
clear
# Amb netegem el terminal

# Declaració dels diferents colors
NORMAL='\e[0m'          # Color Base
ROJO='\e[31m'           # Color Vermell  
VERDE='\e[32m'          # Color Verd
ROJOBK='\e[41m'         # Fons Vermell
On_Purple='\033[45m'    # Fons Lila

# PART 0 - COMPROVAR QUE SOM L'USUARI ROOT + ACTUALITZAR REPOSITORIS ################################################################################
echo -e "${On_Purple}SCRIPT AUTOMÀTIC PER INSTAL·LAR EL SERVIDOR MOODLE${NORMAL}"
#Comprovació de l’usuari
#Aquest condicional utilitza la comanda “whoami”, serveix per identificar l’usuari actual
#Compara la variable si es == a “root” en cas afirmatiu escriu “Ets root.” i en cas negatiu et diu que no ho ets i surt de l’script
if [ $(whoami) == "root" ]; then
        echo -e "${VERDE}Ets root.${NORMAL}"
        # Color verd
else
        echo -e "${ROJO}No ets root.${NORMAL}"
        # Color vermell
        echo -e "${ROJOBK}No tens permisos per executar aquest script, només pots ser executat per l'usuari root.${NORMAL}"
        # Fons vermell
        # Exit fa que sortim de l'script.
        exit
fi

# Creació del document registre.txt
mkdir /script 2>/dev/null
touch /script/registre.txt 2>/dev/null

# Actualització dels repositoris
apt-get update >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Repositoris de Linux actualitzats correctament." >>/script/registre.txt
        echo -e "${VERDE}Repositoris de Linux actualitzats correctament.${NORMAL}"
else
        echo -e "${ROJO}No s'han pogut actualitzat els repositoris de Linux, potser no tens internet.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}No s'han pogut actualitzat els repositoris de Linux, potser no tens internet.${NORMAL}"
        exit
fi

# PART 1 - PAQUET LAMP ################################################################################
#Instal.lació paquet Apache2
if [ $(dpkg-query -W -f='${Status}' 'apache2' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
# Si no trobem Apache2, avisem que no està instal·lat
        echo "Apache2 no està instal·lat." >>/script/registre.txt
        echo "Apache2 no està instal·lat."
        apt-get -y install apache2 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Apache2 instal.lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Apache2 instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}Apache2 no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}Apache2 ja està instal.lat.${NORMAL}"
fi

#Instal.lació paquet MariaDB-Server
if [ $(dpkg-query -W -f='${Status}' 'mariadb-server' 2>/dev/null | grep -c "ok installed") -eq 0 ];then 
        echo "MariaDB-Server no està instal·lat" >>/script/registre.txt
        echo "MariaDB-Server no està instal·lat"
        apt-get -y install mariadb-server >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "MariaDB-Server instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}MariaDB-Server instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}MariaDB-Server no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}MariaDB-Server no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
       echo -e "${VERDE}MariaDB-Server ja està instal·lat.${NORMAL}" >>/script/registre.txt
       echo -e "${VERDE}MariaDB-Server ja està instal·lat.${NORMAL}"
fi

#Instal.lació paquet PHP
if [ $(dpkg-query -W -f='${Status}' 'php' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
# Si no trobem PHP, avisem que no està instal·lat
        echo "PHP no està instal·lat." >>/script/registre.txt
        echo "PHP no està instal·lat."
        apt-get -y install php >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "PHP instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}PHP instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}PHP no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}PHP no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}PHP ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}PHP ja està instal·lat.${NORMAL}"
fi

#Instal.lació paquet PHP-MySQL
if [ $(dpkg-query -W -f='${Status}' 'php-mysql' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
# No podem trobar el paquet 'php-mysql' amb $(dpkg-query -W -f='${Status}' 'mariadb-server'
# Si no trobem PHP-MYSQL, avisem que no està instal·lat
        echo "PHP-MySQL no està instal·lat." >>/script/registre.txt
        echo "PHP-MySQL no està instal·lat."
# Com que no podem comprovar si està instal·lat o no PHP-MySQL, l'instal·larem i si no hi ha errors, 
# voldrar dir que s'ha instal·lat encara que podria ja estar instal·lat abans.
        apt-get -y install php-mysql >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "PHP-MySQL instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}PHP-MySQL instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}PHP-MySQL no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}PHP-MySQL no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}PHP-MySQL ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}PHP-MySQL ja està instal·lat.${NORMAL}"
fi

# PART 2 - BASE DE DADES ################################################################################
#Comprovem si la base de dades moodle existeix
dbname="moodle"
if [ -d "/var/lib/mysql/$dbname" ]; then
        echo -e "${VERDE}La base de dades moodle existeix.${NORMAL}"
else
        echo -e "La base de dades no existeix."
        mysql -u root -e "CREATE DATABASE moodle;"
        mysql -u root -e "CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'moodle';"
        mysql -u root -e "GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost';"
        mysql -u root -e "FLUSH PRIVILEGES;"
        mysql -u root -e "exit"
        # Tornem a comprovar si existeix per assegurar-nos que s'ha creat.
        if [ -d "/var/lib/mysql/$dbname" ]; then
                echo -e "${VERDE}La base de dades roundcube s'ha creat correctament.${NORMAL}"
        else
                echo -e "${ROJO}Malauradament, la base de dades no s'ha creat correctament.${NORMAL}"
                exit
        fi
fi

# PART 3 - ACTUALITZAR MARIADB-SERVER ################################################################################
# Actualitzar MariaDB-Server
#Instalación del software-propierties-common 
if [ $(dpkg-query -W -f='${Status}' 'software-properties-common' 2>/dev/null | grep -c "ok installed") -eq 0 ];then 
	    echo "software-properties-common no está instal·lat."  >>/script/registre.txt
	    echo "software-properties-common no está instal·lat." 
	    apt-get -y install software-properties-common  >/dev/null 2>&1
	    if [ $? -eq 0 ]; then
	            echo "software-properties-common instal·lat correctament." >>/script/registre.txt
		          echo -e "${VERDE}software-properties-common instal·lat correctament.${NORMAL}"
	    else
		          echo "software-properties-common no s'ha instal·lat correctament." >>/script/registre.txt
		          echo -e "${ROJO}software-properties-common no s'ha instal·lat correctament.${NORMAL}"
	            exit
      fi
else
	    echo -e "${VERDE}software-properties-common ja està instal·lat${NORMAL}" 
fi

#Instalación del dirmngr
if [ $(dpkg-query -W -f='${Status}' 'dirmngr' 2>/dev/null | grep -c "ok installed") -eq 0 ];then 
	    echo "dirmngr no está instal·lat."  >>/script/registre.txt
	    echo "dirmngr no está instal·lat." 
	    apt-get -y install dirmngr  >/dev/null 2>&1
	    if [ $? -eq 0 ]; then
	            echo "dirmngr instal·lat correctament." >>/script/registre.txt
		          echo -e "${VERDE}dirmngr instal·lat correctament.${NORMAL}"
	    else
		          echo "dirmngr no s'ha instal·lat correctament." >>/script/registre.txt
		          echo -e "${ROJO}dirmngr no s'ha instal·lat correctament.${NORMAL}"
	            exit
      fi
else
	    echo -e "${VERDE}dirmngr ja està instal·lat${NORMAL}" 
fi

#Inserción de la clave
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "La clau s'ha col·locat correctament." >>/script/registre.txt
        echo -e "${VERDE}La clau s'ha col·locat correctament${NORMAL}"
else
        echo -e "${ROJO}La clau no s'ha col·locat correctament${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}La clau no s'ha col·locat correctament${NORMAL}"
        exit
fi

#Repositorio del mariadb
add-apt-repository 'deb [arch=amd64] http://mirror.rackspace.com/mariadb/repo/10.4/debian buster main' >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "El repositori de mariadb s'ha col·locat correctament." >>/script/registre.txt
        echo -e "${VERDE}El repositori de mariadb s'ha col·locat correctament${NORMAL}"
else
        echo -e "${ROJO}El repositori de mariadb no s'ha col·locat correctament${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}El repositori de mariadb no s'ha col·locat correctament${NORMAL}"
        exit
fi

#Actualización de los paquetes
apt-get update >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Repositoris de Linux actualitzats correctament." >>/script/registre.txt
        echo -e "${VERDE}Repositoris de Linux actualitzats correctament.${NORMAL}"
else
        echo -e "${ROJO}No s'han pogut actualitzat els repositoris de Linux, potser no tens internet.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}No s'han pogut actualitzat els repositoris de Linux, potser no tens internet.${NORMAL}"
        exit
fi

#Instal.lació paquet MariaDB-Server
if [ $(dpkg-query -W -f='${Status}' 'mariadb-server' 2>/dev/null | grep -c "ok installed") -eq 0 ];then 
        echo "MariaDB-Server no està instal·lat" >>/script/registre.txt
        echo "MariaDB-Server no està instal·lat"
        apt-get -y install mariadb-server >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "MariaDB-Server instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}MariaDB-Server instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}MariaDB-Server no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}MariaDB-Server no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
       echo -e "${VERDE}MariaDB-Server ja està instal·lat.${NORMAL}" >>/script/registre.txt
       echo -e "${VERDE}MariaDB-Server ja està instal·lat.${NORMAL}"
fi

# Reinicar Apache2
systemctl restart apache2
if [ $? -eq 0 ];then
        echo "Apache reiniciat correctament." >>/script/registre.txt
        echo -e "${VERDE}Apache reiniciat correctament.${NORMAL}"
else
        echo  "Apache no reiniciat correctament.">>/script/registre.txt
        echo -e "${ROJO}Apache no reiniciat correctament.${NORMAL}"
        exit
fi

# PART 4 - DEPENDÈNCIES DE PHP ################################################################################
# Repositoris de PHP lsb-release, apt-transport-https i ca-certificate
apt -y install lsb-release apt-transport-https ca-certificates >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Repositoris de PHP lsb-release, apt-transport-https i ca-certificates instal·lats correctament." >>/script/registre.txt
        echo -e "${VERDE}Repositoris de PHP lsb-release, apt-transport-https i ca-certificates instal·lats correctament.${NORMAL}"
else
        echo -e "${ROJO}Repositoris de PHP lsb-release, apt-transport-https i ca-certificates no instal·lats correctament.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}Repositoris de PHP lsb-release, apt-transport-https i ca-certificates no instal·lats correctament.${NORMAL}"
        exit
fi

# Paquet apt.gpg de PHP
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Paquet apt.gpg de PHP instal·lat correctament." >>/script/registre.txt
        echo -e "${VERDE}Paquet apt.gpg de PHP instal·lat correctament.${NORMAL}"
else
        echo -e "${ROJO}Paquet apt.gpg de PHP no instal·lat correctament.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}Paquet apt.gpg de PHP no instal·lat correctament.${NORMAL}"
        exit
fi

# Llistats de paquets de PHP
echo "deb https://packages.sury.org/php/ $( lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Llistat de paquets de PHP actualitzats." >>/script/registre.txt
        echo -e "${VERDE}Llistat de paquets de PHP actualitzats.${NORMAL}"
else
        echo -e "${ROJO}Llistat de paquets de PHP no actualitzats.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}Llistat de paquets de PHP no actualitzats.${NORMAL}"
        exit
fi

# Actualització dels repositoris
apt-get update >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Repositoris de Linux actualitzats correctament." >>/script/registre.txt
        echo -e "${VERDE}Repositoris de Linux actualitzats correctament.${NORMAL}"
else
        echo -e "${ROJO}No s'han pogut actualitzat els repositoris de Linux, potser no tens internet.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}No s'han pogut actualitzat els repositoris de Linux, potser no tens internet.${NORMAL}"
        exit
fi

# Instal·lar php7.4
if [ $(dpkg-query -W -f='${Status}' 'php7.4' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "PHP 7.4 no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 no està instal·lat."
        apt-get -y install php7.4 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Instal·lació correcta de PHP 7.4." >>/script/registre.txt
                echo -e "${VERDE}Instal·lació correcta de PHP 7.4.${NORMAL}"
        else
                echo -e "${ROJO}Instal·lació errònea de PHP 7.4.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}Instal·lació errònea de PHP 7.4.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}PHP7.4 ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}PHP7.4 ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-mysql
if [ $(dpkg-query -W -f='${Status}' 'php7.4-mysql' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "PHP 7.4 MySQL no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 MySQL no està instal·lat."
        apt-get -y install php7.4-mysql >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "PHP 7.4 MySQL instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}PHP 7.4 MySQL instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}PHP 7.4 MySQL no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}PHP 7.4 MySQL no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}PHP 7.4 MySQL ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}PHP 7.4 MySQL ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-dom
#if [ $(dpkg-query -W -f='${Status}' 'php7.4-dom' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
#        echo "PHP 7.4 dom no està instal·lat." >>/script/registre.txt
#        echo "PHP 7.4 dom no està instal·lat."
        apt-get -y install php7.4-dom >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Paquet php7.4-dom instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-dom instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-dom no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-dom no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
#else
#        echo -e "${VERDE}El paquet php7.4-dom ja està instal·lat.${NORMAL}" >>/script/registre.txt
#        echo -e "${VERDE}El paquet php7.4-dom ja està instal·lat.${NORMAL}"
#fi

# Instal·lació del paquet php7.4-simplexml
#if [ $(dpkg-query -W -f='${Status}' 'php7.4-simplexml' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
#        echo "PHP 7.4 simplexml no està instal·lat." >>/script/registre.txt
#        echo "PHP 7.4 simplexml no està instal·lat."
        apt-get -y install php7.4-simplexml >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Paquet php7.4-simplexml instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-simplexml instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}php7.4-simplexml no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}php7.4-simplexml no s'ha instal·lat.${NORMAL}"
                exit
        fi
#else
#        echo -e "${VERDE}El paquet php7.4-simplexml ja està instal·lat.${NORMAL}" >>/script/registre.txt
#        echo -e "${VERDE}El paquet php7.4-simplexml ja està instal·lat.${NORMAL}"
#fi

# Instal·lació del paquet php7.4-curl
if [ $(dpkg-query -W -f='${Status}' 'php7.4-curl' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "PHP 7.4 curl no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 curl no està instal·lat."
        apt-get -y install php7.4-curl >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Paquet php7.4-curl instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-curl instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-curl no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}php7.4-curl no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-curl ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-curl ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-gd
if [ $(dpkg-query -W -f='${Status}' 'php7.4-gd' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "PHP 7.4 gd no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 gd no està instal·lat."
        apt-get -y install php7.4-gd >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Paquet php7.4-gd instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-gd instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-gd no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-gd no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-gd ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-gd ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-intl
if [ $(dpkg-query -W -f='${Status}' 'php7.4-intl' 2>/dev/null | grep -c "ok installed") -eq 0 ];then
        echo "PHP 7.4 intl no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 intl no està instal·lat."
        apt-get -y install php7.4-intl >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "Paquet php7.4-intl instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-intl instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-intl no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-intl no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-intl ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-intl ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-ldap
if [ $(dpkg-query -W -f='${Status}' 'php7.4-ldap' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "PHP 7.4 ldap no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 ldap no està instal·lat."
        apt-get -y install php7.4-ldap >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet php7.4-ldap instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-ldap instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-ldap no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-ldap no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-ldap ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-ldap ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-zip
if [ $(dpkg-query -W -f='${Status}' 'php7.4-zip' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "PHP 7.4 zip no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 zip no està instal·lat."
        apt-get -y install php7.4-zip >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet php7.4-zip instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-zip instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet hp7.4-zip no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-zip no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-zip ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-zip ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-bz2
if [ $(dpkg-query -W -f='${Status}' 'php7.4-bz2' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "PHP 7.4 bz2 no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 bz2 no està instal·lat."
        apt-get -y install php7.4-bz2 >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet php7.4-bz2 instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-bz2 instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-bz2 no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-bz2 no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-bz2 ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-mbstring
if [ $(dpkg-query -W -f='${Status}' 'php7.4-mbstring' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "PHP 7.4 mbstring no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 mbstring no està instal·lat."
        apt-get -y install php7.4-mbstring >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet php7.4-mbstring instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-mbstring instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-mbstring no s'ha instal·lat.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-mbstring no s'ha instal·lat.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-mbstring ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-mbstring ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet php7.4-imagick
if [ $(dpkg-query -W -f='${Status}' 'php7.4-imagick' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "PHP 7.4 imagick no està instal·lat." >>/script/registre.txt
        echo "PHP 7.4 imagick no està instal·lat."
        apt-get -y install php7.4-imagick >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet php7.4-imagick instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet php7.4-imagick instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet php7.4-imagick no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet php7.4-imagick no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet php7.4-imagick ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet php7.4-imagick ja està instal·lat.${NORMAL}"
fi

# Les funciones a2dismod y a2enmod no funcionen quan actualitzem els repositoris per instal·lar PHP7.4 (Si la màquina té interfície gràfica)
# Deshabilitar PHP 7.3
a2dismod php7.3 >/dev/null 2>&1
if [ $? -eq 0 ];then
        echo "PHP 7.3 deshabilitat correctament." >>/script/registre.txt
        echo -e "${VERDE}PHP 7.3 deshabilitat correctament.${NORMAL}"
else
        echo -e "${ROJO}PHP 7.3 no s'ha pogut deshabilitar correctament.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}PHP 7.3 no s'ha pogut deshabilitar correctament.${NORMAL}"
        exit
fi

# Habilitar PHP 7.4
a2enmod php7.4 >/dev/null 2>&1
if [ $? -eq 0 ];then
        echo "PHP 7.4 habilitat correctament." >>/script/registre.txt
        echo -e "${VERDE}PHP 7.4 habilitat correctament.${NORMAL}"
else
        echo -e "${ROJO}PHP 7.4 no s'ha pogut habilitar correctament.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}PHP 7.4 no s'ha pogut habilitar correctament.${NORMAL}"
        exit
fi

# Comprovar PHP 7.4
#valor=$(php --version | grep -c "PHP 7.4")
#if [ $valor -eq 0 ]; then
#        echo -e "${ROJO}La versió de PHP que s'està utilitzant no és la 7.4.${NORMAL}" >>/script/registre.txt
#        echo -e "${ROJO}La versió de PHP que s'està utilitzant no és la 7.4.${NORMAL}"
#        exit
#else
#        echo -e "${VERDE}La versió de PHP que s'està utilitzant és la 7.4.${NORMAL}" >>/script/registre.txt
#        echo -e "${VERDE}La versió de PHP que s'està utilitzant és la 7.4.${NORMAL}"
#fi

# PART 5 - DESCÀRREGA DE MOODLE ################################################################################
# Creació del directori on descarregarem Roundcube
mkdir /opt 2>/dev/null
cd /opt/ 2>/dev/null
rm -r moodle* 2>/dev/null

# Descarregar l'arxiu de Moodle
wget https://download.moodle.org/download.php/direct/stable401/moodle-latest-401.tgz >/dev/null 2>&1           
if [ $? -eq 0 ];then
        echo "Arxiu d'instal·lació de Moodle descarregat correctament." >>/script/registre.txt
        echo -e "${VERDE}Arxiu d'instal·lació de Moodle descarregat correctament.${NORMAL}"
else
        echo  "L'arxiu de Moodle no s'ha pogut descarregar.">>/script/registre.txt
        echo -e "${ROJO}L'arxiu de Moodle no s'ha pogut descarregar.${NORMAL}"
        exit
fi

# Decomprimir l'arxiu de Moodle
tar -xvzf moodle-latest-401.tgz >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Arxiu d'instal·lació de Moodle descomprimit correctament." >>/script/registre.txt
        echo -e "${VERDE}Arxiu d'instal·lació de Moodle descomprimit correctament.${NORMAL}"
else
        echo  "L'arxiu de Moodle no s'ha pogut descomprimir.">>/script/registre.txt
        echo -e "${ROJO}L'arxiu de Moodle no s'ha pogut descomprimir.${NORMAL}"
        exit
fi

# PART 6 - CANVI DE PERMISOS ################################################################################
# Esborrar contingut al directori html
rm -r /var/www/html/* 2>/dev/null

# Moure el contingut de RoundCube al directori html
mv moodle/ /var/www/html/ 2>/dev/null
if [ $? -eq 0 ];then
        echo "Contigut de Moodle mogut al directori html correctament." >>/script/registre.txt
        echo -e "${VERDE}Contigut de Moodle mogut al directori html correctament.${NORMAL}"
else
        echo  "El contigut de Moodle no s'ha mogut al directori html correctament.">>/script/registre.txt
        echo -e "${ROJO}El contigut de Moodle no s'ha mogut al directori html correctament.${NORMAL}"
        exit
fi

# Crear carpeta moodle-data
mkdir /var/www/moodledata 2>/dev/null
if [ $? -eq 0 ];then
        echo "Carpeta Moodle Data creada correctament." >>/script/registre.txt
        echo -e "${VERDE}Carpeta Moodle Data creada correctament.${NORMAL}"
else
        echo  "Carpeta Moodle Data no creada correctament.">>/script/registre.txt
        echo -e "${ROJO}Carpeta Moodle Data no creada correctament.${NORMAL}"
        exit
fi

# Assignar permisos a www-data
chown -R www-data:www-data /var/www/ 2>/dev/null
if [ $? -eq 0 ];then
        echo "Permisos assignats a www-data correctament." >>/script/registre.txt
        echo -e "${VERDE}Permisos assignats a www-data correctament.${NORMAL}"
else
        echo  "Els permisos no s'han assignat a www-data correctament.">>/script/registre.txt
        echo -e "${ROJO}Els permisos no s'han assignat a www-data correctament.${NORMAL}"
        exit
fi

# Assignar permisos a tot el directori html
chmod -R 755 /var/www/ 2>/dev/null
if [ $? -eq 0 ];then
        echo "Permisos assignats a tot el directori correctament." >>/script/registre.txt
        echo -e "${VERDE}Permisos assignats a tot el directori  correctament.${NORMAL}"
else
        echo  "No s'han assignat els permisos al directori  correctament.">>/script/registre.txt
        echo -e "${ROJO}No s'han assignat els permisos al directori correctament.${NORMAL}"
        exit
fi

# Reinicar Apache2
systemctl restart apache2
if [ $? -eq 0 ];then
        echo "Apache reiniciat correctament." >>/script/registre.txt
        echo -e "${VERDE}Apache reiniciat correctament.${NORMAL}"
        echo -e "${On_Purple}PER ACCEDIR A MOODLE: http://127.0.0.1:port/installer/ AL NAVEGADOR${NORMAL}"
else
        echo  "Apache no reiniciat correctament.">>/script/registre.txt
        echo -e "${ROJO}Apache no reiniciat correctament.${NORMAL}"
        exit
fi