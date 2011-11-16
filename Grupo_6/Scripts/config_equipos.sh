#! /bin/bash 
#############################################################
# 75.43 - Introduccion a los Sistemas Distribuidos          #
# Trabajo Practico Final. Grupo 6                           #
# Script de configuracion de equipos.                       #
#############################################################

# variable para establecer modo debug. Si esta en 1, se ve mas informacion al ejecutar el script 
DEBUG=0 
 
# Definicion de constantes para redes y mascaras.

RED_A=10.94.5.128 
MASCARA_A=255.255.255.192 
 
RED_C=10.15.65.128 
MASCARA_C=255.255.255.128 
 
RED_D=10.94.6.128 
MASCARA_D=255.255.255.240 
 
RED_E=10.94.5.192 
MASCARA_E=255.255.255.192 
 
RED_F=10.94.6.192 
MASCARA_F=255.255.255.192 
 
RED_G=10.15.65.0 
MASCARA_G=255.255.255.252 
 
RED_I=10.94.6.144 
MASCARA_I=255.255.255.240 
 
RED_J=10.43.9.0 
MASCARA_J=255.255.255.0 
 
RED_K=10.15.65.96 
MASCARA_K=255.255.255.224 
 
RED_O=10.15.65.4 
MASCARA_O=255.255.255.252 
 
RED_P=10.43.10.0 
MASCARA_P=255.255.255.0 
 
RED_Q=192.168.16.0 
MASCARA_Q=255.255.255.0 
 
#Definicion de constantes para las interfaces de routers 
H3_A=10.94.5.132 
H3_C=10.15.65.129 
H3_D=10.94.6.130 
 
H5_D=10.94.6.131 
H5_E=10.94.5.194 
H5_F=10.94.6.193 
H5_G=10.15.65.1 
 
H16_G=10.15.65.2 
H16_I=10.94.6.147 
H16_J=10.43.9.3 
 
H17_J=10.43.9.4 
H17_K=10.15.65.97 
H17_O=10.15.65.5 
 
H30_P=10.43.10.1 
H30_Q=192.168.16.2 
 
H33_O=10.15.65.6 
H33_P=10.43.10.2 

#Definicion de constantes para las interfaces de hosts 
RAMADA1_RED_E=10.94.5.195 
ELMARMOLEJO1_RED_I=10.94.6.148 
MILAGRO1_RED_P=10.43.10.4 

#Definicion de constantes para las interfaces de servidores
WEB_SERVER=192.168.16.1 
TELNET_SERVER_A=10.94.5.130 
TELNET_SERVER_D=10.94.6.129 
FTP_SERVER=10.43.9.1 

#Definicion de constantes para DNS
ROOT_DNS=$H17_J 
SANRAFAEL_DNS=$H3_D 
OTROS_DNS=$H16_I 
 
INTERFAZ=""  
 
function Log(){ 
	if [ $DEBUG = 1 ]; then 
		echo "[DEBUG] - $1" 
	fi 
} 
 
function LimpiarTablaDeRuteo() { 
	Log "Eliminando rutas..." 
	touch rutas.bkp 
	chmod 777 rutas.bkp 
	netstat -rn | grep "^[0-9].*" > rutas.bkp 
	 
	cat rutas.bkp | while read LINE;do 
		IP=`echo $LINE | awk '{print $1}'` 
		MASCARA=`echo $LINE | awk '{print $3}'` 
		Log "Ejecutando: route del -net $IP $MASCARA" 
		route del -net $IP netmask $MASCARA 
	done 
	Log "Rutas eliminadas!" 
} 
 
function DeshabilitarInterfaces(){ 
	Log "Deshabilitando interfaces..." 
	# por seguridad bajamos todas las interfaces del equipo 
	ifconfig | grep "^eth.*" | awk {'print $1'} | while read LINEA 
	do	 
		Log "Bajando interfaz $LINEA" 
		ifconfig $LINEA down 
	done 
	Log "Interfaces deshabilitadas!" 
} 
 
 
function HabilitarPrimeraInterfaz() { 
 	INTERFAZ=`ifconfig -a | grep -m1 "^eth.*" | awk {'print $1'}` 
	Log "Habilitando interfaz ($INTERFAZ) ....."  
	ifconfig $INTERFAZ up 
	sleep 3 
	Log "Interfaz habilitada!" 
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

	case "$1" in	     
			SANRAFAEL)  
			Log "Ejecutando: echo search cuyo.dc.fi.uba.ar sanrafael.cuyo.dc.fi.uba.ar tupungato.cuyo.dc.fi.uba.ar laslenas.cuyo.dc.fi.uba.ar > /etc/resolv.conf" 
			echo "search cuyo.dc.fi.uba.ar sanrafael.cuyo.dc.fi.uba.ar tupungato.cuyo.dc.fi.uba.ar laslenas.cuyo.dc.fi.uba.ar" > /etc/resolv.conf		 
			Log "Ejecutando: echo nameserver $SANRAFAEL_DNS > /etc/resolv.conf" 
			echo "nameserver $SANRAFAEL_DNS" >> /etc/resolv.conf 				
			;; 

			TUPUNGATO)  
			Log "Ejecutando: echo search cuyo.dc.fi.uba.ar sanrafael.cuyo.dc.fi.uba.ar tupungato.cuyo.dc.fi.uba.ar laslenas.cuyo.dc.fi.uba.ar > /etc/resolv.conf" 
			echo "search cuyo.dc.fi.uba.ar sanrafael.cuyo.dc.fi.uba.ar tupungato.cuyo.dc.fi.uba.ar laslenas.cuyo.dc.fi.uba.ar" > /etc/resolv.conf		 
			Log "Ejecutando: echo nameserver $OTROS_DNS > /etc/resolv.conf" 
			echo "nameserver $OTROS_DNS" >> /etc/resolv.conf 				
			;; 

			LASLENAS) 
			Log "Ejecutando: echo search cuyo.dc.fi.uba.ar sanrafael.cuyo.dc.fi.uba.ar tupungato.cuyo.dc.fi.uba.ar laslenas.cuyo.dc.fi.uba.ar > /etc/resolv.conf" 
			echo "search cuyo.dc.fi.uba.ar sanrafael.cuyo.dc.fi.uba.ar tupungato.cuyo.dc.fi.uba.ar laslenas.cuyo.dc.fi.uba.ar" > /etc/resolv.conf		 
			Log "Ejecutando: echo nameserver $OTROS_DNS > /etc/resolv.conf" 
			echo "nameserver $OTROS_DNS" >> /etc/resolv.conf 				
			;; 
	esac
	
	chmod 777 /etc/resolv.conf 
	RESOLVCONF=`cat /etc/resolv.conf` 
	Log "El contenido de /etc/resolv.conf es: $RESOLVCONF" 
} 
 
function ConfigurarIPFORWARD() { 
	_IPFORWARD=$1 
	Log "Configurando ip forward con valor = $_IPFORWARD" 
	echo $_IPFORWARD > /proc/sys/net/ipv4/ip_forward 
} 
 
function AgregarRuta() { 
	if [ $# = 4 ]; then 
		_RED=$1 
		_MASCARA=$2 
		_GATEWAY=$3 
		_METRICA=$4 
		Log "Ejecutando: route add -net $_RED netmask $_MASCARA gw $_GATEWAY metric $_METRICA"  
		route add -net $_RED netmask $_MASCARA gw $_GATEWAY metric $_METRICA 
	else 
		# si llegan 2 parametros es que estamos configurando la default 
		_RED=$1 
		_GATEWAY=$2 
		Log "Ejecutando: route add -net $_RED gw $_GATEWAY"  
		route add -net $_RED gw $_GATEWAY 
	fi 
	 
} 
 
function ConfigurarInterfaz(){ 
	_INTERFAZ=$1 
	_RED=$2 
	_MASCARA=$3 
	 
	if [ $# = 4 ]; then 
		_INTERFAZ="$_INTERFAZ:$4" 
	fi 
 
	Log "Ejecutando: ifconfig $_INTERFAZ $_RED netmask $_MASCARA" 
	ifconfig $_INTERFAZ $_RED netmask $_MASCARA 
 
} 
 
function InicializarConfiguracion() { 
	 
	echo "Configurando el dispositivo $1 ...." 
 
	DeshabilitarInterfaces 
 
	LimpiarTablaDeRuteo 
 
	HabilitarPrimeraInterfaz 
 
	ConfigurarDNS $2

	echo "Dispositivo configurado!" 
} 
 
function RenombrarHost() { 
	rm -f "/etc/hostname" 
	echo $1 > "/etc/hostname" 
	Log "Ejecutando: echo $1 > /etc/hostname" 
	Log "Ejecutando: hostname -F /etc/hostname" 
	hostname -F /etc/hostname 
} 
 
function main() { 
	case "$1" in	     
			H3) 
				InicializarConfiguracion $1 SANRAFAEL
				RenombrarHost $1 
 
				ConfigurarIPFORWARD 1 
			 
				ConfigurarInterfaz $INTERFAZ $H3_A $MASCARA_A 
				ConfigurarInterfaz $INTERFAZ $H3_C $MASCARA_C 1 
				ConfigurarInterfaz $INTERFAZ $H3_D $MASCARA_D 2 
					     
				AgregarRuta $RED_E $MASCARA_E $H5_D 1 
				AgregarRuta $RED_F $MASCARA_F $H5_D 1 
				AgregarRuta $RED_G $MASCARA_G $H5_D 1 
				AgregarRuta $RED_I $MASCARA_I $H5_D 2 
				AgregarRuta $RED_J $MASCARA_J $H5_D 2 
				AgregarRuta $RED_K $MASCARA_K $H5_D 3 
				AgregarRuta $RED_O $MASCARA_O $H5_D 3 
				AgregarRuta $RED_P $MASCARA_P $H5_D 4 
				AgregarRuta $RED_Q $MASCARA_Q $H5_D 5 
			;; 
			 
			H5) 
				InicializarConfiguracion $1  SANRAFAEL
				RenombrarHost $1 
 
				ConfigurarIPFORWARD 1 
 
				ConfigurarInterfaz $INTERFAZ $H5_D $MASCARA_D 
				ConfigurarInterfaz $INTERFAZ $H5_E $MASCARA_E 1 
				ConfigurarInterfaz $INTERFAZ $H5_F $MASCARA_F 2 
				ConfigurarInterfaz $INTERFAZ $H5_G $MASCARA_G 3 
				    		 
				AgregarRuta $RED_A $MASCARA_A $H3_D 1 
				AgregarRuta $RED_C $MASCARA_C $H3_D 1 
				AgregarRuta $RED_I $MASCARA_I $H16_G 1 
				AgregarRuta $RED_J $MASCARA_J $H16_G 1 
				AgregarRuta $RED_K $MASCARA_K $H16_G 2 
				AgregarRuta $RED_O $MASCARA_O $H16_G 2 
				AgregarRuta $RED_P $MASCARA_P $H16_G 3 
				AgregarRuta $RED_Q $MASCARA_Q $H16_G 4 
			;;	 
			     
			H16) 
				InicializarConfiguracion $1 TUPUNGATO
				RenombrarHost $1 
 
				ConfigurarIPFORWARD 1 
 
				ConfigurarInterfaz $INTERFAZ $H16_G $MASCARA_G 
				ConfigurarInterfaz $INTERFAZ $H16_I $MASCARA_I 1 
				ConfigurarInterfaz $INTERFAZ $H16_J $MASCARA_J 2 
						 
				AgregarRuta $RED_A $MASCARA_A $H5_G 2 
				AgregarRuta $RED_C $MASCARA_C $H5_G 2 
				AgregarRuta $RED_D $MASCARA_D $H5_G 1 
				AgregarRuta $RED_E $MASCARA_E $H5_G 1 
				AgregarRuta $RED_F $MASCARA_F $H5_G 1 
				AgregarRuta $RED_K $MASCARA_K $H17_J 1 
				AgregarRuta $RED_O $MASCARA_O $H17_J 1 
				AgregarRuta $RED_P $MASCARA_P $H17_J 2 
				AgregarRuta $RED_Q $MASCARA_Q $H17_J 3 
			;; 
			 
			H17) 
				InicializarConfiguracion $1 TUPUNGATO
				RenombrarHost $1 
				 
				ConfigurarIPFORWARD 1 
			 
				ConfigurarInterfaz $INTERFAZ $H17_J $MASCARA_J 
				ConfigurarInterfaz $INTERFAZ $H17_K $MASCARA_K 1 
				ConfigurarInterfaz $INTERFAZ $H17_O $MASCARA_O 2 
			 
				AgregarRuta $RED_A $MASCARA_A $H16_J 3 
				AgregarRuta $RED_C $MASCARA_C $H16_J 3 
				AgregarRuta $RED_D $MASCARA_D $H16_J 2 
				AgregarRuta $RED_E $MASCARA_E $H16_J 2 
				AgregarRuta $RED_F $MASCARA_F $H16_J 2 
				AgregarRuta $RED_G $MASCARA_G $H16_J 1 
				AgregarRuta $RED_I $MASCARA_I $H16_J 1 
				AgregarRuta $RED_P $MASCARA_P $H33_O 1 
				AgregarRuta $RED_Q $MASCARA_Q $H33_O 2 
			;; 
			 
			H33) 
				InicializarConfiguracion $1 LASLENAS
				RenombrarHost $1 
				 
			    ConfigurarIPFORWARD 1 
			     
				ConfigurarInterfaz $INTERFAZ $H33_O $MASCARA_O 
				ConfigurarInterfaz $INTERFAZ $H33_P $MASCARA_P 1 
				 
				AgregarRuta $RED_A $MASCARA_A $H17_O 4 
				AgregarRuta $RED_C $MASCARA_C $H17_O 4 
				AgregarRuta $RED_D $MASCARA_D $H17_O 3 
				AgregarRuta $RED_E $MASCARA_E $H17_O 3 
				AgregarRuta $RED_F $MASCARA_F $H17_O 3 
				AgregarRuta $RED_G $MASCARA_G $H17_O 2 
				AgregarRuta $RED_I $MASCARA_I $H17_O 2 
				AgregarRuta $RED_J $MASCARA_J $H17_O 1 
				AgregarRuta $RED_K $MASCARA_K $H17_O 1 
				AgregarRuta $RED_Q $MASCARA_Q $H30_P 1 
			;;  
			 
			H30) 
	   			InicializarConfiguracion $1 LASLENAS
				RenombrarHost $1 
	   			 
				ConfigurarIPFORWARD 1 
 
				ConfigurarInterfaz $INTERFAZ $H30_P $MASCARA_P 
				ConfigurarInterfaz $INTERFAZ $H30_Q $MASCARA_Q 1 
 
				AgregarRuta $RED_A $MASCARA_A $H33_P 5 
				AgregarRuta $RED_C $MASCARA_C $H33_P 5 
				AgregarRuta $RED_D $MASCARA_D $H33_P 4 
				AgregarRuta $RED_E $MASCARA_E $H33_P 4 
				AgregarRuta $RED_F $MASCARA_F $H33_P 4 
				AgregarRuta $RED_G $MASCARA_G $H33_P 3 
				AgregarRuta $RED_I $MASCARA_I $H33_P 3 
				AgregarRuta $RED_J $MASCARA_J $H33_P 2 
				AgregarRuta $RED_K $MASCARA_K $H33_P 2 
				AgregarRuta $RED_O $MASCARA_O $H33_P 1 
			;; 
			 
			WEB) 
				InicializarConfiguracion $1 LASLENAS
				RenombrarHost $1 
				 
				ConfigurarIPFORWARD 0 
				 
				ConfigurarInterfaz $INTERFAZ $WEB_SERVER $MASCARA_Q 
				 
				AgregarRuta "default" $H30_Q 
			;; 
			 
			TELNET) 
				InicializarConfiguracion $1 SANRAFAEL
				RenombrarHost $1 
				 
				ConfigurarIPFORWARD 0 
			 
				ConfigurarInterfaz $INTERFAZ $TELNET_SERVER_A $MASCARA_A    		 
				ConfigurarInterfaz $INTERFAZ $TELNET_SERVER_D $MASCARA_D 1 
				 
				AgregarRuta $RED_C $MASCARA_C $H3_D 1 
				AgregarRuta $RED_E $MASCARA_E $H5_D 1 
				AgregarRuta $RED_F $MASCARA_F $H5_D 1 
				AgregarRuta $RED_G $MASCARA_G $H5_D 1 
				AgregarRuta $RED_I $MASCARA_I $H5_D 2 
				AgregarRuta $RED_J $MASCARA_J $H5_D 2 
				AgregarRuta $RED_K $MASCARA_K $H5_D 3 
				AgregarRuta $RED_O $MASCARA_O $H5_D 3 
				AgregarRuta $RED_P $MASCARA_P $H5_D 4 
				AgregarRuta $RED_Q $MASCARA_Q $H5_D 5 
 
				AgregarRuta $RED_C $MASCARA_C $H3_A 1 
				AgregarRuta $RED_E $MASCARA_E $H3_A 2 
				AgregarRuta $RED_F $MASCARA_F $H3_A 2 
				AgregarRuta $RED_G $MASCARA_G $H3_A 2 
				AgregarRuta $RED_I $MASCARA_I $H3_A 3 
				AgregarRuta $RED_J $MASCARA_J $H3_A 3 
				AgregarRuta $RED_K $MASCARA_K $H3_A 4 
				AgregarRuta $RED_O $MASCARA_O $H3_A 4 
				AgregarRuta $RED_P $MASCARA_P $H3_A 5 
				AgregarRuta $RED_Q $MASCARA_Q $H3_A 6 
 
			;; 
			 
			FTP) 
				InicializarConfiguracion $1 TUPUNGATO
				RenombrarHost $1 
				 
				ConfigurarIPFORWARD 0 
			 
				ConfigurarInterfaz $INTERFAZ $FTP_SERVER $MASCARA_J 
				 
				AgregarRuta $RED_A $MASCARA_A $H16_J 3 
				AgregarRuta $RED_C $MASCARA_C $H16_J 3 
				AgregarRuta $RED_D $MASCARA_D $H16_J 2 
				AgregarRuta $RED_E $MASCARA_E $H16_J 2 
				AgregarRuta $RED_F $MASCARA_F $H16_J 2 
				AgregarRuta $RED_G $MASCARA_G $H16_J 1 
				AgregarRuta $RED_I $MASCARA_I $H16_J 1 
 
				AgregarRuta $RED_K $MASCARA_K $H17_J 1 
				AgregarRuta $RED_O $MASCARA_O $H17_J 1 
				AgregarRuta $RED_P $MASCARA_P $H17_J 2 
				AgregarRuta $RED_Q $MASCARA_Q $H17_J 3 
 
			;; 
			 
			RAMADA1) 
				InicializarConfiguracion $1 SANRAFAEL
				RenombrarHost $1 
 
				ConfigurarIPFORWARD 0 
				 
				ConfigurarInterfaz $INTERFAZ $RAMADA1_RED_E $MASCARA_E 
				 
				AgregarRuta "default" $H5_E 
 
 
			;; 
			 
			ELMARMOLEJO1) 
				InicializarConfiguracion $1 TUPUNGATO
				RenombrarHost $1 
				 
				ConfigurarIPFORWARD 0 
				 
				ConfigurarInterfaz $INTERFAZ $ELMARMOLEJO1_RED_I $MASCARA_I 
				 
				AgregarRuta "default" $H16_I 
			;; 
			 
			MILAGRO1) 
				InicializarConfiguracion $1 LASLENAS
				RenombrarHost $1 
				 
				ConfigurarIPFORWARD 0		 
				 
				ConfigurarInterfaz $INTERFAZ $MILAGRO1_RED_P $MASCARA_P 
				 
				AgregarRuta $RED_A $MASCARA_A $H33_P 5 
				AgregarRuta $RED_C $MASCARA_C $H33_P 5 
				AgregarRuta $RED_D $MASCARA_D $H33_P 4 
				AgregarRuta $RED_E $MASCARA_E $H33_P 4 
				AgregarRuta $RED_F $MASCARA_F $H33_P 4 
				AgregarRuta $RED_G $MASCARA_G $H33_P 3 
				AgregarRuta $RED_I $MASCARA_I $H33_P 3 
				AgregarRuta $RED_J $MASCARA_J $H33_P 2 
				AgregarRuta $RED_K $MASCARA_K $H33_P 2 
				AgregarRuta $RED_O $MASCARA_O $H33_P 1 
 
				AgregarRuta $RED_Q $MASCARA_Q $H30_P 1 
 
				 
			;; 
			 
			*) 
				echo "El parametro $1 no corresponde a un dispositivo valido" 
				exit -1 
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
	echo "Se debe proporcionar un parametro que indique el dispositivo a configurar" 
	echo "Los dispositivos posibles son:" 
	echo "ROUTERS: H3, H5, H16, H17, H30, H33" 
	echo "SERVIDORES: WEB, TELNET, FTP" 
	echo "HOSTS: RAMADA1, ELMARMOLEJO1, MILAGRO1" 
	exit -1 
elif [ $# = 2 ]; then	 
	DEBUG=$2 
fi 
 
main $1 
echo "Configuracion completa!" 
exit 0 
 
 
 
