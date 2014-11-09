#!/bin/bash
DIR=$(pwd) # -> /opt/cairo-dock/Packages/*.*.*
DIR_VERIF=`echo $DIR | grep -c /Packages/`

#Can be changed
ROOT_DIR="/opt/cairo-dock" ## <==
#ROOT_DIR="/opt/cairo-dock/3.1" ## <==
DEBIAN_DIR="/opt/cairo-dock/debian" ## <==
#DEBIAN_DIR="/opt/cairo-dock/debian_stable" ## <==

UBUNTU_CORE="vivid utopic trusty precise"
#UBUNTU_PLUG_INS="precise oneiric maverick lucid"
UBUNTU_PLUG_INS="$UBUNTU_CORE"
UNSTABLE_CODENAME="sid"
TESTING_CODENAME="jessie"
STABLE_CODENAME="wheezy"
DEBIAN_SUITE="unstable testing stable"
#DEBIAN_CORE="$DEBIAN_SUITE" ## <==
#DEBIAN_PLUG_INS="$DEBIAN_CORE" ## <==

DEBUILD_ARG2='a'
PPA=0 # For a rebuild: 3.3.99.beta1.1~20140628~git3103~9378aa9-0ubuntu1~ppaX
PPAPG=$PPA # just for plugins
REVISION=1 # to have a newer version than the one in official repo: 3.3.99.beta1.*X*

# should not be changed
CL="debian/changelog"
DPUT_PSEUDO="matttbe"
REPOSNAME="exp"
# REPOSNAME="exp2"
DEBIAN_PBUILDER="$DIR/debian_pbuilder"
mkdir -p "$DEBIAN_PBUILDER"
DEBIAN_SCRIPT="$DEBIAN_PBUILDER/debian_script.sh"

### CHANGELOG ###
CHANGELOG='\\n  * New Upstream Version (sync from GIT).' ## <==
CHANGELOG_PLUG_INS='\\n  * New Upstream Version (sync from GIT).' ## <==
#CHANGELOG='\\n  * New Upstream Version (3.1.0).\n   - Better integration of Unity: support of the Launcher API\n      and better support of indicators\n   - All configuration windows have been merged into a single one.\n   - Added progress bars in several applets and in the Dbus API\n   - The Music Player applet can control players in the systray.\n   - Icons of the taskbar can be separated from launchers or not\n   - And as always ... various bug fixes and improvements :-)'
#CHANGELOG_PLUG_INS='\\n  * New Upstream Version (3.1.0).' ## <==

############################
## How to use this script ##
############################

#	## You need a dput.cf :
#	  * remplace 'matttbe' here above and bellow by your nickname
#	  * You need one section for each supported version (only for Ubuntu), e.g. here with jaunty:
#		[matttbe-exp-jaunty]
#		fqdn = ppa.launchpad.net
#		method = ftp
#		incoming = ~matttbe/experimental/ubuntu/jaunty
#		login = anonymous
#		allow_unsigned_uploads = 0

#	## Explications
#	  * You need to respect the structures of files: in $DEBIAN_DIR: we should find a directory for each version which contains 'debian' (dir for the core) and 'plug-ins/debian' (dir for the plugins)
#	  * All packages should be firstly sent to a temporary PPA and then copy to another one (to wait for the compilation of the core and plugins)
#	  * This script has to be launched from this dir: Packages/x.x.x/ => $ .././debPackages.sh


NORMAL="\\033[0;39m"
BLEU="\\033[1;34m"
VERT="\\033[1;32m"
ROUGE="\\033[1;31m"

echo -e "\n""$BLEU""Upload to ppa""$ROUGE"

while getopts ":e:d:sxtugfh" flag
do
	case "$flag" in
	e)
		echo " => Pause between core and plug-ins: $OPTARG"
		SLEEP_PG=$OPTARG
		;;
	d)
		echo " => Use Delay option with dput: $OPTARG"
		DELAY=$OPTARG
		;;
	s)
		echo " => Shutdown at the end"
		SHUTDOWN=1
		;;
	x)
		echo " => CMake with Extras"
		ARG1="-$flag"
		;;
	t)
		echo " => No generate tarball, only copy it"
		ARG1="-$flag"
		;;
	u)
		echo " => Only upload"
		ARG1="-$flag"
		;;
	g)
		echo " => Only generate tarball"
		ARG1="-$flag"
		;;
	f)
		echo " => Without CMake command (directly 'make dist')"
		ARG1="-$flag"
		;;
	h)
		echo -e "e [int]\t=> Pause between core and plug-ins"
		echo -e "d [int]\t=> Use Delay option with dput"
		echo -e "s\t=> Shutdown at the end"
		echo -e "x\t=> CMake with Extras"
		echo -e "t\t=> No generate tarball, only copy it"
		echo -e "u\t=> Only upload"
		echo -e "g\t=> Only generate tarball"
		echo -e "f\t=> Without CMake command (directly 'make dist')"
		echo -e "$NORMAL"
		exit 0
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	esac
done

echo -e "$NORMAL"

if [ "$DELAY" = "0" ]; then unset DELAY; fi
if [ "$SHUTDOWN" != "" ]; then sudo -v; fi # start sudo unlocked state timeout
TRAP_ON='echo -e "\e]0;$BASH_COMMAND\007"' # Afficher la commande en cours dans le terminal
TRAP_OFF="trap DEBUG"
date_AJD=`date '+%Y%m%d'`

##### Main #####

if test "$1" = ""; then
	echo -e "$BLEU""Disposition :""$NORMAL""
\t|-/cairo-dock-core (+ sources)
\t|-/cairo-dock-plug-ins (+ sources)
\t|-/debian (+ sources)
\t|-/Packages
\t|-----|-/x.x.x -> (e.g. : 2.1.0)
\t|-----|-----|- => this script has to be launched from this dir"
	echo -e "$BLEU""PPA :""$NORMAL""
\t* Having one ppa
\t* Added DEBFULLNAME= and DEBEMAIL= defined with an export or in ~/.bashrc or ~/.zshrc
\t* Having ~/.dput.cf file with entries $DPUT_PSEUDO-[$UBUNTU_CORE]"

	echo -e "$BLEU""\nExtras :""$NORMAL""
\tIf the script is launched with '../.debPackages.sh -...' :
\t\t-f : no cmake
\t\t-u : upload -> tarballs already exists"
fi

if [ $DIR_VERIF -eq 0 ]; then
	echo -e "$ROUGE""WARNING : wrong DIR! You're not in this dir: Packages/x.x.x/""$NORMAL"
	exit 0
fi

NUMBER_RELEASE=`head -n 15 "$ROOT_DIR"/cairo-dock-core/CMakeLists.txt | grep "set (VERSION" | cut -d\" -f2 | cut -d\" -f1` # 2.1.0-rc3
NUMBER_RELEASE_PG=`head -n 15 "$ROOT_DIR"/cairo-dock-plug-ins/CMakeLists.txt | grep "set (VERSION" | cut -d\" -f2 | cut -d\" -f1` # 2.1.0-rc3
PLUG_INS=`head -n 15 "$ROOT_DIR"/cairo-dock-plug-ins/CMakeLists.txt | grep "project (" | cut -d\" -f2 | cut -d\" -f1` # cairo-dock-plugins

echo -e "$VERT"

read -p "Special version? (press enter for: $NUMBER_RELEASE.$REVISION~$date_AJD~gitXXX~HASH-0ubuntu1~ppa$PPA ; 'CD' = Version for official repositories): " VERSION
if [ "$VERSION" = "CD" ]; then
	echo -e "$ROUGE""\n\n\t\WARNING: REMOVED FLAGS FOR INSTABLE APPLETS !!!"
	echo -e "\tDir with core and plug-ins branches: $ROOT_DIR"
	echo -e "\tDir with debian config files: $DEBIAN_DIR\n\n"
	echo -e "\tVersions of Debian: $DEBIAN_CORE""$VERT"
fi
# trickle
	dpkg -s trickle |grep installed |grep "install ok" > /dev/null	
	if [ $? -eq 1 ]; then
		echo -e "$ROUGE""Package 'trickle' is not available: Installation""$NORMAL"
		sudo apt-get install -qq trickle
	fi
read -p "Limit upload bandwidth? (ko) : " TRICKLE
if [ "$TRICKLE" = "" ]; then
	TRICKLE=0
fi

if test "$ARG1" = "-t"; then
	echo -e "$ROUGE""NOT Generating tarballs ...""$NORMAL"
	mv *.tar.gz ../
fi

if test ! "$ARG1" = "-u"; then
	read -p "The current dir will be emptied, press Enter to continue" POUET
	rm -r *
fi
echo -e "$NORMAL"

date > $DIR/log.txt
echo 0 > sleepPG; gpg --armor --sign --detach-sig sleepPG >> $DIR/log.txt # start gpg unlocked state timeout
rm -f sleepPG*
if [ "$SHUTDOWN" != "" ]; then sudo -v; fi

###### TARBALL ######
if test "$ARG1" = "-t"; then
	mv ../*.tar.gz .
	tar xzf *.tar.gz
elif test "$ARG1" = "-u"; then
	echo -e "$ROUGE""Only the upload, DEBUILD_ARG2 = $DEBUILD_ARG2""$NORMAL"
else
	echo "***************************"
	echo -e "* ""$VERT""Generating tarballs ...""$NORMAL"" *"
	echo "***************************"

	echo -e "$VERT""\n\tCore""$NORMAL"
	echo -e "\n\t==== Tarball : Core ====\n" >> $DIR/log.txt
	cd "$ROOT_DIR"/cairo-dock-core/
	if test "$ARG1" = "-f" -a -d 'build'; then
		echo -e "$ROUGE""no cmake""$NORMAL"
		cd build/
	else
		rm -rf build/
		mkdir build
		cd build/
		cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DPACKAGEMENT=yes >> $DIR/log.txt
	fi
	trap "$TRAP_ON" DEBUG
	make dist >> $DIR/log.txt
	$TRAP_OFF
	TARBALL_CORE="cairo-dock-$NUMBER_RELEASE.tar.gz"
	TARBALL_ORIG_CORE="cairo-dock_$NUMBER_RELEASE.orig.tar.gz"
	mv $TARBALL_CORE $DIR/$TARBALL_ORIG_CORE
	if [ "$VERSION" != "CD" ]; then
		CORE_REV="`git rev-list HEAD --count`~`git rev-parse --short HEAD`"
	fi
	cd $DIR
	tar xzf $TARBALL_ORIG_CORE
	rm -rf "$DEBIAN_PBUILDER"
	mkdir -p "$DEBIAN_PBUILDER"
	if [ "$VERSION" = "" ]; then
		mv $TARBALL_ORIG_CORE "cairo-dock_$NUMBER_RELEASE.$REVISION~$date_AJD~git$CORE_REV.orig.tar.gz"
		cp "cairo-dock_$NUMBER_RELEASE.$REVISION~$date_AJD~git$CORE_REV.orig.tar.gz" "$DEBIAN_PBUILDER"
	else
		cp $TARBALL_ORIG_CORE "$DEBIAN_PBUILDER"
	fi

	echo -e "$VERT""\tPlug-ins""$NORMAL"
	echo -e "\n\t==== Tarball : Plug-ins ====\n" >> $DIR/log.txt
	cd "$ROOT_DIR"/cairo-dock-plug-ins/
	if [ $NUMBER_RELEASE != $NUMBER_RELEASE_PG ]; then
		echo -e "$ROUGE""ATTENTION, la version est différente de core""$NORMAL"
	fi
	if test "$ARG1" = "-f" -a -d 'build'; then
		echo -e "$ROUGE""no cmake""$NORMAL"
		cd build/
	else
		rm -rf build/
		mkdir build
		cd build/
		if test "$ARG1" = "-x" -a -f "$ROOT_DIR""/cairo-dock_git.sh"; then
			CONFIGURE=`grep "CONFIGURE_PG=" "$ROOT_DIR"/cairo-dock_git.sh |head -n1 |cut -d\" -f2 |cut -d\" -f1`
		fi
		cmake .. -DCMAKE_INSTALL_PREFIX=/usr $CONFIGURE -DPACKAGEMENT=yes >> $DIR/log.txt
	fi
	trap "$TRAP_ON" DEBUG
	make dist >> $DIR/log.txt
	$TRAP_OFF
	TARBALL_PG="$PLUG_INS-$NUMBER_RELEASE_PG.tar.gz"
	TARBALL_ORIG_PG="cairo-dock-plug-ins_$NUMBER_RELEASE_PG.orig.tar.gz"
	mv $TARBALL_PG $DIR/$TARBALL_ORIG_PG
	if [ "$VERSION" != "CD" ]; then
		PLUG_INS_REV="`git rev-list HEAD --count`~`git rev-parse --short HEAD`"
	fi
	cd $DIR
	tar xzf $TARBALL_ORIG_PG
	if [ "$VERSION" = "" ]; then
		mv $TARBALL_ORIG_PG "cairo-dock-plug-ins_$NUMBER_RELEASE_PG.$REVISION~$date_AJD~git$PLUG_INS_REV.orig.tar.gz"
		cp "cairo-dock-plug-ins_$NUMBER_RELEASE_PG.$REVISION~$date_AJD~git$PLUG_INS_REV.orig.tar.gz" "$DEBIAN_PBUILDER"
	else
		cp $TARBALL_ORIG_PG "$DEBIAN_PBUILDER"
	fi

	if [ "$VERSION" = "CD" ]; then # signature des fichiers.
		cp $TARBALL_ORIG_CORE $TARBALL_CORE
		gpg --armor --sign --detach-sig $TARBALL_CORE
		cp $TARBALL_ORIG_PG $TARBALL_PG
		gpg --armor --sign --detach-sig $TARBALL_PG
	fi
fi
if test "$ARG1" = "-g"; then exit 0; fi

if [ "$SHUTDOWN" != "" ]; then sudo -v; fi

if test "$CORE_REV" = "" -a  "$VERSION" != "CD"; then
	cd "$ROOT_DIR"/cairo-dock-core/
	CORE_REV="`git rev-list HEAD --count`~`git rev-parse --short HEAD`"
	cd "$ROOT_DIR"/cairo-dock-plug-ins/
	PLUG_INS_REV="`git rev-list HEAD --count`~`git rev-parse --short HEAD`"
	cd $DIR
fi

### PACKAGE NAME

if [ "$VERSION" = "" ]; then
	VERSION="$NUMBER_RELEASE.$REVISION~$date_AJD~git$CORE_REV-0ubuntu1~ppa$PPA"
	VERSION_PG="$NUMBER_RELEASE_PG.$REVISION~$date_AJD~git$PLUG_INS_REV-0ubuntu1~ppa$PPAPG"
	VERSION_DEB="$NUMBER_RELEASE.$REVISION~$date_AJD~git$CORE_REV-1debian1~ppa$PPA"
	VERSION_DEB_PG="$NUMBER_RELEASE_PG.$REVISION~$date_AJD~git$PLUG_INS_REV-1debian1~ppa$PPAPG"
elif [ "$VERSION" = "CD" ]; then
	VERSION="$NUMBER_RELEASE-0ubuntu$PPA"
	VERSION_PG="$NUMBER_RELEASE_PG-0ubuntu$PPAPG"
	VERSION_DEB="$NUMBER_RELEASE-$PPA"
	VERSION_DEB_PG="$NUMBER_RELEASE_PG-$PPAPG"
else
	VERSION_PG=$VERSION
	VERSION_DEB=$VERSION
	VERSION_DEB_PG=$VERSION
fi

cd $DIR/cairo-dock-$NUMBER_RELEASE

###### CORE ######
echo -e "$BLEU""\nUpload Core packages\n""$NORMAL"

OPT=$DEBUILD_ARG2

# Ubuntu => dput
# Debian => script
echo "#!/bin/bash" > "$DEBIAN_SCRIPT"
echo "source /root/.scripts/pbuilder_utils" >> "$DEBIAN_SCRIPT"
echo "update_pbuilder" >> "$DEBIAN_SCRIPT"
echo "clean_pbuilder" >> "$DEBIAN_SCRIPT"
chmod +x "$DEBIAN_SCRIPT"
for RLS in $UBUNTU_CORE $DEBIAN_CORE; do
	echo -e "$VERT""Upload Core package - $RLS""$NORMAL"
	echo -e "\n\t==== Upload : Core - $RLS ====" >> $DIR/log.txt
	if test -d 'debian'; then
		rm -r debian
	fi
	cp -R "$DEBIAN_DIR"/$RLS/debian .
	if test `echo $DEBIAN_SUITE | grep -c $RLS` -gt 0; then
		PAQUET="cairo-dock ($VERSION_DEB~$RLS) $RLS; urgency=low"
	else
		PAQUET="cairo-dock ($VERSION~$RLS) $RLS; urgency=low"
	fi
	DATE=`date -R`
	SIGN='\\n -- '"$DEBFULLNAME <$DEBEMAIL>"'  '"$DATE \n"
	sed -i "1i$SIGN" $CL
	sed -i "1i$CHANGELOG" $CL
	sed -i "1i$PAQUET" $CL
	trap "$TRAP_ON" DEBUG
	debuild -S -s$OPT >> $DIR/log.txt
	if [ "$SHUTDOWN" != "" ]; then sudo -v; fi
	if test `echo $DEBIAN_SUITE | grep -c $RLS` -gt 0; then
		$TRAP_OFF
		if test "$RLS" = "stable"; then RLS2="$STABLE_CODENAME"; fi
		if test "$RLS" = "testing"; then RLS2="$TESTING_CODENAME"; fi
		if test "$RLS" = "unstable"; then RLS2="$UNSTABLE_CODENAME"; fi
		echo "build_pbuilder \"cairo-dock_""$VERSION_DEB""~""$RLS"".dsc\" \"$RLS2\"" >> "$DEBIAN_SCRIPT"
		mv ../cairo-dock_"$VERSION_DEB"~"$RLS"* "$DEBIAN_PBUILDER"
	else
		trickle -u $TRICKLE dput $DPUT_PSEUDO-$REPOSNAME-$RLS ../cairo-dock_"$VERSION"~"$RLS"_source.changes
		$TRAP_OFF
	fi
	if [ "$SHUTDOWN" != "" ]; then sudo -v; fi
	OPT='d'
done

###### PAUSE: reset password timeout ######

if [ "$SLEEP_PG" != "" ]; then
	echo -e "$ROUGE""\nPAUSE: $(($SLEEP_PG/60)) minutes\n""$NORMAL"
	cd $DIR
	for i in 1 2 3 4; do
		echo $i > sleepPG
		gpg --armor --sign --detach-sig sleepPG >> $DIR/log.txt
		date
		sleep $(($SLEEP_PG/4))
		if [ "$SHUTDOWN" != "" ]; then sudo -v; fi
		rm -f sleepPG*
	done
fi

###### PLUG-INS ######

cd $DIR/$PLUG_INS-$NUMBER_RELEASE_PG
echo -e "$BLEU""\nUpload Plug-ins packages\n""$NORMAL"

OPT=$DEBUILD_ARG2
for RLS in $UBUNTU_PLUG_INS $DEBIAN_PLUG_INS; do
	echo -e "$VERT""\nUpload Plug-ins package - $RLS""$NORMAL"
	echo -e "\n\t==== Upload : Plug-ins - $RLS ====\n" >> $DIR/log.txt
	if test -d 'debian'; then
		rm -r debian
	fi
	cp -R "$DEBIAN_DIR"/$RLS/plug-ins/debian .
	if test `echo $DEBIAN_SUITE | grep -c $RLS` -gt 0; then
		OPT='a'
		PAQUET_PLUG_INS="cairo-dock-plug-ins ($VERSION_DEB_PG~$RLS) $RLS; urgency=low"
	else
		PAQUET_PLUG_INS="cairo-dock-plug-ins ($VERSION_PG~$RLS) $RLS; urgency=low"
	fi
	DATE=`date -R`
	SIGN='\\n -- '"$DEBFULLNAME <$DEBEMAIL>"'  '"$DATE \n"
	sed -i "1i$SIGN" $CL
	sed -i "1i$CHANGELOG_PLUG_INS" $CL
	sed -i "1i$PAQUET_PLUG_INS" $CL
	trap "$TRAP_ON" DEBUG
	debuild -S -s$OPT >> $DIR/log.txt
	if [ "$SHUTDOWN" != "" ]; then sudo -v; fi
	if test `echo $DEBIAN_SUITE | grep -c $RLS` -gt 0; then
		$TRAP_OFF
		if test "$RLS" = "stable"; then RLS2="$STABLE_CODENAME"; fi
		if test "$RLS" = "testing"; then RLS2="$TESTING_CODENAME"; fi
		if test "$RLS" = "unstable"; then RLS2="$UNSTABLE_CODENAME"; fi
		echo "build_pbuilder \"cairo-dock-plug-ins_""$VERSION_DEB_PG""~""$RLS"".dsc\" \"$RLS2\"" >> "$DEBIAN_SCRIPT"
		mv ../cairo-dock-plug-ins_"$VERSION_DEB_PG"~"$RLS"* "$DEBIAN_PBUILDER"
	else
#		if test "$DELAY" != "" -a $DELAY -gt 0 -a $DELAY -le 15; then
#			DPUT_OPT="-e $DELAY"
#		fi
		trickle -u $TRICKLE dput $DPUT_OPT $DPUT_PSEUDO-$REPOSNAME-$RLS ../cairo-dock-plug-ins_"$VERSION_PG"~"$RLS"_source.changes
	fi
	$TRAP_OFF
	if [ "$SHUTDOWN" != "" ]; then sudo -v; fi
	OPT='d'
done

echo -e "\n\t==== END ====" >> $DIR/log.txt

if test -n "$SHUTDOWN" -a ! -e SHUTDOWN; then
	if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
		dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"The computer will be powered off in 1 minute." int32:8 string:"class=$COLORTERM"
	fi
	sudo shutdown -h 1
else
	if test  `ps aux | grep -c " [c]airo-dock"` -gt 0; then
		dbus-send --session --dest=org.cairodock.CairoDock /org/cairodock/CairoDock org.cairodock.CairoDock.ShowDialog string:"The script to upload all packages is now over." int32:8 string:"class=$COLORTERM"
	else
		zenity --info --title=Cairo-Dock --text="The script to upload all packages is now over."
	fi
fi
exit
