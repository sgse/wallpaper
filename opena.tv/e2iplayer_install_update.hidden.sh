#!/bin/sh

## Variablen ##
STARTDATE="$(date +%a.%d.%b.%Y-%H:%M)"
BOXIP="http://localhost"
WGET=/usr/bin/wget
EXTRACT=/usr/bin/7za
TARGET_PATH=/usr/lib/enigma2/python/Plugins/Extensions
TMP=/tmp
LOGFILE=$TMP/_e2iplayer_install.log

# maxbambi
#FILE_ADRESS=https://gitlab.com/maxbambi/e2iplayer/-/archive/master/e2iplayer-master.zip
# zadmario
FILE_ADRESS=https://gitlab.com/zadmario/e2iplayer/-/archive/master/e2iplayer-master.zip


# Generelles Logging.
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$LOGFILE 2>&1


# Konsole (OSD Fenster am TV) automatisch schliessen, damit man das bei der
# Ausfuehrung dieses Scripts direkt an der Box per Hotkey nicht selbst tun muss.
sleep 1
$WGET -q -O - $BOXIP/web/remotecontrol?command=174


# E2iPlayer Installation Startmeldung.
echo -e "\nInstalliere/Aktualisiere E2iPlayer ... -> $STARTDATE\n\n"
$WGET -O - -q "$BOXIP/web/message?text=Starte%20Installation%20bzw%2E%20Aktualisierung%0AE2iPlayer \
%20%2E%2E%2E%20->%20$STARTDATE&type=1&timeout=10" > /dev/null && sleep 12


# Bei Bedarf benoetigte Plugins/Programme nachinstallieren wie ppanel, e2iplayer-deps, und p7zip.
E2IPLAYER_DEPS=enigma2-plugin-extensions-e2iplayer-deps
PPANEL=enigma2-plugin-extensions-ppanel
P7ZIP=p7zip

for i in $E2IPLAYER_DEPS $PPANEL $P7ZIP ; do
	opkg list-installed | grep -q $i
	
	if [ "$?" != "0" ] ; then
		echo -e "$i fehlt.\nInstalliere $i  ...\n"
			
		if [ "$OPKG_UPDATE" = "yes" ] ; then
			opkg install $i
		else
			OPKG_UPDATE=yes && opkg update && opkg install $i
		fi
			
		if [ "$?" = "0" ] ; then
			echo -e "\n$i erfolgreich installiert.\n\n"
		else
			$WGET -O - -q "$BOXIP/web/message?text=FEHLER%20---%20(%20Details%20dazu%20in%20$LOGFILE%20)&type=3" > /dev/null
			echo -e "\n... FEHLER ...\n$i installieren fehlgeschlagen !"
			echo -e "$i manuell mit Befehl;\nopkg install $i\ninstallieren und/oder $0 erneut starten.\n" && exit 1
		fi
	fi
done

# Image Distro auslesen (z.b: ob OpenATV oder OpenPLI) da es im OpenPLI bei Verwendung der E2iPlayer Version von @zadmario
# ein Problem mit "nicht gefundener OpenSSL" geben kann, was mit der Installation von libcrypto-compat zu beheben geht.
DISTROVERSION="$($WGET -O - -q $BOXIP/web/deviceinfo | grep "\(<\|</\)e2distroversion" \
 | tr -d '\n' | sed "s/.*<e2distroversion>\(.*\)<\/e2distroversion>.*/\\1\n/")"
LIBCRYPTO_COMPAT="$(opkg info libcrypto-compat* | grep "Package:" | grep -v '\(-dbg\|-dev\|-staticdev\)' | awk {'print $NF'})"

# Wenn die Image Distro ein OpenPLI ist, bei Bedarf das Paket libcrypto-compat nachinstallieren. 
if [ "$DISTROVERSION" = "openpli" ] ; then
	opkg list-installed | grep "$LIBCRYPTO_COMPAT"
	
	if [ "$?" != "0" ] ; then
		echo -e "Image Distro = \"$DISTROVERSION\",\n$LIBCRYPTO_COMPAT fehlt.\nInstalliere $LIBCRYPTO_COMPAT ...\n\n"
			
		if [ "$OPKG_UPDATE" = "yes" ] ; then
			opkg install $LIBCRYPTO_COMPAT
		else
			opkg update && opkg install $LIBCRYPTO_COMPAT
		fi
		
		echo -e "\n"
	fi
fi


# Python Version checken (um fuer die Install/Aktualisierung zw. bis zu OpenATV-6.4 und ab OpenATV-7.0 zu unterscheiden).
PYTHON_VERSION_COMPLETE=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
echo -e "Python Version = $PYTHON_VERSION_COMPLETE\n\n"
#PYTHON_VERSION=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:1])))')
#PYTHON_VERSION=$(python -c 'import platform; print(platform.python_version())[:1]')
PYTHON_VERSION=$(python -c "import sys; print(sys.version_info.major)")

# Wenn Python Version 2.x.x -> E2iPlayer aus Git von @zadmario bzw. @maxbambi installieren/aktualisieren. 
if [ $PYTHON_VERSION -eq 2 ] ; then
	echo -e "Downloade e2iplayer-master.zip ...\n"
	$WGET -O $TMP/e2iplayer-master.zip $FILE_ADRESS

	echo -e "\nEntpacke e2iplayer-master.zip nach;\n$TMP ..."
	$EXTRACT x $TMP/e2iplayer-master.zip -o$TMP

	echo -e "\n\nKopiere;\n$TMP/e2iplayer-master/IPTVPlayer\nnach;\n$TARGET_PATH ...\n"
	cp -rf $TMP/e2iplayer-master/IPTVPlayer $TARGET_PATH

	if [ "$?" = "0" ] ; then
		$WGET -O - -q "$BOXIP/web/message?text=E2iPlayer%20erfolgreich%20installiert%20bzw%2E%20aktualisiert%2E&type=1&timeout=10" > /dev/null
		echo -e "\nE2iPlayer wurde erfolgreich installiert/aktualisiert.\n"
	else
		$WGET -O - -q "$BOXIP/web/message?text=FEHLER%20---%20(%20Details%20dazu%20in%20$LOGFILE%20)&type=3" > /dev/null
		echo -e "\n... FEHLER ...\nE2iPlayer Install/Aktualisierung fehlgeschlagen !\n" && failed=yes
	fi


	# Reste loeschen.
	echo -e "\nLoesche Altlasten (.zip und Ordner e2iplayer-master) ...\n"
	rm $TMP/e2iplayer-master.zip
	rm -r $TMP/e2iplayer-master
	echo -e "\nJob fertig !\n"

# Wenn Python Version 3.x.x -> E2iPlayer aus Git von @jbleyel installieren/aktualisieren.
elif [ $PYTHON_VERSION -eq 3 ] ; then
	FILE_ADRESS=https://github.com/oe-mirrors/e2iplayer/archive/refs/heads/python3.zip
	echo -e "Downloade e2iplayer-python3.zip ...\n"
	$WGET -O $TMP/e2iplayer-python3.zip $FILE_ADRESS

	echo -e "\nEntpacke e2iplayer-python3.zip nach;\n$TMP ..."
	$EXTRACT x $TMP/e2iplayer-python3.zip -o$TMP

	echo -e "\n\nKopiere;\n$TMP/e2iplayer-python3/IPTVPlayer\nnach;\n$TARGET_PATH ...\n"
	cp -rf $TMP/e2iplayer-python3/IPTVPlayer $TARGET_PATH

	if [ "$?" = "0" ] ; then
		$WGET -O - -q "$BOXIP/web/message?text=E2iPlayer%20erfolgreich%20installiert%20bzw%2E%20aktualisiert%2E&type=1&timeout=10" > /dev/null
		echo -e "\nE2iPlayer wurde erfolgreich installiert/aktualisiert.\n"
	else
		$WGET -O - -q "$BOXIP/web/message?text=FEHLER%20---%20(%20Details%20dazu%20in%20$LOGFILE%20)&type=3" > /dev/null
		echo -e "\n... FEHLER ...\nE2iPlayer Install/Aktualisierung fehlgeschlagen !\n" && failed=yes
	fi


	# Reste loeschen.
	echo -e "\nLoesche Altlasten (.zip und Ordner e2iplayer-python3) ...\n"
	rm $TMP/e2iplayer-python3.zip
	rm -r $TMP/e2iplayer-python3
	echo -e "\nJob fertig !\n" 
fi

if [ "$failed" = "yes" ] ; then
	echo -e "\nInstallation/Aktualisierung fehlgeschlagen,\nInternet Verbindung pruefen\nund/oder $0 erneut starten.\n" && exit 1
fi


# Pruefen ob Aufnahme{n} laeuft/laufen, wenn nicht Enigma2-GUI-Neusstart einleiten, wenn doch Enigma2-GUI-Neusstart
# um 10 Minuten verschieben und das wiederholend so lange bis keine Aufnahme{n} mehr laeuft/laufen.
sleep 11
z=1
REC=yes
while [ "$REC" = "yes" ] ; do
	if [ $($WGET -O- -q $BOXIP/web/timerlist | grep "<e2state>2</e2state>" | grep -cm 1 "2") = 1 ] ; then
		REC=yes 
		echo -e "Kein Enigma2-GUI-Neustart moeglich da eine Aufnahme laeuft -> Warte 10 Minuten ...\n"
		$WGET -O - -q "$BOXIP/web/message?text=Kein%20Enigma2%2DGUI%2DNeustart%20moeglich%2C%20da%20eine%0A \
        Aufnahme%20laeuft%20%2D%3E%20Warte%20%31%30%20Minuten%20%2E%2E%2E&type=2&timeout=10" > /dev/null
		z=$((z+1)) && sleep 10m
		echo -e "Leite Enigma2-GUI-Neustart (Versuch $z) ein ...\n"
		$WGET -O - -q "$BOXIP/web/message?text=Leite%20Enigma2%2DGUI%2DNeustart%20ein%20%2E%2E%2E&type=1&timeout=10" > /dev/null && sleep 12
	else
		REC=no
	fi
done

echo -e "Keine laufende Aufnahme -> Starte Enigma2-GUI neu ...\n"
$WGET -q -O - $BOXIP/web/powerstate?newstate=3
#wget -q -O - http://localhost/web/powerstate?newstate=3


exit
