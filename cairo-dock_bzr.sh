#!/bin/bash

# Script for BZR install for Cairo-Dock
#
# Copyright : (C) 2008-2009 by Yann SLADEK
#                 2009-2012 by Matthieu BAERTS
# E-mail : mav@glx-dock.org, matttbe@glx-dock.org
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# http://www.gnu.org/licenses/licenses.html#GPL


## Changelog
# 18/08/14 : 	matttbe : Added libwayland-dev, removed libgnomeui-dev
# 28/07/14 : 	matttbe : Added gnome-session for GNOME users (needed for the session)
# 09/12/13 : 	matttbe : Added libxcomposite-dev, libxrandr-dev (instead of libxinerama-dev), gdb (instead of ddd)
# 16/03/13 : 	matttbe : Added libgnome-menu-3-dev
# 16/11/12 : 	matttbe : Modified all updated CMake flags
# 05/11/12 : 	matttbe : Detection of Gnome + fixed dependences for installations before oneiric (with GTK2)
# 27/08/12 : 	matttbe : Display the output of 'install_applet.sh' if there is a question
# 18/07/12 : 	matttbe : Added -Denable-desktop-manager=yes for Debian
# 15/04/12 : 	matttbe : Fixed ShowDialog
# 06/04/12 : 	matttbe : Prise en charge de precise pour la désinstallation de paquets + accélération de cette opération
# 02/01/12 : 	matttbe : Retrait de NEEDED_GNOME et XFCE pour après lucid.
# 02/01/12 : 	matttbe : Ajout de -Denable-global-menu=yes
# 22/12/11 : 	matttbe : Ajout de libwebkitgtk-3.0-dev et libvte-2.90-dev pour GTK3 (oneiric et +)
# 20/12/11 : 	matttbe : Ajout de -Denable-application-menu=yes pour Natty et + (part 2)
# 19/12/11 : 	matttbe : Ajout de -Denable-application-menu=yes pour Natty et +
# 04/12/11 : 	matttbe : Ajout de libindicator3-dev pour Oneiric et +
# 02/12/11 : 	matttbe : Ajout de libido3-0.1-dev pour Oneiric et +
# 01/12/11 : 	matttbe : Ajout de libgtk-3-dev et libdbusmenu-gtk3-dev pour Oneiric et +
# 09/09/11 : 	matttbe : Ajout de -Denable-desktop-manager=yes pour Natty et + pour lancer une session sans Unity
# 01/09/11 : 	matttbe : retrait de -Denable-impulse (plus nécessaire) + -r => -R
# 30/08/11 : 	matttbe : Ajout de -i, -r, -u pour un install, reinstall, update sans passer par le menu
# 26/08/11 : 	matttbe : Retrait de libglut et impulse est maintenant stable
# 31/07/11 : 	matttbe : Ajout de libupower-glib-dev
# 30/07/11 : 	matttbe : ajout d'un check en cas de problème au make install
# 16/07/11 : 	matttbe : installation des paquets en 1 coup + déinstallation de tous les paquets de CD
# 13/07/11 : 	matttbe : retrait du weekly debian
# 30/06/11 : 	matttbe : Ajout d'Impulse + dépendances (libpulse-dev & libfftw3-dev)
# 20/06/11 : 	matttbe : Suppression des fichiers installés par le core avant le make install
# 26/05/11 : 	matttbe : Retrait des flags non utilisés
# 24/02/11 : 	matttbe : Ajout de -DWITH_VALA=yes pour >= natty
# 24/02/11 : 	matttbe : Ajout de -DWITH_VALA=no pour <= lucid
# 28/01/11 : 	matttbe : Ajout de -DENABLE_GTK_GRIP=1 pour >= natty
# 18/01/11 : 	matttbe : Ajout de libwebkitgtk-dev pour >= natty
# 07/01/11 : 	matttbe : Ajout de python valac mono-gmcs ruby libglib2.0-cil-dev libndesk-dbus1.0-cil-dev libndesk-dbus-glib1.0-cil-dev
# 17/11/10 : 	matttbe : Ajout de enable-recent-events + libzeitgeist-dev
# 27/10/10 : 	matttbe : Ajout de enable-disks + removed remote_control
# 02/10/10 : 	matttbe : Ajout de libsensors4-dev
# 16/09/10 : 	matttbe : Ajout de enable_remote_control
# 07/09/10 : 	matttbe : Recompilation de Cairo-Desklet si changements dans l'API
# 24/06/10 : 	matttbe : Ajout d'une option "--no-exit" pour ne pas fermer le terminal
# 20/06/10 : 	matttbe : On efface les anciens caches de cmake car on a changé de dossier => à VIRER dans qqs jours !!!
# 19/06/10 : 	matttbe : Ajout de cairo-desklet + afficher la version installée
# 18/06/10 : 	matttbe : compilation dans un dossier build.
# 30/05/10 : 	matttbe : fix pour le script de smo (par smo) + oubli d'une boucle pour needed_a_karmic
# 18/05/10 : 	matttbe : Ajout de MeMenu + Status notifer
# 09/05/10 : 	matttbe : Ajout de libical-dev
# 09/04/10 : 	matttbe : suppression des dossiers data et lib en cas de changements de noms de lib ou de fichiers pour les plug-ins
# 25/03/10 : 	matttbe : libcurl4-dev + dépendances des plug-ins extras
# 22/03/10 : 	matttbe : passage à cmake
# 22/01/10 : 	matttbe : pg-extras -> liens symboliques
# 10/02/10 : 	matttbe : changement pour le nouveau nom de domaine glx-dock.org
# 22/01/10 : 	matttbe : changement pour DBus applets + traduction
# 08/11/09 : 	matttbe : Prise en charge de Lucid + applets third-party
# 25/10/09 : 	matttbe : ajout de RSSreader + scooby-do + envoie des info via ShowDialog
# 16/10/09 : 	matttbe : Contrôle de la connexion Internet
# 14/10/09 : 	matttbe : Ajout du support pour Linux Mint
# 18/09/09 : 	matttbe : on enlève le lanceur devenu inutile.
# 16/09/09 : 	nochka85 : Fix du message si on n'a jamais installé le dock par paquet
#		matttbe : fix erreur au reload
# 15/09/09 : 	matttbe : ajout du dépôt debian et hardy + désinstallation des paquets de CD si installation par bzr.
#		boucle pour ajouter des arguments, par ex './cairo-dock_bzr.sh -e "scooby-do"'. L'autre méthode est tjs ok.
#		+ curl dans les dep + reload auto en cas de nouvelle version
# 13/09/09 : 	matttbe : ajout de mail et NM à compiler
#		possibilité d'ajouter d'autres arguments avec, par exemple  './cairo-dock_bzr.sh -e "--enable-scooby-do"'
# 08/09/09 : 	matttbe : fix de libxklavier, fix de revno, réduction des passphrases
#		possibilité de choisir bzr branch ou bzr checkout et d'installer les depôts weekly
#		Menu différent si le dossier cairo-dock-core existe ou non
#		On 'force' l'installation des paquets
#		Ajout du menu avec -o et -c
#		Fix pour branch => il faut d'abord se trouver dans le dossier !
# 06/09/09 : 	Modification du script pour gérér BZR
# 16/05/09 : 	Suppression de stacks
# 15/05/09 : 	Suppression des themes, ajout de dnd2share et modification de la detection de la distrib (smo)
# 18/04/09 :	Suppression de l'installation de Glitz (inutile depuis la v2)
# 16/11/08 : 	Refonte du script pour la version 2
# 13/11/08 :	Mise à jour des versions de cairo, glitz et pixman (pas de mises à jour auto)
# 22/10/08 :	Ajout de intrepid dans la détection des distribs
# 23/05/08 :	Ajout de la détection de la distrib et des plugins correspondant
# 20/05/08 : 	Ajout du choix du mode compilation (--full-compile pour forcer l'autoreconf)
# 28/03/08 : 	Ajout de l'icone pour XFCE et KDE (en test)
#				Suppression de l'icone lors de la désinstall
#				Téléchargement et recompilation de tous les plugins à chaque mise à jour de cairo-dock (en une passe)
# 25/03/08 : 	Ajout de l'applet Switcher pour test :)
# 22/03/08 :	Ajout de l'icone Cairo-Dock SVN dans le menu Applications de Gnome (uniquement)
# 20/03/08 :	Ajout des themes dans une branches séparés
# 16/02/08 : 	Ajout des paquets libxxf86vm-dev et libx11-dev danss les dépendances
# 12/02/08 : 	Ajout de la fonction de desinstallation de Glitz
#				Modification de la fonction de vérification des erreurs lors de l'install

DEBUG=0 # Attention, ne pas oublier de modifier !!! => à 0
DIR=$(pwd)
LOG_CAIRO_DOCK=$DIR/log.txt
SCRIPT="cairo-dock_bzr.sh"
SCRIPT_SAVE="cairo-dock_bzr.sh.save"
SCRIPT_NEW="cairo-dock_bzr.sh.new"
HOST="http://download.tuxfamily.org/glxdock/scripts/"
DOMAIN="glx-dock.org"

CAIRO_DOCK_CORE_LP_BRANCH="cairo-dock-core"
CAIRO_DOCK_PLUG_INS_LP_BRANCH="cairo-dock-plug-ins"
CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH="cairo-dock-plug-ins-extras"
CAIRO_DOCK_PLUG_INS_EXTRAS_USR="/usr/share/cairo-dock/plug-ins/Dbus/third-party"
CAIRO_DOCK_PLUG_INS_EXTRAS_HOME="$HOME/.config/cairo-dock/third-party"
CAIRO_DESKLET_LP_BRANCH="cairo-desklet"
BUILD_DIR="build"

#unset SSH_AUTH_SOCK # Evite de devoir retaper le passphrase
# ssh-add

#PLUGINS="alsaMixer Animated-icons Cairo-Penguin Clipper clock compiz-icon Dbus desklet-rendering dialog-rendering dnd2share dock-rendering drop-indicator dustbin GMenu icon-effect illusion keyboard-indicator logout mail motion-blur musicPlayer netspeed Network-Monitor powermanager quick-browser rhythmbox Scooby-Do shortcuts showDesklets showDesktop show-mouse slider stack System-Monitor switcher systray terminal tomboy Toons weather weblets wifi Xgamma xmms"
PLUGINS_GNOME="gnome-integration"
PLUGINS_GNOME_OLD="gnome-integration-old"
PLUGINS_XFCE="xfce-integration"

NEEDED_THIRD_PARTY="python valac ruby"
NEEDED_THIRD_PARTY_A_KARMIC="mono-gmcs libglib2.0-cil-dev libndesk-dbus1.0-cil-dev libndesk-dbus-glib1.0-cil-dev"
NEEDED="bzr build-essential pkg-config zenity gettext libcairo2-dev librsvg2-dev libdbus-glib-1-dev libxxf86vm-dev x11proto-xf86vidmode-dev libxrandr-dev libxcomposite-dev libxrender-dev libasound2-dev libxtst-dev libetpan-dev libexif-dev curl libglib2.0-dev cmake libcurl4-gnutls-dev libical-dev gdb libsensors4-dev libpulse-dev $NEEDED_THIRD_PARTY "
NEEDED_XFCE_OLD="libthunar-vfs-1-dev"
NEEDED_GNOME_OLD="libgnomevfs2-dev"
NEEDED_GNOME="gnome-session"
NEEDED_A_KARMIC="libxklavier-dev libdbusmenu-glib-dev libupower-glib-dev $NEEDED_THIRD_PARTY_A_KARMIC"
NEEDED_KARMIC="libxklavier-dev"
NEEDED_B_KARMIC="libxklavier12-dev"
NEEDED_A_LUCID="libzeitgeist-dev"
NEEDED_B_NATTY="libwebkit-dev"
NEEDED_A_NATTY="libgtk-3-dev libgl1-mesa-dev libglu1-mesa-dev libpango1.0-dev libdbusmenu-gtk3-dev libido3-0.1-dev libindicator3-dev libwebkitgtk-3.0-dev libvte-2.90-dev libgnome-menu-3-dev libwayland-dev" # GTK3
NEEDED_B_ONEIRIC="libgtk2.0-dev libgtkglext1-dev libdbusmenu-gtk-dev libido-0.1-dev libindicator-dev libwebkitgtk-dev libvte-dev libgnome-menu-dev" # GTK2

UPDATE=0
UPDATE_PLUG_INS=0
UPDATE_CAIRO_DOCK=0
ERROR=0
FULL_COMPILE=0
DISTRIB=""
INSTALL_CAIRO_DOCK_OK=1
CONFIGURE="-Denable-network-monitor=ON -Denable-doncky=ON -Denable-scooby-do=ON -Denable-disks=ON -Denable-global-menu=ON"

if test -e "$DIR/.bzr_dl"; then
	BZR_DL_MODE=`cat $DIR/.bzr_dl`
else
	BZR_DL_MODE=0
fi

BZR_REV_FILE_CORE="$DIR/.bzr_core"
BZR_REV_FILE_PLUG_INS="$DIR/.bzr_plug_ins"
BZR_REV_FILE_PLUG_INS_EXTRAS="$DIR/.bzr_plug_ins_extras"
BZR_REV_FILE_DESKLET="$DIR/.bzr_desklet"

TRAP_ON='echo -e "\e]0;$BASH_COMMAND\007"' # Afficher la commande en cours dans le terminal
TRAP_OFF="trap DEBUG"

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m" 
ROUGE="\\033[1;31m"


#######################################################################
#	Fonctions d'install
#######################################################################

install_cairo_dock() {

	rm -Rf $LOG_CAIRO_DOCK > /dev/null

	echo "Installation de Cairo-Dock du `date`" >> $LOG_CAIRO_DOCK

	echo "" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation : Cairo-Dock Core"

	install_cairo >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tError"
		check $LOG_CAIRO_DOCK "CD"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK

}

install_cairo() {
	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH

	rm -rf $BUILD_DIR
	mkdir $BUILD_DIR
	cd $BUILD_DIR

	if test `lsb_release -rs | cut -d. -f1` -ge 11 -o `grep -c "^Linux Mint" /etc/issue` -eq 1; then # natty or newer
		CONFIGURE_CORE="$CONFIGURE_CORE -Ddisable-gtk-grip=ON -Denable-desktop-manager=ON"
	elif test `grep -c "^Debian" /etc/issue` -eq 1; then
		CONFIGURE_CORE="$CONFIGURE_CORE -Denable-desktop-manager=ON"
	fi

	cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $CONFIGURE_CORE && make clean && make -j $(grep -c "^processor" /proc/cpuinfo)

	if [ $? -ne 0 ]; then
		cd $DIR
		return 1
	fi

	sudo rm -rf /usr/include/cairo-dock/* /usr/lib/libgldi.so*
	sudo rm -rf /usr/share/cairo-dock/*
	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH/$BUILD_DIR
	sudo make install
	if [ $? -ne 0 ]; then
		cd $DIR
		return 1
	fi
	cd $DIR
}


install_cairo_dock_plugins() {

	echo -e "$BLEU""Installation : Plug-Ins"

	echo "Installation des plug-ins du `date`" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK

	install_plugins >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tError"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK
}


install_plugins() {
	echo $(pwd)

	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
	echo $(pwd)
	
	
	rm -rf $BUILD_DIR
#	find -name "CMakeFiles" -exec rm -rf '{}' \; # virer les anciens caches => à effacer à l'avenir
#	find -name "*.cmake" -delete # à virer
#	rm -f CMakeCache.txt # à virer
#	find -name "Makefile" -delete # à virer
	mkdir $BUILD_DIR
	cd $BUILD_DIR

	echo "cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $CONFIGURE && make clean && make -j $(grep -c '^processor' /proc/cpuinfo)" > BUILD.sh
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $CONFIGURE && make clean && make -j $(grep -c '^processor' /proc/cpuinfo)
	
	if [ $? -ne 0 ]; then
		cd $DIR
		return 1
	fi

	sudo rm -rf /usr/lib/cairo-dock/* /usr/share/cairo-dock/plug-ins/* # en cas de changements de noms de lib ou de fichiers
	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH/$BUILD_DIR
	sudo make install
	if [ $? -ne 0 ]; then
		cd $DIR
		return 1
	fi
	cd $DIR
}


install_cairo_dock_plugins_extras() {
	echo -e "$BLEU""Installation : Plug-ins Extras"

	cd $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		echo -e "\tCheck dependences"
	sh dependences_deb.sh >> $LOG_CAIRO_DOCK
	if [ $? -ne 0 ]; then
		ERROR+=1
	fi

	echo "Installation des Plug-ins Extras du `date`" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK
	
	./install_applet.sh

	cd $DIR

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK
}


install_cairo_desklet() {

	echo "Installation de Cairo-Desklet" >> $LOG_CAIRO_DOCK

	echo "" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation : Cairo-Desklet"

	install_desklet >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tError"
		check $LOG_CAIRO_DOCK "CD"
	else
		echo -e "$VERT""\tSuccessfully Installed !"
	fi

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK

}

install_desklet() {
	cd $DIR/$CAIRO_DESKLET_LP_BRANCH

	rm -rf $BUILD_DIR
	mkdir $BUILD_DIR
	cd $BUILD_DIR
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug && make clean && make -j $(grep -c '^processor' /proc/cpuinfo)

	if [ $? -ne 0 ]; then
		return 1
	fi

	sudo make install
	cd ../..
}



install(){
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""C'est la première fois que vous installez la version BZR de Cairo-Dock"
		echo -e "\nGrâce à l'outil bzr, vous pouvez désormais télécharger les sources de plusieurs façons, notamment télécharger tout le contenu de la branche (si vous souhaitez ultérieurement procéder à des modifications et les publier sur des branches différents) ou uniquement la dernière révision (si vous voulez simplement tester les dernières révisions)\n""$VERT"

		BZR_DL_READ='0' # il nous faut une boucle pour prendre plus de cas
		while [ $BZR_DL_READ != '1' ] && [ $BZR_DL_READ != '2' ]; do
			echo -e "\t1 --> Télécharger la branche complète (~150Mo - pour les développeurs)"
			echo -e "\t2 --> Télécharger la dernière version (~20Mo - pour tous utilisateurs)"
			read BZR_DL_READ 
		done

		case $BZR_DL_READ in
			"1")
				echo -e "Mode choisi : branch\n"
				BZR_DL="branch"
				BZR_DL_MODE=1
			;;
			"" | "2")
				echo -e "Mode choisi : checkout --lightweight\n"
				BZR_DL="checkout --lightweight -q"
				BZR_DL_MODE=0
			;;
		esac

		echo $BZR_DL_MODE > $DIR/.bzr_dl

		echo -e "$BLEU""Téléchargement des données. Cette opération peut prendre quelques minutes"
		LG_DL_BG="Téléchargement de"
		LG_DL_END="Données téléchargées. L'installation va débuter\nCette opération peut prendre plusieurs minutes et ralentir votre système"
		LG_DL_ERROR="Impossible de se connecter au serveur de Launchpad, veuillez vérifier votre connexion internet ou retenter plus tard"
	else
		echo -e "$BLEU""Is it the first time that you install Cairo-Dock from BZR sources files?"
		echo -e "\nWith BZR you can download these sources files in two ways:\n\t* By downloading all the content (it's interesting to have a copy of the server branch if you want to make some modifications in this branch) or only the latest revision (if you just want to compile sources)\n""$VERT"

		BZR_DL_READ='0'
		while [ $BZR_DL_READ != '1' ] && [ $BZR_DL_READ != '2' ]; do
			echo -e "\t1 --> Download the complete branch (~150Mo - for dev.)"
			echo -e "\t2 --> Download only the last rev. (~20Mo - for all users)"
			read BZR_DL_READ 
		done

		case $BZR_DL_READ in
			"1")
				echo -e "Your choice: 'branch'\n"
				BZR_DL="branch"
				BZR_DL_MODE=1
			;;
			"" | "2")
				echo -e "Your choice: 'checkout --lightweight'\n"
				BZR_DL="checkout --lightweight -q"
				BZR_DL_MODE=0
			;;
		esac

		echo $BZR_DL_MODE > $DIR/.bzr_dl

		echo -e "$BLEU""The download will begin. Please wait ;)"
		LG_DL_BG="Download of"
		LG_DL_END="Sources files downloaded. The installation will begin\nThis compilation can take some time and slow down your system"
		LG_DL_ERROR="It seems that there is some problems. Please check your Internet connexion or retry later!"
	fi

	echo -e "$NORMAL"
	sleep 2

	if [ ! -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Cairo-Dock Core"
		bzr $BZR_DL lp:$CAIRO_DOCK_CORE_LP_BRANCH 
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		else
			NEW_CORE_VERSION=`bzr revno -q $CAIRO_DOCK_CORE_LP_BRANCH`
			echo $NEW_CORE_VERSION > $BZR_REV_FILE_CORE
			echo -e "\nCairo-Dock-Core : rev $NEW_CORE_VERSION \n"
			echo -e "\nCairo-Dock-Core : rev $NEW_CORE_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL" ## PLUG-INS ##

	if [ ! -d $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Plug-Ins"
		bzr $BZR_DL lp:$CAIRO_DOCK_PLUG_INS_LP_BRANCH 
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		else
			NEW_PLUG_INS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_LP_BRANCH`
			echo $NEW_PLUG_INS_VERSION > $BZR_REV_FILE_PLUG_INS
			echo -e "\nCairo-Dock-Plug-ins : rev $NEW_PLUG_INS_VERSION \n"
			echo -e "\nCairo-Dock-Plug-ins : rev $NEW_PLUG_INS_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL" ## PLUG-INS EXTRAS ##

	if [ ! -d $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Plug-Ins Extras"
		bzr $BZR_DL lp:$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		else
			NEW_PLUG_INS_EXTRAS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH`
			echo $NEW_PLUG_INS_EXTRAS_VERSION > $BZR_REV_FILE_PLUG_INS_EXTRAS
			echo -e "\nCairo-Dock-Plug-ins-Extras : rev $NEW_PLUG_INS_EXTRAS_VERSION \n"
			echo -e "\nCairo-Dock-Plug-ins-Extras : rev $NEW_PLUG_INS_EXTRAS_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL" ## CAIRO-DESKLET ##

	if [ ! -d $DIR/$CAIRO_DESKLET_LP_BRANCH ]; then
		echo -e "$BLEU""$LG_DL_BG Desklets"
		bzr $BZR_DL lp:$CAIRO_DESKLET_LP_BRANCH
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		else
			NEW_DESKLET_VERSION=`bzr revno -q $CAIRO_DESKLET_LP_BRANCH`
			echo $NEW_DESKLET_VERSION > $BZR_REV_FILE_DESKLET
			echo -e "\nCairo-Desklets : rev $NEW_DESKLET_VERSION \n"
			echo -e "\nCairo-Desklets : rev $NEW_DESKLET_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	fi

	echo -e "$NORMAL"
	echo -e "$BLEU""$LG_DL_END"
	echo -e "$NORMAL"

	sleep 5

	install_cairo_dock

	install_cairo_dock_plugins

	install_cairo_dock_plugins_extras

	install_cairo_desklet

	check $LOG_CAIRO_DOCK "CD"
}


reinstall(){
	FULL_COMPILE=1

	install_cairo_dock

	install_cairo_dock_plugins

	install_cairo_dock_plugins_extras

	install_cairo_desklet

	check $LOG_CAIRO_DOCK "CD"
}



#######################################################################
#	Fonctions de désinstallation
#######################################################################


uninstall() {
	echo "Uninstallation of Cairo-Dock and its plug-ins"

	# Core
	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH/$BUILD_DIR
	sudo make uninstall > $LOG_CAIRO_DOCK 2>&1
	cd ..
	rm -rf $BUILD_DIR
	cd ..

	# Plug-ins
	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH/$BUILD_DIR
	sudo make uninstall >> $LOG_CAIRO_DOCK 2>&1
	cd ..
	rm -rf $BUILD_DIR
	cd ..

	# Extras
	sudo rm -r $CAIRO_DOCK_PLUG_INS_EXTRAS_USR

	# Desklet
	cd $DIR/$CAIRO_DESKLET_LP_BRANCH/$BUILD_DIR
	sudo make uninstall >> $LOG_CAIRO_DOCK 2>&1
	cd ..
	rm -rf $BUILD_DIR
	cd ..

	if [ -e /usr/share/applications/cairo-dock_svn.desktop ]; then
		sudo rm -f /usr/share/applications/cairo-dock_svn.desktop
	fi
	echo "La désinstallation à été effectuée / Uninstallation finished"
	echo ""
	echo "Cependant, votre dossier de configuration est toujours présent."
	echo "Celui-ci se trouve dans votre ~/.config et se nomme cairo-dock (attention c'est un dossier caché)."
	echo "Vous pouvez le supprimer une fois la désinstallation effectuée"
}



#######################################################################
#	Fonctions de mises à jour
#######################################################################

update(){
	if [ $LG -eq 0 ]; then
		LG_SEARCH_FOR="Recherche des mises à jour pour"
		LG_UP_FOUND="Une mise à jour a été détectée pour"
	else
		LG_SEARCH_FOR="Check if there is an update for"
		LG_UP_FOUND="An update has been detected for"
	fi

	echo -e "$BLEU""$LG_SEARCH_FOR Cairo-Dock"
	if test -e "$BZR_REV_FILE_CORE"; then
		ACTUAL_CORE_VERSION=`cat "$BZR_REV_FILE_CORE"`
	else
		echo 0 > "$BZR_REV_FILE_CORE"
		ACTUAL_CORE_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH
		BZR_UP="pull"
		bzr $BZR_UP lp:$CAIRO_DOCK_CORE_LP_BRANCH
		NEW_CORE_VERSION=`bzr revno -q`
		cd $DIR/
	else
		BZR_UP="update -q"
		NEW_CORE_VERSION=`bzr revno -q $CAIRO_DOCK_CORE_LP_BRANCH`
		if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_CORE_LP_BRANCH
		fi
	fi

	echo $NEW_CORE_VERSION > $BZR_REV_FILE_CORE
	echo -e "\nCairo-Dock-Core : rev $ACTUAL_CORE_VERSION -> $NEW_CORE_VERSION \n"
	echo -e "\nCairo-Dock-Core : rev $ACTUAL_CORE_VERSION -> $NEW_CORE_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
		DIFF_CORE_VERSION=$(($NEW_CORE_VERSION-$ACTUAL_CORE_VERSION))
		if [ $DIFF_CORE_VERSION -le 10 ]; then
			bzr log -l$DIFF_CORE_VERSION --line $CAIRO_DOCK_CORE_LP_BRANCH
		else
			bzr log -l1 --line $CAIRO_DOCK_CORE_LP_BRANCH
		fi
		echo -e "$VERT""\n$LG_UP_FOUND Cairo-Dock"
		sleep 1
		install_cairo_dock
		UPDATE_CAIRO_DOCK=1
		UPDATE=1
		#echo -e "$VERT""Mise à jour et recompilation des plug-ins suite à la mise à jour de cairo-dock"
		echo -e "$NORMAL"""
	else
		echo -e "$NORMAL"""
	fi

	## PLUG-INS ##

	echo -e "$BLEU""\n$LG_SEARCH_FOR Plug-ins"
	if test -e "$BZR_REV_FILE_PLUG_INS"; then
		ACTUAL_PLUG_INS_VERSION=`cat "$BZR_REV_FILE_PLUG_INS"`
	else
		echo 0 > "$BZR_REV_FILE_PLUG_INS"
		ACTUAL_PLUG_INS_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
		bzr $BZR_UP lp:$CAIRO_DOCK_PLUG_INS_LP_BRANCH
		NEW_PLUG_INS_VERSION=`bzr revno -q`
		cd $DIR/
	else
		NEW_PLUG_INS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_LP_BRANCH`
		if [ $ACTUAL_PLUG_INS_VERSION -ne $NEW_PLUG_INS_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_PLUG_INS_LP_BRANCH
		fi
	fi

	echo $NEW_PLUG_INS_VERSION > "$BZR_REV_FILE_PLUG_INS"
	echo -e "\nCairo-Dock-Plug-Ins : rev $ACTUAL_PLUG_INS_VERSION -> $NEW_PLUG_INS_VERSION \n"
	echo -e "\nCairo-Dock-Plug-Ins : rev $ACTUAL_PLUG_INS_VERSION -> $NEW_PLUG_INS_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_PLUG_INS_VERSION -ne $NEW_PLUG_INS_VERSION ]; then
		DIFF_PLUG_INS_VERSION=$(($NEW_PLUG_INS_VERSION-$ACTUAL_PLUG_INS_VERSION))
		if [ $DIFF_PLUG_INS_VERSION -le 10 ]; then
			bzr log -l$DIFF_PLUG_INS_VERSION --line $CAIRO_DOCK_PLUG_INS_LP_BRANCH
		else
			bzr log -l1 --line $CAIRO_DOCK_PLUG_INS_LP_BRANCH
		fi
		echo -e "$VERT""\n$LG_UP_FOUND Plug-Ins"
		install_cairo_dock_plugins
		UPDATE=1
	elif [ $UPDATE_CAIRO_DOCK -eq 1 ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$VERT""Recompilation des plug-ins suite à la mise à jour de Cairo-Dock Core"
		else
			echo -e "$VERT""Recompilation due to some changes of Cairo-Dock API"
		fi
		install_cairo_dock_plugins
	fi
	echo -e "$NORMAL"

	## PLUG-INS EXTRAS ##

	echo -e "$BLEU""\n$LG_SEARCH_FOR Plug-ins Extras"
	if test -e "$BZR_REV_FILE_PLUG_INS_EXTRAS"; then # le fichier existe
		ACTUAL_PLUG_INS_EXTRAS_VERSION=`cat "$BZR_REV_FILE_PLUG_INS_EXTRAS"`
	else
		echo 0 > "$BZR_REV_FILE_PLUG_INS_EXTRAS"
		ACTUAL_PLUG_INS_EXTRAS_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		bzr $BZR_UP lp:$CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		NEW_PLUG_INS_EXTRAS_VERSION=`bzr revno -q`
		cd $DIR/
	else
		NEW_PLUG_INS_EXTRAS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH`
		if [ $ACTUAL_PLUG_INS_EXTRAS_VERSION -ne $NEW_PLUG_INS_EXTRAS_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		fi
	fi

	echo $NEW_PLUG_INS_EXTRAS_VERSION > "$BZR_REV_FILE_PLUG_INS_EXTRAS"
	echo -e "\nCairo-Dock-Plug-Ins-Extras : rev $ACTUAL_PLUG_INS_EXTRAS_VERSION -> $NEW_PLUG_INS_EXTRAS_VERSION \n"
	echo -e "\nCairo-Dock-Plug-Ins-Extras : rev $ACTUAL_PLUG_INS_EXTRAS_VERSION -> $NEW_PLUG_INS_EXTRAS_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_PLUG_INS_EXTRAS_VERSION -ne $NEW_PLUG_INS_EXTRAS_VERSION ]; then
		DIFF_PLUG_INS_EXTRAS_VERSION=$(($NEW_PLUG_INS_EXTRAS_VERSION-$ACTUAL_PLUG_INS_EXTRAS_VERSION))
		if [ $DIFF_PLUG_INS_EXTRAS_VERSION -le 10 ]; then
			bzr log -l$DIFF_PLUG_INS_EXTRAS_VERSION --line $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		else
			bzr log -l1 --line $CAIRO_DOCK_PLUG_INS_EXTRAS_LP_BRANCH
		fi
		echo -e "$VERT""\n$LG_UP_FOUND Plug-Ins Extras"
		install_cairo_dock_plugins_extras
		UPDATE=1
	fi

	## CAIRO-DESKLET ##

	echo -e "$BLEU""\n$LG_SEARCH_FOR Desklets"
	if test -e "$BZR_REV_FILE_DESKLET"; then # le fichier existe
		ACTUAL_DESKLET_VERSION=`cat "$BZR_REV_FILE_DESKLET"`
	else
		echo 0 > "$BZR_REV_FILE_DESKLET"
		ACTUAL_DESKLET_VERSION=0
	fi

	if [ ! -d $DIR/$CAIRO_DESKLET_LP_BRANCH ]; then # desklet a été ajouté après
		echo -e "$BLEU""$LG_DL_BG Desklets"
		if [ $BZR_DL_MODE -eq 1 ]; then
			bzr branch lp:$CAIRO_DESKLET_LP_BRANCH
		else
			bzr checkout --lightweight lp:$CAIRO_DESKLET_LP_BRANCH
		fi
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""$LG_DL_ERROR"
			read
			exit
		else
			NEW_DESKLET_VERSION=`bzr revno -q $CAIRO_DESKLET_LP_BRANCH`
			echo $NEW_DESKLET_VERSION > $BZR_REV_FILE_DESKLET
			echo -e "\nCairo-Desklets : rev $NEW_DESKLET_VERSION \n"
			echo -e "\nCairo-Desklets : rev $NEW_DESKLET_VERSION \n" >> $LOG_CAIRO_DOCK
		fi
	elif [ $BZR_DL_MODE -eq 1 ]; then
		cd $DIR/$CAIRO_DESKLET_LP_BRANCH
		bzr $BZR_UP lp:$CAIRO_DESKLET_LP_BRANCH
		NEW_DESKLET_VERSION=`bzr revno -q`
		cd $DIR/
	else
		NEW_DESKLET_VERSION=`bzr revno -q $CAIRO_DESKLET_LP_BRANCH`
		if [ $ACTUAL_DESKLET_VERSION -ne $NEW_DESKLET_VERSION ]; then
			bzr $BZR_UP $CAIRO_DESKLET_LP_BRANCH
		fi
	fi

	echo $NEW_DESKLET_VERSION > "$BZR_REV_FILE_DESKLET"
	echo -e "\nCairo-Desklet : rev $ACTUAL_DESKLET_VERSION -> $NEW_DESKLET_VERSION \n"
	echo -e "\nCairo-Desklet : rev $ACTUAL_DESKLET_VERSION -> $NEW_DESKLET_VERSION \n" >> $LOG_CAIRO_DOCK

	if [ $ACTUAL_DESKLET_VERSION -ne $NEW_DESKLET_VERSION ]; then
		DIFF_DESKLET_VERSION=$(($NEW_DESKLET_VERSION-$ACTUAL_DESKLET_VERSION))
		if [ $DIFF_DESKLET_VERSION -le 10 ]; then
			bzr log -l$DIFF_DESKLET_VERSION --line $CAIRO_DESKLET_LP_BRANCH
		else
			bzr log -l1 --line $CAIRO_DESKLET_LP_BRANCH
		fi
		echo -e "$VERT""\n$LG_UP_FOUND Desklet"
		install_cairo_desklet
		UPDATE=1
	elif [ $UPDATE_CAIRO_DOCK -eq 1 ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$VERT""Recompilation suite à la mise à jour de l'API Cairo-Dock"
		else
			echo -e "$VERT""Recompilation due to some changes of Cairo-Dock API"
		fi
		install_cairo_desklet
	fi

	## CHECK ##

	echo -e "$NORMAL"

	if [ $UPDATE -eq 1 ]; then
	    check $LOG_CAIRO_DOCK "CD"
	else
		if [ $LG -eq 0 ]; then
			echo -e "$BLEU""Pas de mise à jour disponible"
			echo -e "$NORMAL"
			if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Pas de mise à jour" int32:8 string:"class=$COLORTERM"
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		else
			echo -e "$BLEU""No update available"
			echo -e "$NORMAL"
			if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: no update" int32:8 string:"class=$COLORTERM"
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		fi
	fi
}



#######################################################################
#	Fonctions de vérifications
#######################################################################

check() {
	if [ $LG -eq 0 ]; then
		echo -e "$NORMAL""Vérification de l'intégrité de l'installation"
		LG_INSTALL_OK="L'installation s'est terminée correctement."
	else
		echo -e "$NORMAL""Verification of the installation"
		LG_INSTALL_OK="Successfully installed"
	fi
	sleep 1

	if [ $2 = "CD" ]; then
		if [ $ERROR -ne 0 ]; then
			echo -e "$ROUGE"
			if [ $LG -eq 0 ]; then
				echo "Des erreurs ont été détéctées lors de l'installation."
				egrep -i "( error| Erreur)" $1 | grep -v error.svg
				echo -e "Veuillez consulter le fichier log.txt pour plus d'informations et vous rendre sur le forum de cairo-dock pour reporter l'erreur dans la section \"Version BZR\". Merci !\n"
			else
				echo "Some errors have been detected during the installation"
				egrep -i "( error| Erreur)" $1 | grep -v error.svg
				echo -e "Please keep a copy of the file 'log.txt' and report the bug on our forum (http://www.glx-dock.org) on the section \"Version BZR\". Thank you!\n"
			fi
			check_version
			echo -e "$NORMAL"
			if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Compilation error
Cairo-Dock: Erreur à la compilation
	Please report this bug !=> http://www.glx-dock.org" int32:0 string:"class=$COLORTERM"
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		else
			echo -e "$VERT"
			echo "$LG_INSTALL_OK"
			echo -e "$NORMAL"
			if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
				dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"Cairo-Dock: Successfully Updated
Cairo-Dock: Mis à jour avec succès" int32:8 string:"class=$COLORTERM"
			else
				zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
			fi
		fi
	fi
}

testping () {
	if [ "`ping -c1 $DOMAIN |grep received|cut -d, -f2`" != " 1 received" ]
	then
		echo -e "$ROUGE"
		if [ $LG -eq 0 ]; then
			echo "Le test de connexion vers Internet à échouée"
			echo "Réglez ce problème avant de poursuivre ce script"
		else
			echo "Internet Connexion Error"
			echo "It's required if you want to access to our server"
		fi
		echo -e "$NORMAL"
		read
		exit
	else
		echo -e "$VERT""\nInternet Connexion\t [ OK ]\n""$NORMAL"
	fi
}

check_new_script() {
	cp $SCRIPT $SCRIPT_SAVE #pour moi :)

	if [ $LG -eq 0 ]; then
		echo -e "$NORMAL""Test de la connexion Internet (Obligatoire)"
		testping
		echo "Vérification de la disponibilité d'un nouveau script"
		LG_UPDL="Une mise à jour a été téléchargée"
		LG_CLICKHERE="Cliquez sur Ok pour relancer le script."
		LG_SCRIPT="Vous possédez la dernière version du script de M@v"
	else
		echo -e "$NORMAL""Connexion Internet test (Required)"
		testping
		echo "It checks if a new script exists"
		LG_UPDL="An update has been downloaded"
		LG_CLICKHERE="Click here in order to relauch the script."
		LG_SCRIPT="You have the latest version of M@v'script"
	fi
	wget $HOST/$SCRIPT -q -O $SCRIPT_NEW
	diff $SCRIPT $SCRIPT_NEW >/dev/null
	if [ $? -eq 1 ]; then
		echo -e "$ROUGE"
		echo "$LG_UPDL"
		echo -e "$NORMAL"
		mv $SCRIPT_NEW $SCRIPT
		sudo chmod u+x $SCRIPT
		zenity --info --title=Cairo-Dock --text="$LG_CLICKHERE"
		./$SCRIPT
		exit
	else
		clear
		echo -e "$VERT""\n\t$LG_SCRIPT"
	fi
	echo -e "$NORMAL"
	rm $SCRIPT_NEW

}


#######################################################################
#	Autres fonctions
#######################################################################


detect_env_graph() 
{
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Détection de l'environnement graphique"
		## kde 3/4
		if [[ `ps aux | grep -e "[k]smserver"` ]]; then
		   if [[ `ps aux | grep -e "[k]ded4" ` ]]; then
		       ENV=2;
		       echo -e "$VERT""Votre environnement est KDE 4 \n"
		   else
		       ENV=2;
		       echo -e "$VERT""Votre environnement est KDE 3 \n"
		   fi
		## gnome
		elif test -n "$GNOME_DESKTOP_SESSION_ID" -o `ps aux | grep -c "[g]nome-settings-daemon"` -gt 0; then
		   ENV=1;
		   if [ $DISTRIB = "gutsy" ]; then
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME_OLD
		   else
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME
		   fi
		   echo -e "$VERT""Votre environnement est GNOME \n"
		## xfce4
		elif [[ `ps aux | grep -e "[x]fce-mcs-manager"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Votre environnement est XFCE 4 \n"
		elif [[ `ps aux | grep -e "[x]fce"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Votre environnement est XFCE \n"
		else
		   echo -e "Type de session locale non détéctée, ou non supportée vous utilisez e17, fluxbox ???... \n"
		fi
	else
		echo -e "$BLEU""What's your DE (Desktop Environment)"
		## kde 3/4
		if [[ `ps aux | grep -e "[k]smserver"` ]]; then
		   if [[ `ps aux | grep -e "[k]ded4" ` ]]; then
		       ENV=2;
		       echo -e "$VERT""Your Desktop Environment is KDE 4 \n"
		   else
		       ENV=2;
		       echo -e "$VERT""Your Desktop Environment is KDE 3 \n"
		   fi
		## gnome
		elif test -n "$GNOME_DESKTOP_SESSION_ID" -o `ps aux | grep -c "[g]nome-settings-daemon"` -gt 0; then
		   ENV=1;
		   if [ $DISTRIB = "gutsy" ]; then
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME_OLD
		   else
		       PLUGINS_INTEGRATION=$PLUGINS_GNOME
		   fi
		   echo -e "$VERT""Your Desktop Environment is GNOME \n"
		## xfce4
		elif [[ `ps aux | grep -e "[x]fce-mcs-manager"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Your Desktop Environment is XFCE 4 \n"
		elif [[ `ps aux | grep -e "xfce"`  ]]; then
		   ENV=3;
		   PLUGINS_INTEGRATION=$PLUGINS_XFCE
		   echo -e "$VERT""Your Desktop Environment is XFCE \n"
		else
		   echo -e "You don't use a common Desktop Environment, don't hesitate to report any bugs ;) \n"
		fi
	fi

	return $ENV

} 

detect_distrib() {
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Détection de la distribution"
	else
		echo -e "$BLEU""What's your distribution"
	fi
	DISTRIB=$(grep -e DISTRIB_CODENAME /etc/lsb-release | cut -d= -f2)

	if [ $LG -eq 0 ]; then
		if [ -n $DISTRIB ]; then
			echo -e "$VERT""Votre distribution est $(grep -e DISTRIB_DESCRIPTION /etc/lsb-release | cut -d= -f2) ($DISTRIB)"
			echo -e "$NORMAL"
		elif [ $(grep -c "^Debian" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Votre distribution est Debian"
			echo -e "$NORMAL"
		elif [ $(grep -c "^Linux Mint" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Votre distribution est Linux Mint"
			echo -e "$NORMAL"
		else 
			echo -e "$ROUGE""Impossible de déterminer la distribution\nATTENTION : Ce script est prévu pour Ubuntu et Debian\nWARNING : This script is provided for Ubuntu and Debian"
			echo -e "$NORMAL"
		fi
	else
		if [ -n $DISTRIB ]; then
			echo -e "$VERT""Your distribution is $(grep -e DISTRIB_DESCRIPTION /etc/lsb-release | cut -d= -f2) ($DISTRIB)"
			echo -e "$NORMAL"
		elif [ $(grep -c "^Debian" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Your distribution is Debian"
			echo -e "$NORMAL"
		elif [ $(grep -c "^Linux Mint" /etc/issue) -eq 1 ]; then
			echo -e "$VERT""Your distribution is Linux Mint"
			echo -e "$NORMAL"
		else 
			echo -e "$ROUGE""WARNING : This script is provided for Ubuntu and Debian"
			echo -e "$NORMAL"
		fi
	fi
}


check_dependancies() {
	if [ $LG -eq 0 ]; then
		echo -e "$BLEU""Vérification des paquets nécessaires à la compilation" 
	else
		echo -e "$BLEU""Check up: Packages needed for the compilation" 
	fi

	dpkg -s sudo |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then #Debian
			if [ $LG -eq 0 ]; then
				echo -e "$ROUGE"" Le paquet 'sudo' n'est pas installé, veuillez l'installer avant de continuer.""$NORMAL"""
			else
				echo -e "$ROUGE"" 'sudo' package isn't installed. Please install it.""$NORMAL"""
			fi
			read
			exit
		fi

	sudo -v # Pour que Nochka puisse aller regarder la tv en attendant la fin de la compilation ;-)

	if [ $(grep -c "^Ubuntu" /etc/issue) -eq 1 ]; then # pour ne pas avoir un message d'erreur sur les autres
		# VERSIONS
		if [ $DISTRIB = 'karmic' ]; then #karmic
			NEEDED="$NEEDED $NEEDED_KARMIC "
		elif [ `lsb_release -rs | cut -d. -f1` -ge 10 ]; then #lucid ou nouveau
			NEEDED="$NEEDED $NEEDED_A_KARMIC "
		else
			NEEDED="$NEEDED $NEEDED_B_KARMIC " #karmic ou plus vieux
		fi
		if test `lsb_release -rs | cut -d. -f1` -ge 10 -a ! "$DISTRIB" = "lucid"; then #maverick ou nouveau
			NEEDED="$NEEDED $NEEDED_A_LUCID "
		else #lucid ou ancien
			CONFIGURE="$CONFIGURE -Denable-vala-support=OFF"
			if [ $ENV -eq 1 ]; then #Gnome
				NEEDED="$NEEDED $NEEDED_GNOME_OLD "
			elif [ $ENV -eq 3 ]; then #XFCE
				NEEDED="$NEEDED $NEEDED_XFCE_OLD "
			fi
		fi
		if test `lsb_release -rs | cut -d. -f1` -ge 11; then #natty ou nouveau
			NEEDED="$NEEDED $NEEDED_A_MAVERICK "
			CONFIGURE="$CONFIGURE -Denable-vala-support=ON"
			if test ! "$DISTRIB" = "natty"; then # oneiric ou nouveau
				NEEDED="$NEEDED $NEEDED_A_NATTY "
			else
				NEEDED="$NEEDED $NEEDED_B_ONEIRIC "
			fi
		else
			NEEDED="$NEEDED $NEEDED_B_NATTY $NEEDED_B_ONEIRIC "
		fi
		if test `lsb_release -rs | cut -d. -f1` -ge 12; then # precise or newer
			CD_PACKAGES_OTHER="libgldi-dev libgldi3 cairo-dock-plug-ins-dbus-interface-python cairo-dock-plug-ins-dbus-interface-mono cairo-dock-plug-ins-dbus-interface-ruby cairo-dock-plug-ins-dbus-interface-vala"
		else
			CD_PACKAGES_OTHER="cairo-dock-dev"
		fi

		# ENVIRONMENTS
		if [ $ENV -eq 1 ]; then #Gnome
			NEEDED="$NEEDED $NEEDED_GNOME "
		fi
	else # on test tout...
		NEEDED="$NEEDED $NEEDED_THIRD_PARTY $NEEDED_THIRD_PARTY_A_KARMIC $NEEDED_A_KARMIC $NEEDED_KARMIC $NEEDED_A_LUCID $NEEDED_A_MAVERICK $NEEDED_B_NATTY $NEEDED_A_NATTY $NEEDED_B_ONEIRIC"
		CONFIGURE="$CONFIGURE -Denable-vala-support=ON"
		CD_PACKAGES_OTHER="libgldi-dev libgldi3 cairo-dock-plug-ins-dbus-interface-python cairo-dock-plug-ins-dbus-interface-mono cairo-dock-plug-ins-dbus-interface-ruby cairo-dock-plug-ins-dbus-interface-vala"
	fi

	paquetsPresent=""
	cd_packages=""
	paquetsOK=""

	for tested in $NEEDED
	do
		dpkg -s $tested |grep installed |grep "install ok" > /dev/null
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""This package $tested isn't installed : Installation""$NORMAL"""
			paquetsPresent="$paquetsPresent $tested"
			# sudo apt-get install -qq $tested  >> $LOG_CAIRO_DOCK
		fi
	done

	for testPkg in $paquetsPresent; do
		sudo apt-get install -s $testPkg > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			paquetsOK="$paquetsOK $testPkg"
		else
			echo -e "$ROUGE""This package $testPkg isn't available""$NORMAL"""
		fi
	done

	if [ "$paquetsOK" != "" ]; then
		sudo apt-get install -y --force-yes -m -q $paquetsOK
	fi

	CD_PACKAGES_BASE="cairo-dock cairo-dock-plug-ins cairo-dock-core cairo-dock-plug-ins-data cairo-dock-data cairo-dock-plug-ins-integration"
	# check CD
	# juste plus rapide que de tester un à un...
	DPKG_SELECTIONS=`dpkg --get-selections`
	for cd_package in $CD_PACKAGES_BASE $CD_PACKAGES_OTHER; do
		if [ `echo $DPKG_SELECTIONS | grep "$cd_package" | grep -c install` -ge 1 ]; then  #CD est installé par paquet
			cd_packages="$cd_packages $cd_package"
		fi
	done
	if test -n "$cd_packages"; then
		if [ $LG -eq 0 ]; then
			echo -e "$ROUGE"" Désinstallation des paquets '$cd_packages' ""$NORMAL"""
		else
			echo -e "$ROUGE""Uninstallation of these packages: '$cd_packages'.""$NORMAL"""
		fi
		sudo apt-get purge -q $cd_packages
		sudo apt-get autoremove --purge -q
	fi

	if [ $LG -eq 0 ]; then
		echo -e "$VERT""Vérification [ OK ]"
	else
		echo -e "$VERT""Verification [ OK ]"
	fi
	echo -e "$NORMAL"""
	sleep 1
}


ppa_weekly() {
	if [ $(grep -c "^Ubuntu" /etc/issue) -eq 1 ]; then
		LSB_RELEASE=`lsb_release -sc`
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly/ubuntu $LSB_RELEASE main ## Cairo-Dock-PPA-Weekly"
		sudo -v
		W_SUDO="sudo"
	elif [ $(grep -c "^Linux Mint" /etc/issue) -eq 1 ]; then
		PPA="deb http://ppa.launchpad.net/cairo-dock-team/weekly-debian/ubuntu jaunty main ## Cairo-Dock-PPA-Weekly for Debian and the others forks"
		sudo -v
		W_SUDO="sudo"
	else
		if [ $LG -eq 0 ]; then
			echo -e "$ROUGE""Désolé, seuls Ubuntu est supportés. En cas de problème, merci de nous contacter sur notre forum.""$NORMAL"""
		else
			echo -e "$ROUGE""Sorry but only Ubuntu is supported. If there is a problem, please contact us on our forum.""$NORMAL"""
		fi
		read
		exit
	fi

	if [ -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		if [ $LG -eq 0 ]; then
			echo -e "$BLEU""Désinstallation de la version BZR"
		else
			echo -e "$BLEU""Uninstallation of the BZR version"
		fi
		echo -e "$NORMAL"""
		uninstall
	fi

	echo -e "$VERT""PPA weekly - Repository"
	echo "Ajout du dépôt ppa weekly" >> $LOG_CAIRO_DOCK
	echo -e "$NORMAL"""

	echo -e "\nAjout du dépôt\n" >> $LOG_CAIRO_DOCK
	echo "$PPA" | $W_SUDO tee -a /etc/apt/sources.list  >> $LOG_CAIRO_DOCK
	echo -e "\nAjout de la clé\n" >> $LOG_CAIRO_DOCK
	$W_SUDO apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E80D6BF5 >> $LOG_CAIRO_DOCK
	echo -e "\nMise à jour de la apt list\n" >> $LOG_CAIRO_DOCK
	$W_SUDO apt-get update  >> $LOG_CAIRO_DOCK
	echo -e "\nInstallation\n" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation des paquets Cairo-Dock, version instable"
	echo -e "$NORMAL"""
	$W_SUDO apt-get install cairo-dock  >> $LOG_CAIRO_DOCK
	zenity --info --title=Cairo-Dock --text="$LG_CLOSE"
}


about() {
	echo -e "Author : Mav (2008-2009)\n\t matttbe (2009-2012)"
	echo -e "Contact : mav@glx-dock.org\n\t matttbe@glx-dock.org"
}

check_version() {
	echo -e "Cairo-Dock Core: `cat $BZR_REV_FILE_CORE`"
	echo -e "Cairo-Dock Plug-ins: `cat $BZR_REV_FILE_PLUG_INS`"
	echo -e "Cairo-Dock Plug-ins Extras: `cat $BZR_REV_FILE_PLUG_INS_EXTRAS`"
	echo -e "Cairo-Desklet: `cat $BZR_REV_FILE_DESKLET`"
}

echo $LANG | grep -c "^fr" > /dev/null
if [ $? -eq 0 ]; then 
	LG=0
	LG_CLOSE="Cliquez sur Ok pour fermer le terminal."
else
	LG=1
	LG_CLOSE="Click on Ok in order to close the terminal."
fi

if [ $DEBUG -ne 1 ]; then
	# if [ `date +%Y%m%d` -gt 20100220 ];then
		check_new_script
	# fi
fi

if [ "$1" = "smo_install" -o "$1" = "-i" -o "$1" = "-I" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	install
elif [ "$1" = "smo_update" -o "$1" = "-u" -o "$1" = "-U" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	update
elif [ "$1" = "-R" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	reinstall
elif [ "$1" = "-e" ]; then # possibilité d'ajouter des args
	ARGS=$2
	echo "$ARGS" > $DIR/.args
	if [ $(grep -c "enable" $DIR/.args) -eq 1 ]; then # s'il y a au-moins un enable
		CONFIGURE="$CONFIGURE $ARGS"
	else
		for arg in $ARGS
		do
			CONFIGURE="$CONFIGURE -Denable-${arg}=ON"
		done
	fi
	rm -f $DIR/.args
fi

if [ $LG -eq 0 ]; then
	echo -e "$NORMAL""Script d'installation de la version BZR de Cairo-Dock (FR)\n"
	echo -e "Veuillez choisir l'option d'installation : \n"

	if [ -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "\t1 --> Mettre à jour la version BZR installée"
		echo -e "\t2 --> Reinstaller la version BZR actuelle"
		echo -e "\t3 --> Désinstaller la version BZR"
		echo -e "\t4 --> Installer le ppa weekly au lieu de BZR "
		echo -e "\t5 --> Afficher les actuelles numéros de révision."
		echo -e "\t6 --> A propos"

		echo -e "\nVotre choix : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				update
			;;

			"2")
				detect_distrib
				detect_env_graph
				check_dependancies
				reinstall
			;;

			"3")
				uninstall
				zenity --info --title=Cairo-Dock --text="Cairo-Dock a été désinstallé, veuillez lire le message dans le terminal"
				exit
			;;

			"4")
				ppa_weekly
			;;

			"5")
				check_version
			;;

			"6")
				about
			;;
		esac
	else
		echo -e "\t1 --> Installer la version BZR pour la première fois"
		echo -e "\t2 --> Installer le ppa weekly au lieu de BZR"
		echo -e "\t3 --> A propos"

		echo -e "\nVotre choix : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				install
			;;

			"2")
				ppa_weekly
			;;

			"3")
				about
			;;
		esac
	fi
else
		echo -e "$NORMAL""Installation script for BZR version of Cairo-Dock (EN)\n"
	echo -e "What do you want : \n"

	if [ -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "\t1 --> Update Cairo-Dock to the latest BZR revision"
		echo -e "\t2 --> Reinstall the current version"
		echo -e "\t3 --> Uninstall the current version"
		echo -e "\t4 --> Install weekly ppa instead of BZR"
		echo -e "\t5 --> Display the current installed revision"
		echo -e "\t6 --> About this script"

		echo -e "\nYour choice : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				update
			;;

			"2")
				detect_distrib
				detect_env_graph
				check_dependancies
				reinstall
			;;

			"3")
				uninstall
				zenity --info --title=Cairo-Dock --text="Cairo-Dock has been uninstalled, please read the message into the terminal"
			;;

			"4")
				ppa_weekly
			;;

			"5")
				check_version
			;;

			"6")
				about
			;;
		esac
	else
		echo -e "\t1 --> Install the current version of Cairo-Dock from BZR server for the first time (Install)"
		echo -e "\t2 --> Install weekly ppa instead of BZR"
		echo -e "\t3 --> About this script"

		echo -e "\nYour choice : "
		read answer_menu

		case $answer_menu in

			"1")
				detect_distrib
				detect_env_graph
				check_dependancies
				install
			;;

			"2")
				ppa_weekly
			;;

			"3")
				about
			;;
		esac
	fi
fi

if [ "$1" = "--no-exit" ]; then
	read
fi
