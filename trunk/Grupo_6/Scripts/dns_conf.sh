#!/bin/bash 
#############################################################
# 75.43 - Introduccion a los Sistemas Distribuidos          #
# Trabajo Practico Final. Grupo 6                           #
# Script de configuracion de DNS.                           #
#############################################################

DEBUG=1 
 
H17_J=10.43.9.4 
 
BIND_DIR="/etc/bind" 
ROOT_DIR="./root" 
SLAVE_DIR="./slave"
SANRAFAEL_DIR="./sanrafael" 
OTROS_DIR="./otros" 
 
ROOT_DNS=$H17_J 
 
function Log(){ 
	if [ $DEBUG = 1 ]; then 
		echo "[DEBUG] - $1" 
	fi 
} 
 
 
function BackupDNSConf() { 
 
	Log "Parando servicio bind9..." 
	/etc/init.d/bind9 stop 
	Log "Parando rndc..." 
	rndc stop 
 
	if [ -d $BIND_DIR.grupo6.bkp ]; then  
		rm -rf $BIND_DIR.grupo6.bkp 
		Log "El directorio $BIND_DIR.grupo6.bkp ya existe. Borrando..." 
	fi		 
	Log "Ejecutando: mv -f $BIND_DIR $BIND_DIR.grupo6.bkp" 
	mv -f $BIND_DIR $BIND_DIR.grupo6.bkp 
	mkdir $BIND_DIR 
	Log "Se ha creado un backup del directorio $BIND_DIR como $BIND_DIR.grupo6.bkp" 
 
} 
 
function ConfigurarDNS() { 
	Log "Configurando servidor DNS..."	 
	if [ ! -f /etc/hosts.bkp ]; then  
		mv /etc/hosts /etc/hosts.bkp 
		Log "Se ha creado un backup del archivo /etc/hosts -> /etc/hosts.bkp" 
	fi 
	Log "Ejecutando: echo 127.0.0.1	localhost > /etc/hosts"	 
	echo "127.0.0.1	localhost" > /etc/hosts 
	 
	if [ ! -f /etc/resolv.conf.bkp ]; then  
		mv /etc/resolv.conf /etc/resolv.conf.bkp 
		Log "Se ha creado un backup del archivo /etc/resolv.conf -> /etc/resolv.conf.bkp" 
	fi 

	chmod 777 /etc/resolv.conf 
	RESOLVCONF=`cat /etc/resolv.conf` 
	Log "El contenido de /etc/resolv.conf es: $RESOLVCONF" 
 
	Log "Ejecutando: cp -f rndc.conf /etc/rndc.conf" 
	cp -f rndc.conf $BIND_DIR/rndc.conf 
	Log "Ejecutando: cp -f rndc.key /etc/rndc.key" 
	cp -f rndc.key $BIND_DIR/rndc.key
 
	Log "Seteando permisos a /etc/bind" 
	chmod 777 /etc/bind/* 
	chmod 777 /etc/bind 
	Log "Borrando /etc/cache/bind" 
	rm -rf /var/cache/bind 
	Log "Copiando archivo /etc/default/bind9" 
	cp -f bind9 /etc/default/bind9 
	Log "Iniciando servicio bind..." 
	/etc/init.d/bind9 restart 
} 
 
 
function main() {  
 
	case "$1" in 
			ROOT) 
			   	BackupDNSConf		    	 
			    cp -f $ROOT_DIR/named.conf $BIND_DIR/named.conf 
				cp -f $ROOT_DIR/cuyo.db $BIND_DIR/cuyo.db 
				cp -f $ROOT_DIR/6.94.10.db $BIND_DIR/6.94.10.db 
				cp -f $ROOT_DIR/65.15.10.db $BIND_DIR/65.15.10.db 
				ConfigurarDNS 
			;; 
 
			SLAVE) 
		    	BackupDNSConf		    	 
		    	cp -f $SLAVE_DIR/named.conf $BIND_DIR/named.conf 
				cp -f $SLAVE_DIR/cuyo.db $BIND_DIR/cuyo.db 
				cp -f $SLAVE_DIR/6.94.10.db $BIND_DIR/6.94.10.db 
				cp -f $SLAVE_DIR/65.15.10.db $BIND_DIR/65.15.10.db 
				ConfigurarDNS 
			;; 
			
			SANRAFAEL) 
				BackupDNSConf 
			    	cp -f $SANRAFAEL_DIR/named.conf $BIND_DIR/named.conf		    					 
			    	cp -f $SANRAFAEL_DIR/sanrafael.db $BIND_DIR/sanrafael.db 
			    	cp -f $SANRAFAEL_DIR/5.94.10.db $BIND_DIR/5.94.10.db 
			    	cp -f $SANRAFAEL_DIR/128-28.6.94.10.db $BIND_DIR/128-28.6.94.10.db
			    	cp -f $SANRAFAEL_DIR/192-26.6.94.10.db $BIND_DIR/192-26.6.94.10.db
			    	cp -f $SANRAFAEL_DIR/1-32.65.15.10.db $BIND_DIR/1-32.65.15.10.db
			    	cp -f $SANRAFAEL_DIR/128-25.65.15.10.db $BIND_DIR/128-25.65.15.10.db
				ConfigurarDNS 
			;; 
 
			OTROS) 
			    	BackupDNSConf 
			      	cp -f $OTROS_DIR/named.conf $BIND_DIR/named.conf 
			    	cp -f $OTROS_DIR/tupungato.db $BIND_DIR/tupungato.db 
			    	cp -f $OTROS_DIR/laslenas.db $BIND_DIR/laslenas.db 
			    	cp -f $OTROS_DIR/2-32.65.15.10.db $BIND_DIR/2-32.65.15.10.db  
			    	cp -f $OTROS_DIR/5-32.65.15.10.db $BIND_DIR/5-32.65.15.10.db
			    	cp -f $OTROS_DIR/6-32.65.15.10.db $BIND_DIR/6-32.65.15.10.db    
			    	cp -f $OTROS_DIR/96-27.65.15.10.db $BIND_DIR/96-27.65.15.10.db 
			    	cp -f $OTROS_DIR/144-28.6.94.10.db $BIND_DIR/144-28.6.94.10.db 
			    	cp -f $OTROS_DIR/9.43.10.db $BIND_DIR/9.43.10.db 
			    	cp -f $OTROS_DIR/10.43.10.db $BIND_DIR/10.43.10.db 
			    	cp -f $OTROS_DIR/16.168.192.db $BIND_DIR/16.168.192.db  
				ConfigurarDNS 
			;; 
			*) 
			    echo "Parametro incorrecto." 
			    exit -1 
		  ;; 
	esac 
} 
 
#--------------------------------------------------------- 
# Main del script 
#--------------------------------------------------------- 
 
if [ $USER != "root" ]; then 
	echo "El script debe ser ejecutado como root. Utilice el comando sudo" 
	exit -1 
fi 
 
if [ $# = 0 ]; then 
	echo "Se debe proporcionar un parametro que indique el DNS a configurar" 
	echo "Las opciones posibles son:" 
	echo "ROOT, SANRAFAEL, OTROS" 
	exit -1 
elif [ $# = 2 ]; then	 
	DEBUG=$2 
fi 
 
main $1 
 
Log "Status rndc" 
rndc status 
Log "" 
Log "Habilidanto querylog en rndc" 
rndc querylog 
Log "" 
SYSLOG=`tail /var/log/syslog` 
Log "ultimas lineas de syslog:" 
Log "-------------------------" 
Log "$SYSLOG" 
echo 
echo 
MESSAGES=`tail /var/log/messages` 
Log "ultimas lineas de messages:" 
Log "-------------------------" 
Log "$MESSAGES" 
echo 
echo 
echo "Configuracion completa!" 
exit 0 
 
 
