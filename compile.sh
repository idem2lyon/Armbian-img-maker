#!/bin/bash
#
# Copyright (c) 2015 Igor Pecovnik, igor.pecovnik@gma**.com
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# This file is a part of tool chain https://github.com/igorpecovnik/lib
#
#--------------------------------------------------------------------------------------------------------------------------------

# Read build script documentation
# http://www.armbian.com/using-armbian-tools/
# for detailed explanation of these parameters

# method
KERNEL_ONLY="no"					# build only kernel
KERNEL_CONFIGURE="no"					# want to change my default configuration
CLEAN_LEVEL="make,debs"					# comma-separated list of clean targets: "make" = make clean for selected kernel and u-boot,
							# "debs" = delete pckages in "./output/debs" for current branch and family,
							# "alldebs" - delete all packages in "./output/debs", "images" = delete "./output/images",
							# "cache" = delete "./output/cache", "sources" = delete "./sources"
# user
DEST_LANG="fr_FR.UTF-8"					# fr_FR.UTF-8
CONSOLE_CHAR="UTF-8"

# advanced
KERNEL_KEEP_CONFIG="no"					# overwrite kernel config before compilation
EXTERNAL="yes"						# install extra applications and drivers
FORCE_CHECKOUT="yes"					# ignore manual changes to source
BUILD_ALL="no"						# cycle through selected boards and make images

# build script version to use
LIB_TAG=""						# empty for latest version,
							# one of listed here: https://github.com/igorpecovnik/lib/tags for stable versions,
							# or commit hash
#--------------------------------------------------------------------------------------------------------------------------------

# source is where we start the script
SRC=$(pwd)

# destination
DEST=$(pwd)/output

# sources download
SOURCES=$(pwd)/sources

#--------------------------------------------------------------------------------------------------------------------------------
# To preserve proper librarires updating
#--------------------------------------------------------------------------------------------------------------------------------
if [[ -f main.sh && -d bin ]]; then
	echo -e "[\e[0;31m error \x1B[0m] Copy this file one level up, alter and run again."
	exit
fi


#--------------------------------------------------------------------------------------------------------------------------------
# Show warning for those who updated the script
#--------------------------------------------------------------------------------------------------------------------------------
if [[ -d $DEST/output ]]; then
	echo -e "[\e[0;35m warn \x1B[0m] Structure has been changed. Remove all files and start in a clean directory. \
	CTRL-C to exit or any key to continue. Only sources will be doubled ..."
	read
fi

if [[ $EUID != 0 ]]; then
	echo -e "[\e[0;35m warn \x1B[0m] This script requires root privileges"
	sudo "$0" "$@"
	exit 1
fi

#--------------------------------------------------------------------------------------------------------------------------------
# Get updates of the main build libraries
#--------------------------------------------------------------------------------------------------------------------------------
[[ $(dpkg-query -W -f='${db:Status-Abbrev}\n' git 2>/dev/null) != *ii* ]] && \
	apt-get -qq -y --no-install-recommends install git

if [[ ! -d $SRC/lib ]]; then
	git clone https://github.com/igorpecovnik/lib
fi
cd $SRC/lib
if [[ ! -f $SRC/.ignore_changes ]]; then
	echo -e "[\e[0;32m o.k. \x1B[0m] This script will try to update"
	git pull
	CHANGED_FILES=$(git diff --name-only)
	if [[ -n $CHANGED_FILES ]]; then
		echo -e "[\e[0;35m warn \x1B[0m] Can't update [\e[0;33mlib/\x1B[0m] since you made changes to: \e[0;32m\n${CHANGED_FILES}\x1B[0m"
		echo -e "Press \e[0;33m<Ctrl-C>\x1B[0m to abort compilation, \e[0;33m<Enter>\x1B[0m to ignore and continue"
		read
	else
		git checkout ${LIB_TAG:- master}
	fi
fi
#--------------------------------------------------------------------------------------------------------------------------------
# Do we need to build all images
#--------------------------------------------------------------------------------------------------------------------------------
if [[ $BUILD_ALL == yes ]]; then
	source $SRC/lib/build-all.sh
else
	source $SRC/lib/main.sh
fi

# If you are committing new version of this file, increment VERSION
# Only integers are supported
# VERSION=15
