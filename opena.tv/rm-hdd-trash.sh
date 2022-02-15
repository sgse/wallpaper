#!/bin/sh
# duo2 usr/script/rm-hdd-trash.sh # 09.03.2018
Hilfe(){
  echo "${0##*/} löscht die Dateien aus den Papierkörben "
  echo "Hilfe für ${0##*/} gibt es bei SGS"
  exit
}
test "${1}" = "-h" -o "${1}" = "-help" -o "${1}" = "--help" && Hilfe

Exit(){
    echo "$0: $2" >&2
    exit $1
}

files_hdd=`find /media/hdd/movie/.Trash/ -type f | wc -l`
#files_hdd2=`find /media/hdd2/movie/.Trash/ -type f | wc -l`
path_hdd='/media/hdd/movie/.Trash'
#path_hdd2='/media/hdd2/movie/.Trash'

echo "$files_hdd Dateien in $path_hdd"
#echo "$files_hdd2 Dateien in $path_hdd2"
echo '*********************************************'
echo '* Die rm-hdd-trash.sh liegt in /usr/script/ *'
echo '*********************************************'

if [ $files_hdd > 0 ]
	then
		rm $path_hdd/*.* 2>/dev/null
		echo "$files_hdd Dateien aus $path_hdd entfernt"
fi

#if [ $files_hdd2 > 0 ]
#	then
#		rm $path_hdd/*.* 2>/dev/null
#		echo "$files_hdd2 Dateien aus $path_hdd2 entfernt"
#fi
