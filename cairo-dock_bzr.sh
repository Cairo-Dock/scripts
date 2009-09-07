#!/bin/bash

# Script for BZR install for Cairo-Dock
#
# Copyright : (C) 2009 by Yann SLADEK
# E-mail : mav@cairo-dock.org
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


#Changelog
# 07/09/09 : 	fix de libxklavier, fix de revno, réduction des passphrases, possibilité de choisir bzr branch ou bzr checkout
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

# TODO : passphrases

DEBUG=0 # Attention, ne pas oublier de modifier !!!
DIR=$(pwd)
LOG_CAIRO_DOCK=$DIR/log.txt
SCRIPT="cairo-dock_bzr.sh"
SCRIPT_SAVE="cairo-dock_bzr.sh.save"
SCRIPT_NEW="cairo-dock_bzr.sh.new"
HOST="http://svn.cairo-dock.org"

CAIRO_DOCK_CORE_LP_BRANCH="cairo-dock-core"
CAIRO_DOCK_PLUG_INS_LP_BRANCH="cairo-dock-plug-ins"

#unset SSH_AUTH_SOCK # Evite de devoir retaper le passphrase
# ssh-add

#PLUGINS="alsaMixer Animated-icons Cairo-Penguin Clipper clock compiz-icon Dbus desklet-rendering dialog-rendering dnd2share dock-rendering drop-indicator dustbin GMenu icon-effect illusion keyboard-indicator logout mail motion-blur musicPlayer netspeed Network-Monitor powermanager quick-browser rhythmbox Scooby-Do shortcuts showDesklets showDesktop show-mouse slider stack System-Monitor switcher systray terminal tomboy Toons weather weblets wifi Xgamma xmms"
PLUGINS_GNOME="gnome-integration"
PLUGINS_GNOME_OLD="gnome-integration-old"
PLUGINS_XFCE="xfce-integration"

NEEDED="bzr libtool build-essential automake1.9 autoconf m4 autotools-dev pkg-config zenity intltool gettext libcairo2-dev libgtk2.0-dev librsvg2-dev libdbus-glib-1-dev libgnomeui-dev libvte-dev libxxf86vm-dev libx11-dev libalsa-ocaml-dev libasound2-dev libxtst-dev libgnome-menu-dev libgtkglext1-dev freeglut3-dev glutg3-dev libetpan-dev libwebkit-dev libexif-dev"
NEEDED_XFCE="libthunar-vfs-1-dev"
NEEDED_GNOME="libgnomevfs2-dev"
NEEDED_KARMIC="libxklavier-dev"
NEEDED_B_KARMIC="libxklavier12-dev"

UPDATE=0
UPDATE_PLUG_INS=0
UPDATE_CAIRO_DOCK=0
ERROR=0
DESKTOP_ENTRY_NAME=cairo-dock_bzr.desktop
FULL_COMPILE=0
DISTRIB=""
INSTALL_CAIRO_DOCK_OK=1

if test -e "$DIR/.bzr_dl"; then
	BZR_DL_MODE=`cat $DIR/.bzr_dl`
else
	BZR_DL_MODE=0
fi

BZR_REV_FILE_CORE="$DIR/.bzr_core"
BZR_REV_FILE_PLUG_INS="$DIR/.bzr_plug_ins"

NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m" 
ROUGE="\\033[1;31m"


#######################################################################
#	Fonctions d'install
#######################################################################

install_cairo_dock() {

	rm -Rf $LOG_CAIRO_DOCK > /dev/null

	echo "Installation de cairo-dock du `date`" >> $LOG_CAIRO_DOCK	

	echo "" >> $LOG_CAIRO_DOCK
	echo -e "$BLEU""Installation de cairo-dock"

	install_cairo >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tErreur"
		check $LOG_CAIRO_DOCK "CD"	
	else
		echo -e "$VERT""\tRéalisé avec succès"
	fi
	
	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK

}

install_cairo() {
	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH
	
	autoreconf -isvf && ./configure --prefix=/usr && make clean && make -j $(grep -c ^processor /proc/cpuinfo)

	if [ $? -ne 0 ]; then
		return 1
	fi

	sudo make install
	cd ..
}


install_cairo_dock_plugins() {
	
	echo -e "$BLEU""Installation des plug-ins"
	
	echo "Installation des plug-ins du `date`" >> $LOG_CAIRO_DOCK
	echo "" >> $LOG_CAIRO_DOCK	

	install_plugins >> $LOG_CAIRO_DOCK 2>&1

	if [ $? -ne 0 ]; then
		ERROR+=1
		echo -e "$ROUGE""\tErreur"	
	else
		echo -e "$VERT""\tRéalisé avec succès"
	fi	

	echo -e "$NORMAL"
	echo "" >> $LOG_CAIRO_DOCK

}


install_plugins() {
	echo $(pwd)

	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
	echo $(pwd)

	autoreconf -isvf && ./configure --prefix=/usr && make clean && make -j $(grep -c ^processor /proc/cpuinfo)
	
	if [ $? -ne 0 ]; then
		return 1
	fi

	sudo make install
	cd ..
}



install(){

	echo -e "$BLEU""C'est la première fois que vous installez la version BZR de Cairo-Dock"
	echo -e "\nGrâce à l'outil bzr, vous pouvez désormais télécharger les sources de plusieurs façons, notamment télécharger tout le contenu de la branche (si vous souhaitez ultérieurement procéder à des modifications et les publier sur des branches différents) ou uniquement la dernière révision (si vous voulez simplement tester les dernières révisions)\n""$VERT"
	echo -e "\t1 --> Télécharger la branche complète (~150Mo - pour les développeurs)\n\t\tDownload the complete branch (~150Mo - for dev.)"
	echo -e "\t2 --> Télécharger la dernière version (~25Mo - pour tous utilisateurs)\n\t\tDownload only the last rev. (~25Mo - for all users)"
	read BZR_DL_READ 
	if [ $BZR_DL_READ -eq 1 ]; then
		BZR_DL="branch"
		BZR_DL_MODE=1
	else
		BZR_DL="checkout --lightweight -q"
		BZR_DL_MODE=0
	fi
	echo $BZR_DL_MODE > $DIR/.bzr_dl
	
	echo -e "$BLEU""Téléchargement des données. Cette opération peut prendre quelques minutes"
	echo -e "$NORMAL"
	sleep 2

	if [ ! -d $DIR/$CAIRO_DOCK_CORE_LP_BRANCH ]; then
		echo -e "$BLEU""Téléchargement de cairo-dock"
		bzr $BZR_DL lp:$CAIRO_DOCK_CORE_LP_BRANCH 
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""Impossible de se connecter au serveur de Launchpad, veuillez vérifier votre connexion internet ou retenter plus tard"
			exit
		fi
	fi

	echo -e "$NORMAL"

	if [ ! -d $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH ]; then
		echo -e "$BLEU""Téléchargement des plugins"
		bzr $BZR_DL lp:$CAIRO_DOCK_PLUG_INS_LP_BRANCH 
		if [ $? -ne 0 ]; then
			echo -e "$ROUGE""Impossible de se connecter au serveur de Launchpad, veuillez vérifier votre connexion internet ou retenter plus tard"
			exit
		fi
	fi

	echo -e "$NORMAL"
	echo -e "$BLEU""Données téléchargées. L'installation va débuter"
	echo "Cette opération peut prendre plusieurs minutes et ralentir votre système"
	echo -e "$NORMAL"

	sleep 5
	
	install_cairo_dock

	install_cairo_dock_plugins

	check $LOG_CAIRO_DOCK "CD"
	
}


reinstall(){

	FULL_COMPILE=1

	install_cairo_dock

	install_cairo_dock_plugins
	
	check $LOG_CAIRO_DOCK "CD"
}



#######################################################################
#	Fonctions de désinstallation
#######################################################################


uninstall() {
	echo "Désinstallation de Cairo-Dock et des plug-ins"	
	
	cd $DIR/$CAIRO_DOCK_CORE_LP_BRANCH
	sudo make uninstall > $LOG_CAIRO_DOCK 2>&1
	cd ..

	cd $DIR/$CAIRO_DOCK_PLUG_INS_LP_BRANCH
	sudo make uninstall >> $LOG_CAIRO_DOCK 2>&1
	cd ..
	
	if [ -e /usr/share/applications/cairo-dock_svn.desktop ]; then
		sudo rm -f /usr/share/applications/cairo-dock_svn.desktop
	fi
	echo "La désinstallation à été effectuée."
	echo ""
	echo "Cependant, votre dossier de configuration est toujours présent."
	echo "Celui-ci se trouve dans votre /home/.config et se nomme cairo-dock (attention c'est un dossier caché)."
	echo "Vous pouvez le supprimer une fois la désinstallation effectuée"
	zenity --info --title=Cairo-Dock --text="Cairo-Dock a été désinstallé, veuillez lire le message dans le terminal"	
	exit

}



#######################################################################
#	Fonctions de mises à jour
#######################################################################

update(){
	echo -e "$BLEU""Recherche des mises à jour pour cairo-dock"
	if test -e "$BZR_REV_FILE_CORE"; then
		ACTUAL_CORE_VERSION=`cat "$BZR_REV_FILE_CORE"`
	else
		echo 0 > "$BZR_REV_FILE_CORE"
		ACTUAL_CORE_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		BZR_UP="pull"
		bzr $BZR_UP $CAIRO_DOCK_CORE_LP_BRANCH
		NEW_CORE_VERSION=`bzr revno -q $CAIRO_DOCK_CORE_LP_BRANCH`
	else
		BZR_UP="update -q"
		NEW_CORE_VERSION=`bzr revno -q $CAIRO_DOCK_CORE_LP_BRANCH`
		if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_CORE_LP_BRANCH
		fi
	fi

	echo -e "\nCairo-Dock-Core : rev $NEW_CORE_VERSION \n"
	echo -e "\nCairo-Dock-Core : rev $NEW_CORE_VERSION \n" >> $LOG_CAIRO_DOCK
	
	if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
		echo -e "$VERT""Une mise à jour de cairo-dock a été détéctée"
		sleep 1
		install_cairo_dock
		UPDATE_CAIRO_DOCK=1
		UPDATE=1
		#echo -e "$VERT""Mise à jour et recompilation des plug-ins suite à la mise à jour de cairo-dock"
		echo -e "$NORMAL"""
	else
		echo -e "$NORMAL"""
	fi


	echo -e "$BLEU""Recherche des mises à jour pour les plug-ins"
	if test -e "$BZR_REV_FILE_PLUG_INS"; then
		ACTUAL_PLUG_INS_VERSION=`cat "$BZR_REV_FILE_PLUG_INS"`
	else
		echo 0 > "$BZR_REV_FILE_PLUG_INS"
		ACTUAL_PLUG_INS_VERSION=0
	fi

	if [ $BZR_DL_MODE -eq 1 ]; then
		bzr $BZR_UP $CAIRO_DOCK_PLUG_INS_LP_BRANCH
		NEW_PLUG_INS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_LP_BRANCH`
	else
		NEW_PLUG_INS_VERSION=`bzr revno -q $CAIRO_DOCK_PLUG_INS_LP_BRANCH`
		if [ $ACTUAL_CORE_VERSION -ne $NEW_CORE_VERSION ]; then
			bzr $BZR_UP $CAIRO_DOCK_PLUG_INS_LP_BRANCH
		fi
	fi

	echo $NEW_PLUG_INS_VERSION > "$BZR_REV_FILE_PLUG_INS"
	echo -e "\nCairo-Dock-Plug-Ins : rev $NEW_PLUG_INS_VERSION \n"
	echo -e "\nCairo-Dock-Plug-Ins : rev $NEW_PLUG_INS_VERSION \n" >> $LOG_CAIRO_DOCK
	
	if [ $ACTUAL_PLUG_INS_VERSION -ne $NEW_PLUG_INS_VERSION ]; then		
		echo -e "$VERT""Une mise à jour des plug-ins a été détéctée"
		install_cairo_dock_plugins
		UPDATE=1
	elif [ $UPDATE_CAIRO_DOCK -eq 1 ]; then
		echo -e "$VERT""Recompilation des plug-ins suite à la mise à jour de cairo-dock"
		install_cairo_dock_plugins
	fi
	  
	echo -e "$NORMAL"
    
 	if [ $UPDATE -eq 1 ]; then
	    check $LOG_CAIRO_DOCK "CD"
	else
		echo -e "$BLEU"
		echo "Pas de mise à jour disponible"
		echo -e "$NORMAL"
		add_icon_to_gnome_menu
		zenity --info --title=Cairo-Dock --text="Cliquez sur Ok pour fermer le terminal."
		exit
	fi
	
}



#######################################################################
#	Fonctions de vérifications
#######################################################################

check() {
	echo -e "$NORMAL""Vérification de l'intégrité de l'installation"
	sleep 1
	
	if [ $2 = "CD" ]; then
		if [ $ERROR -ne 0 ]; then
			echo -e "$ROUGE"
			echo "Des erreurs ont été détéctées lors de l'installation."
			egrep -i "( error| Erreur)" $1
			echo "Veuillez consulter le fichier log.txt pour plus d'informations et vous rendre sur le forum de cairo-dock pour reporter l'erreur dans la section \"Version BZR\" "
			echo -e "$NORMAL"
			exit
		else
			echo -e "$VERT"
			echo "L'installation s'est terminée correctement."
			echo -e "$NORMAL"
			add_icon_to_gnome_menu
			zenity --info --title=Cairo-Dock --text="Cliquez sur Ok pour fermer le terminal"
			exit
		fi
	fi
}


check_new_script() {
	cp $SCRIPT $SCRIPT_SAVE #pour moi :)
	echo -e "$NORMAL"""
	echo "Vérification de la disponibilité d'un nouveau script"
	wget $HOST/$SCRIPT -q -O $SCRIPT_NEW	
	diff $SCRIPT $SCRIPT_NEW >/dev/null
	if [ $? -eq 1 ]; then
		echo -e "$ROUGE"		
		echo "Veuillez relancer le script, une mise à jour a été téléchargée"
		echo -e "$NORMAL"
		mv $SCRIPT_NEW $SCRIPT
		sudo chmod u+x $SCRIPT
		zenity --info --title=Cairo-Dock --text="Cliquez sur Ok pour fermer le terminal."
		exit
	else
		echo ""
		echo -e "$VERT""Vous possédez la dernière version du script de M@v"
	fi
	echo -e "$NORMAL"
	rm $SCRIPT_NEW

}


#######################################################################
#	Autres fonctions
#######################################################################



add_icon_to_gnome_menu() {
		
	if [ ! -e /usr/share/applications/$DESKTOP_ENTRY_NAME ]; then
		echo -e "$BLEU"
		echo "Ajout de l'icone Cairo-Dock BZR dans le menu Applications"
		echo -e "$NORMAL"

		sudo cp $DIR/$CAIRO_DOCK_CORE_LP_BRANCH/data/cairo-dock.svg /usr/share/pixmaps

		cd $DIR

		echo "[Desktop Entry]
		Encoding=UTF-8
		Name=Cairo-Dock BZR" > $DESKTOP_ENTRY_NAME
		echo "Exec=cairo-dock" >> $DESKTOP_ENTRY_NAME
		echo "Info=Cairo-Dock BZR
		Categories=Application;Utility; 
		Comment=Cairo-Dock BZR
		Comment[fr]=Cairo-Dock BZR
		Terminal=false
		Type=Application
		StartupNotify=true
		Name[fr_FR]=Cairo-Dock BZR
		Comment[fr_FR]=Cairo-Dock BZR
		Icon[fr_FR]=/usr/share/pixmaps/cairo-dock.svg
		Icon=/usr/share/pixmaps/cairo-dock.svg" >> $DESKTOP_ENTRY_NAME

		sudo mv $DESKTOP_ENTRY_NAME /usr/share/applications/

		echo -e "$VERT""Effectué"
		echo -e "$NORMAL"
	fi

}


detect_env_graph() 
{
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
	elif [[ `ps aux | grep -e "[g]nome-settings-daemon" ` ]]; then
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
	else
	   echo -e "Type de session locale non détéctée, ou non supportée vous utilisez e17, fluxbox ???... \n"
	fi

	return $ENV

} 

detect_distrib() {
	echo -e "$BLEU""Détection de la distribution"
	DISTRIB=$(grep -e DISTRIB_CODENAME /etc/lsb-release | cut -d= -f2)
	
	if [ -n $DISTRIB ]; then
		echo -e "$VERT""Votre distribution est $(grep -e DISTRIB_DESCRIPTION /etc/lsb-release | cut -d= -f2) ($DISTRIB)"
		echo -e "$NORMAL"
	else 
		echo -e "$ROUGE""Impossible de déterminer la distribution"
		echo -e "$NORMAL"
	fi	
}


check_dependancies() {
	
	echo -e "$BLEU""Vérification des paquets nécéssaires à la compilation" 
	
	dpkg -s sudo |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then #Debian
			echo -e "$ROUGE"" Le paquet sudo n'est pas installé, veuillez l'installer avant de continuer \n 'sudo' package isn't installed. Please install it.""$NORMAL"""
			exit
		fi
	
	sudo -v
	
	for tested in $NEEDED
	do
		dpkg -s $tested |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""Le paquet $tested n'est pas installé""$NORMAL"""
			sudo apt-get install $tested
		fi
	done

	if [ $ENV -eq 1 ]; then #Gnome
		dpkg -s $NEEDED_GNOME |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""Le paquet $NEEDED_GNOME n'est pas installé""$NORMAL"""
			sudo apt-get install $NEEDED_GNOME
		fi
	elif [ $ENV -eq 3 ]; then #XFCE
		dpkg -s $NEEDED_XFCE |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""Le paquet $NEEDED_XFCE n'est pas installé""$NORMAL"""
			sudo apt-get install $NEEDED_XFCE
		fi
	fi
	if [ $DISTRIB = 'karmic' ]; then #karmic
		dpkg -s $NEEDED_KARMIC |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""Le paquet $NEEDED_KARMIC n'est pas installé""$NORMAL"""
			sudo apt-get install $NEEDED_KARMIC
		fi
	else
		dpkg -s $NEEDED_B_KARMIC |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			echo -e "$ROUGE""Le paquet $NEEDED_B_KARMIC n'est pas installé""$NORMAL"""
			sudo apt-get install $NEEDED_B_KARMIC
		fi
	fi
	
	echo -e "$VERT""Vérification OK"
	echo -e "$NORMAL"""
	sleep 1
}



about() {
	echo "Auteur : Mav"
	echo "Contact : mav@cairo-dock.org"
	exit
}

if [ "$1" = "smo_install" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	install
elif [ "$1" = "smo_update" ]; then
	detect_distrib
	detect_env_graph
	check_dependancies
	update
fi
	
if [ $DEBUG -ne 1 ]; then
	check_new_script
fi

LG_CMD=`echo $LANG | grep fr`
if [ -n $LG_CMD ]; then 
	LG="FR" 
fi


echo -e "$NORMAL""Script d'installation de la version BZR de Cairo-Dock\n"
echo -e "Veuillez choisir l'option d'installation : \n"

echo -e "\t1 --> Mettre à jour la version BZR installée (Update)"
echo -e "\t2 --> Installer la version BZR pour la première fois (Install)"
echo -e "\t3 --> Reinstaller la version BZR actuelle (Renstall)"
echo -e "\t4 --> Désinstaller la version BZR (Uninstall)"
echo -e "\t5 --> A propos (About)"

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
		install
	;;
	
	"3")
		detect_distrib
		detect_env_graph
		check_dependancies
		reinstall
	;;
	
	"4")
		uninstall
	;;

	"5")
		about
	;;
	
esac
