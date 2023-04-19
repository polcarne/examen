#!/bin/bash
clear
# Amb netegem el terminal

# Declaració dels diferents colors
NORMAL='\e[0m'          # Color Base
ROJO='\e[31m'           # Color Vermell  
VERDE='\e[32m'          # Color Verd
ROJOBK='\e[41m'         # Fons Vermell
On_Purple='\033[45m'    # Fons Lila

# PART 0 - COMPROVAR QUE SOM L'USUARI ROOT I ACTUALITZACIÓ REPOSITORIS ################################################################################
echo -e "${On_Purple}SCRIPT AUTOMÀTIC PER INSTAL·LAR EL SERVIDOR KMS${NORMAL}"
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

# PART 1 - DESCÀRREGA DE KMS ################################################################################
# Creació del directori on descarregarem Wordpress 
mkdir /opt 2>/dev/null
cd /opt/ 2>/dev/null
rm -r *master* 2>/dev/null

# Descarregar l'arxiu de KMS
wget https://github.com/SystemRage/py-kms/archive/refs/heads/master.zip >/dev/null 2>&1           
if [ $? -eq 0 ];then
        echo "Arxiu d'instal·lació de KMS descarregat correctament." >>/script/registre.txt
        echo -e "${VERDE}Arxiu d'instal·lació de KMS descarregat correctament.${NORMAL}"
else
        echo  "L'arxiu de KMS no s'ha pogut descarregar.">>/script/registre.txt
        echo -e "${ROJO}L'arxiu de KMS no s'ha pogut descarregar.${NORMAL}"
        exit
fi

# Decomprimir l'arxiu de KMS
unzip master.zip >/dev/null 2>&1
if [ $? -eq 0 ]; then
        echo "Arxiu d'instal·lació de KMS descomprimit correctament." >>/script/registre.txt
        echo -e "${VERDE}Arxiu d'instal·lació de KMS descomprimit correctament.${NORMAL}"
else
        echo  "L'arxiu de KMS no s'ha pogut descomprimir.">>/script/registre.txt
        echo -e "${ROJO}L'arxiu de KMS no s'ha pogut descomprimir.${NORMAL}"
        exit
fi

# Crear carpeta (/srv/kms)
mkdir /srv/kms/

# Moure el contingut de KMS al directori html
mv py-kms-master/* /srv/kms/ 2>/dev/null
if [ $? -eq 0 ];then
        echo "Contigut de KMS mogut al directori /srv/kms correctament." >>/script/registre.txt
        echo -e "${VERDE}Contigut de KMS mogut al directori /srv/kms correctament.${NORMAL}"
else
        echo  "Contigut de KMS no mogut al directori /srv/kms correctament.">>/script/registre.txt
        echo -e "${ROJO}Contigut de KMS no mogut al directori /srv/kms correctament.${NORMAL}"
        exit
fi

# Instal·lació del paquet python3-tk
if [ $(dpkg-query -W -f='${Status}' 'python3-tk' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "python3-tk no està instal·lat." >>/script/registre.txt
        echo "python3-tk no està instal·lat."
        apt-get -y install python3-tk >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet python3-tk instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet python3-tk instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet python3-tk no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet python3-tk no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet python3-tk ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet python3-tk ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet python3-pip
if [ $(dpkg-query -W -f='${Status}' 'python3-pip' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "python3-pip no està instal·lat." >>/script/registre.txt
        echo "python3-pip no està instal·lat."
        apt-get -y install python3-pip >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet python3-pip instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet python3-pip instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet python3-pip no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet python3-pip no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet python3-pip ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet python3-pip ja està instal·lat.${NORMAL}"
fi

# Instal·lació del paquet tzlocal pysqlite3
pip3 install tzlocal pysqlite3 2>&1
# No podem comprovar si s'ha insta·lat bé o no perquè surt un error per defecte.

# Instal·lació del paquet net-tools 
if [ $(dpkg-query -W -f='${Status}' 'net-tools ' 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "net-tools  no està instal·lat." >>/script/registre.txt
        echo "net-tools  no està instal·lat."
        apt-get -y install net-tools  >/dev/null 2>&1
        if [ $? -eq 0 ];then
                echo "Paquet net-tools instal·lat correctament." >>/script/registre.txt
                echo -e "${VERDE}Paquet net-tools instal·lat correctament.${NORMAL}"
        else
                echo -e "${ROJO}El paquet net-tools no s'ha instal·lat correctament.${NORMAL}" >>/script/registre.txt
                echo -e "${ROJO}El paquet net-tools no s'ha instal·lat correctament.${NORMAL}"
                exit
        fi
else
        echo -e "${VERDE}El paquet net-tools ja està instal·lat.${NORMAL}" >>/script/registre.txt
        echo -e "${VERDE}El paquet net-tools ja està instal·lat.${NORMAL}"
fi

# Hem de canviar de terminal, terminal tty2
chvt 2
if [ $? -eq 0 ];then
        echo "Terminal canviat correctament." >>/script/registre.txt
        echo -e "${VERDE}Terminal canviat correctament.${NORMAL}" >/dev/tty1
else
        echo -e "${ROJO}Terminal no canviat correctament.${NORMAL}" >>/script/registre.txt
        echo -e "${ROJO}Terminal no canviat correctament.${NORMAL}" >/dev/tty1
        exit
fi

## Accedir a la carpeta /srv
#cd /srv/kms/py-kms/ > 2>/dev/null
# No cal accedir a la carpeta, col·loquem la ruta sencera
# Executem l'arxiu de KMS desde el terminal 2 perquè funcioni desde el terminal 1
python3 /srv/kms/py-kms/pykms_Server.py >/dev/tty1

# Inserir el text a l'arxiu kms.service
echo -e "[Unit]" > /etc/systemd/system/kms.service
echo -e "After=network.target" >> /etc/systemd/system/kms.service
echo -e "[Service]" >> /etc/systemd/system/kms.service
echo -e "ExecStart=/usr/bin/python3 /srv/kms/py-kms/pykms_Server.py" >> /etc/systemd/system/kms.service
echo -e "[Install]" >> /etc/systemd/system/kms.service
echo -e "WantedBy=multi-user.target" >> /etc/systemd/system/kms.service

# Arrencar el servidor KMS
systemctl start kms.service >/dev/null 2>&1
# Habilitar el servidor KMS de forma automàtica
systemctl enable kms.service >/dev/null 2>&1

# FI
