#!/bin/bash

INSTALL=0

function main() {

	case "$1" in

		WEB)
			echo "Configurando Web Server..."
			chmod 777 /var/www/*
			cp -f index.html /var/www/index.html				
			if [ $INSTALL = 1 ]; then
				apt-get install apache2
			fi
			
			if [ $? = 0 ]
			then
				ps -ef | grep "apache2" | grep -v "grep" > /dev/null
				if [ $? != 0 ]
				then
					cp -f index.html /var/www/index.html				
					echo "Iniciando servidor Web.."
					/etc/init.d/apache2 start
				fi
			fi
		;;
	
		TELNET)
			echo "Configurando Telnet Server..."
			
			if [ $INSTALL = 1 ]; then
				apt-get install telnetd
			fi
			
			if [ $? = 0 ]
			then	
				ps -ef | grep "inetd" | grep -v "grep" > /dev/null
				if [ $? != 0 ]
				then
					echo "Iniciando servidor Telnet.."
					/etc/init.d/openbsd-inetd start
					if [ $? != 0 ]
					then
						/etc/init.d/inetd start
					fi
				fi
			fi
		;;
	
		FTP)
			echo "Configurando FTP Server..."

			if [ $INSTALL = 1 ]; then
				apt-get install proftpd
			fi
			
			if [ $? = 0 ]
			then
				ps -ef | grep "proftpd" | grep -v "grep" > /dev/null
				if [ $? != 0 ]
				then
					echo "Iniciando servidor Ftp.."
					/etc/init.d/proftpd start			
				fi
			fi
		;;

		*)
			echo "Parametro invalido"
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
	echo "Se debe proporcionar un parametro que indique el servidor a configurar"
	echo "Las opciones posibles son:"
	echo "SERVIDORES: WEB, TELNET, FTP"
	exit -1
elif [ $# = 2 ]; then	
	INSTALL=$2
fi

main $1
echo "Configuracion completa!"
exit 0
