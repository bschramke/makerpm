#!/bin/bash

# Copyright (c) 2013, Björn Schramke (bjoern@schramke-online.de)
# All rights reserved.
#
# This script is based on makerpm-amd-13.1.sh by Sebastian Siebert
# Copyright (c) 2010-2013, Sebastian Siebert (mail@sebastian-siebert.de)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY SEBASTIAN SIEBERT ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL SEBASTIAN SIEBERT BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Changelog:

# Version 1.0  - inital development

##########################################################################################
# Constants
SCRIPTVERSION="0.1"
AUTHOR="Björn Schramke"
AUTHOR_MAIL="bjoern@schramke-online.de"

INNOEXTRACT_URL='http://constexpr.org/innoextract/'

# Name and store page for the GOG.com download
GOG_SETUP_FILE='setup_police_quest1234_2.0.0.8.exe'
GOG_URL='http://www.gog.com/gamecard/police_quest_1_2_3_4'

TEMP_PATH="/tmp/pqsetup/"

GITHUB_URL="https://raw.github.com/bschramke/makerpm/"
GITHUB_SPEC="${GITHUB_URL}master/PQ1VGA.spec"
GITHUB_ICON="${GITHUB_URL}master/PQ1.png"
GITHUB_SCRIPT="${GITHUB_URL}master/PQ1VGA"
GITHUB_DESKTOP="${GITHUB_URL}master/PQ1VGA.desktop"

RPMBUILD_WORKINGDIR=~/rpmbuild/
RPMBUILD_SOURCEDIR=${RPMBUILD_WORKINGDIR}SOURCES/
RPMBUILD_RPMDIR=${RPMBUILD_WORKINGDIR}RPMS/noarch/

PQ1_VERSION="2.0.0"
PQ1_SPEC="PQ1.spec"
PQ1_TAR="PQ1.tgz"
PQ1_ICON="PQ1.png"
PQ1_DESKTOP="PQ1.desktop"
PQ1_SCRIPT="PQ1"
PQ1_RPM="PQ1-2.0.0-19920923.noarch.rpm"

PQ1VGA_VERSION="2.0.0"
PQ1VGA_SPEC="PQ1VGA.spec"
PQ1VGA_TAR="PQ1VGA.tgz"
PQ1VGA_ICON="PQ1.png"
PQ1VGA_DESKTOP="PQ1VGA.desktop"
PQ1VGA_SCRIPT="PQ1VGA"
PQ1VGA_RPM="PQ1VGA-2.0.0-19920923.noarch.rpm"

PQ2_VERSION="2.0.0"
PQ2_SPEC="PQ2.spec"
PQ2_TAR="PQ2.tgz"
PQ2_ICON="PQ2.png"
PQ2_DESKTOP="PQ2.desktop"
PQ2_SCRIPT="PQ2"
PQ2_RPM="PQ2-2.0.0-19920923.noarch.rpm"

PQ3_VERSION="1.0.0"
PQ3_SPEC="PQ3.spec"
PQ3_TAR="PQ3.tgz"
PQ3_ICON="PQ3.png"
PQ3_DESKTOP="PQ3.desktop"
PQ3_SCRIPT="PQ3"
PQ3_RPM="PQ3-${PQ3_VERSION}-19920923.noarch.rpm"

MAKERPM_DIR="$PWD"

# set default configuration
BUILDONLY="true"
DOWNLOADONLY="false"
KEEP_FILES="true"
INSTALL="false"
UNINSTALL="false"

##########################################################################################
# Colors

disable_color() {
        red='' ; green='' ; yellow='' ; blue='' ; pink='' ; cyan='' ; white=''
        dim_red='' ; dim_green='' ; dim_yellow='' ; dim_blue='' ; dim_pink=''
        dim_cyan='' ; dim_white='' ; reset=''
}
disable_color
if [ -t 1 ] && [ "$(tput colors 2> /dev/null)" != -1 ] ; then

               red="$(printf '\033[1;31m')"
             green="$(printf '\033[1;32m')"
            yellow="$(printf '\033[1;33m')"
              blue="$(printf '\033[1;34m')"
              pink="$(printf '\033[1;35m')"
              cyan="$(printf '\033[1;36m')"
             white="$(printf '\033[1;37m')"

           dim_red="$(printf '\033[0;31m')"
         dim_green="$(printf '\033[0;32m')"
        dim_yellow="$(printf '\033[0;33m')"
          dim_blue="$(printf '\033[0;34m')"
          dim_pink="$(printf '\033[0;35m')"
          dim_cyan="$(printf '\033[0;36m')"
         dim_white="$(printf '\033[0;37m')"

             reset="$(printf '\033[0m')"
fi

##########################################################################################
# Helper functions

function OutputUsage() {
    echo "Usage : $(basename $0) [options...]"
    echo "Options:"
    echo "  -b/--build                 build only the RPM-Package (default)"
    echo "  -d/--downloadonly          download only the Steam-Package for Ubuntu"
    echo "  -k/--keep                  do not remove downloaded .deb and .spec after build"
    echo "  -i/--install               build and install/update the RPM-Package"
    echo "  -u/--uninstall             remove Steam and clean up completely all possible Steam files and directories"
    echo "  -h/--help                  this help text"
    echo "  -V/--version               show version number"

    exit 1
}

check_invalid_options() {
    # $1 = option
    if [ "${BUILDONLY}" = "true" -a "buildonly" != "$1" ]; then
        ERROROPTION="--buildonly"
    elif [ "${DOWNLOADONLY}" = "true" -a "downloadonly" != "$1" ]; then
        ERROROPTION="--downloadonly"
    elif [ "${INSTALL}" = "true" -a "install" != "$1" ]; then
        ERROROPTION="--install"
    elif [ "${UNINSTALL}" = "true" -a "uninstall" != "$1" ]; then
        ERROROPTION="--uninstall"
    fi

    if [ -n "${ERROROPTION}" ]; then
        echo "Error: Option \"--$1\" can not use with \"${ERROROPTION}\""
        exit 1;
    fi
}

check_install() {
    PROGRAM=$1
    echo -n -e "Check for installed package \"${PROGRAM}\" ... "
    rpm -q "${PROGRAM}" >/dev/null
    if [ $? -eq 0 ]; then
        print_okay
    else
        print_pkg_missing
        echo -n -e "\t try to run \"zypper install ${PROGRAM}\" now ...\n"
        zypper -v -n in ${PROGRAM}
        if [ $? -ne 0 ]; then
            echo -n "\t Error: zypper could not install the package \"${PROGRAM}\" ..."
            print_failure
            exit 1
        fi
    fi
}

check_workingdir() {
    echo -n -e "Checking rpmbuild working directory ... "
    if [ -d ${RPMBUILD_SOURCEDIR} ]; then
        print_okay
    else
        print_missing
	echo -n -e " try to create working directory \"${RPMBUILD_SOURCEDIR}\" ... "
	mkdir -p ${RPMBUILD_SOURCEDIR}
	if [ $? -ne 0 ];then
	  print_failure
	  exit 1
	fi
	print_okay
    fi
}

download_spec(){
    echo "Download pq1vga.spec ..."
    curl -f -o "$1" "$2"
#    cp "$1" "$2"
    if [ $? -ne 0 ]; then
        print_failure
        exit 1
    fi
    print_okay
}

copy_source_file(){
    cp -f $1 ${RPMBUILD_SOURCEDIR}
    if [ $? -ne 0 ]; then
        echo -n -e "\n   Error: Copying failed!"
        print_failure
        exit 1
    fi
}

print_okay() {
    echo -e "\033[${COLUMNS}C\033[15D[\e[1;32m OK \e[0m]"
}
print_failure() {
    echo -e "\033[${COLUMNS}C\033[15D[\e[1;31m FAILURE \e[0m]"
}
print_missing() {
    echo -e "\033[${COLUMNS}C\033[15D[\e[1;33m MISSING \e[0m]"
}
print_aborted() {
    echo -e "\033[${COLUMNS}C\033[15D[\e[1;33m ABORTED \e[0m]"
}

print_pkg_available() {
#    echo -e "[\e[1;32m AVAILABLE \e[0m]"
    echo -e "\033[${COLUMNS}C\033[15D[\e[1;33m AVAILABLE \e[0m]"
}
print_pkg_missing() {
#    echo -e "[\e[1;31m MISSING \e[0m]"
    echo -e "\033[${COLUMNS}C\033[15D[\e[1;33m MISSING \e[0m]"
}

box_full() {
    printf '*%.0s' $(seq 1 67)
    echo ""
}

box_content() {
    echo -n "*"
    if [ $# -eq 0 ]; then
        printf ' %.0s' $(seq 1 65)
    elif [ $# -eq 1 ]; then
        RIGHT="$1"
        printf ' %.0s' $(seq 1 17)
        echo -n "${RIGHT}"
        printf ' %.0s' $(seq 1 $[48-${#RIGHT}])
    elif [ $# -eq 2 ]; then
        LEFT="$1"
        RIGHT="$2"
        printf ' %.0s' $(seq 1 3)
        echo -n "${LEFT}"
        printf ' %.0s' $(seq 1 $[14-${#LEFT}])
        echo -n "${RIGHT}"
        printf ' %.0s' $(seq 1 $[48-${#RIGHT}])
    fi
    echo "*"
}

if [ $# -ne 0 ]; then
    BUILDONLY="false"
fi

##########################################################################################
# Parse command-line arguments

while [ "$#" -gt "0" ]; do
    case $1 in
        -b|--buildonly)
            check_invalid_options "buildonly"
            BUILDONLY="true"
            echo "only build"
            shift 1
        ;;
        -d|--downloadonly)
            check_invalid_options "downloadonly"
            DOWNLOADONLY="true"
            echo "only download"
            shift 1
        ;;
        -k|--keep)
#            check_invalid_options "keep"
            KEEP_FILES="true"
            shift 1
        ;;
        -i|--install)
            check_invalid_options "install"
            INSTALL="true"
            echo "build and install"
            shift 1
        ;;
        -u|--uninstall)
            check_invalid_options "uninstall"
            UNINSTALL="true"
            shift 1
        ;;
        -h|--help)
            OutputUsage
            exit 0
        ;;
        -V|--version)
            echo -e "$(basename $0) - Version ${SCRIPTVERSION}\n"
            echo "Copyright (c) 2012-`date +'%Y'`, ${AUTHOR} (${AUTHOR_MAIL})"
#            echo "Copyright (c) 2010-`date +'%Y'`, Sebastian Siebert (mail@sebastian-siebert.de)"
            echo "All rights reserved."
            echo "This script is under the modified BSD License (2-clause license)"
            exit 0
        ;;
        -*|--*)
            echo "Error: Option \"$1\" is unknown"
            echo "try '$(basename $0) -h' or '$(basename $0) --help' for more information"
            exit 1
        ;;
     esac
done

# Check the size of the console
set -- $(stty size 2> /dev/null || echo 0 0)
LINES=$1
COLUMNS=$2
if [ ${LINES} -eq 0 ]; then
    LINES=24
fi
if [ ${COLUMNS} -eq 0 ]; then
    COLUMNS=80
fi

box_full
box_content
box_content "Script:" "$(basename $0)"
box_content "Version:" "${SCRIPTVERSION}"
box_content "Written by:" "${AUTHOR} (${AUTHOR_MAIL})"
box_content
box_content "Description:" "This script helps you to create a rpm package"
box_content "from the proprietary Police Quest 1 VGA package"
box_content
box_content "License:" "This script is under the"
box_content "modified BSD License (2-clause license)"
box_content
box_full

##################################################################################
## here comes the actual script contents
##################################################################################

check_install innoextract
check_install rpm-build
check_workingdir

echo -n "Check for existing GOG-Setup-Package \"${GOG_SETUP_FILE}\" ..."
if [ -f ${GOG_SETUP_FILE} ]; then
    print_okay
else
    print_missing
    echo "cant find ${GOG_SETUP_FILE}, get it from ${green}${GOG_URL}${reset}."
    exit 1
fi

echo -n "Extract files from GOG-Setup-Package \"${GOG_SETUP_FILE}\" ..."
innoextract -es ${GOG_SETUP_FILE} -d ${TEMP_PATH}
if [ $? -ne 0 ]; then
    echo -n -e "\n   Error: Extracting GOG-Setup-Package failed!"
    print_failure
    exit 1
fi
print_okay

##################################################################################
## prepare PQ1
##################################################################################
echo -n "Check for existing PQ1 package \"${PQ1_TAR}\" ..."
if [ -f ${PQ1_TAR} ]; then
    print_okay
else
    print_missing
    cd "${TEMP_PATH}/app/"
    mv "Police Quest 1" PQ1
    tar -czf "${MAKERPM_DIR}/${PQ1_TAR}" "PQ1"
    cd ${MAKERPM_DIR}
fi

##################################################################################
## prepare PQ1VGA
##################################################################################
echo -n "Check for existing PQ1VGA package \"${PQ1VGA_TAR}\" ..."
if [ -f ${PQ1VGA_TAR} ]; then
    print_okay
else
    print_missing
    cd "${TEMP_PATH}/app/"
    mv "Police Quest 1 VGA" PQ1VGA
    tar -czf "${MAKERPM_DIR}/${PQ1VGA_TAR}" "PQ1VGA"
    cd ${MAKERPM_DIR}
fi

echo -n "Check for existing PQ1VGA-Spec \"${PQ1VGA_SPEC}\" ..."
if [ -f ${PQ1VGA_SPEC} ]; then
    print_okay
else
    print_missing
    download_spec ${PQ1VGA_SPEC} ${GITHUB_SPEC}
fi

echo -n "Check for existing PQ1VGA-Icon \"${PQ1VGA_ICON}\" ..."
if [ -f ${PQ1VGA_ICON} ]; then
    print_okay
else
    print_missing
    download_spec ${PQ1VGA_ICON} ${GITHUB_ICON}
fi

echo -n "Check for existing PQ1VGA.desktop \"${PQ1VGA_DESKTOP}\" ..."
if [ -f ${PQ1VGA_DESKTOP} ]; then
    print_okay
else
    print_missing
    download_spec ${PQ1VGA_DESKTOP} ${GITHUB_DESKTOP}
fi

echo -n "Check for existing PQ1VGA-Script \"${PQ1VGA_SCRIPT}\" ..."
if [ -f ${PQ1VGA_SCRIPT} ]; then
    print_okay
else
    print_missing
    download_spec ${PQ1VGA_SCRIPT} ${GITHUB_SCRIPT}
fi

##################################################################################
## prepare PQ2
##################################################################################
echo -n "Check for existing PQ2 package \"${PQ2_TAR}\" ..."
if [ -f ${PQ2_TAR} ]; then
    print_okay
else
    print_missing
    cd "${TEMP_PATH}/app/"
    mv "Police Quest 2" PQ2
    tar -czf "${MAKERPM_DIR}/${PQ2_TAR}" "PQ2"
    cd ${MAKERPM_DIR}
fi

##################################################################################
## prepare PQ3
##################################################################################
echo -n "Check for existing PQ3 package \"${PQ3_TAR}\" ..."
if [ -f ${PQ3_TAR} ]; then
    print_okay
else
    print_missing
    cd "${TEMP_PATH}/app/"
    mv "Police Quest 3" PQ3
    tar -czf "${MAKERPM_DIR}/${PQ3_TAR}" "PQ3"
    cd ${MAKERPM_DIR}
fi

# clean up
rm -Rf ${TEMP_PATH}

# exit here if the option -d or --downloadonly is set
if [ "${DOWNLOADONLY}" = "true" ]; then
    echo "Finish! Have a lot of fun!"
    exit 0
fi

echo -n -e "Copying archives with binaries to rpmbuild working directory ..."
copy_source_file ${PQ1_TAR}
copy_source_file ${PQ1VGA_TAR}
copy_source_file ${PQ2_TAR}
copy_source_file ${PQ3_TAR}
print_okay

echo -n -e "Copying icons to rpmbuild working directory ..."
copy_source_file ${PQ1_ICON}
copy_source_file ${PQ1VGA_ICON}
copy_source_file ${PQ2_ICON}
copy_source_file ${PQ3_ICON}
print_okay

echo -n -e "Copying start scripts to rpmbuild working directory ..."
copy_source_file ${PQ1_SCRIPT}
copy_source_file ${PQ1VGA_SCRIPT}
copy_source_file ${PQ2_SCRIPT}
copy_source_file ${PQ3_SCRIPT}
print_okay

echo -n -e "Copying .desktop-files to rpmbuild working directory ..."
copy_source_file ${PQ1_DESKTOP}
copy_source_file ${PQ1VGA_DESKTOP}
copy_source_file ${PQ2_DESKTOP}
copy_source_file ${PQ3_DESKTOP}
print_okay

echo -n -e "Build the PQ1 RPM-Package ..."
rpmbuild -bb --quiet ${PQ1_SPEC}
if [ $? -ne 0 ]; then
    echo -n -e "\n   Error: RPM-Build failed!"
    print_failure
    exit 1
fi
print_okay
mv -f "${RPMBUILD_RPMDIR}${PQ1_RPM}" ${PQ1_RPM}

echo -n -e "Build the PQ1VGA RPM-Package ..."
rpmbuild -bb --quiet ${PQ1VGA_SPEC}
if [ $? -ne 0 ]; then
    echo -n -e "\n   Error: RPM-Build failed!"
    print_failure
    exit 1
fi
print_okay
mv -f "${RPMBUILD_RPMDIR}${PQ1VGA_RPM}" ${PQ1VGA_RPM}

echo -n -e "Build the PQ2 RPM-Package ..."
rpmbuild -bb --quiet ${PQ2_SPEC}
if [ $? -ne 0 ]; then
    echo -n -e "\n   Error: RPM-Build failed!"
    print_failure
    exit 1
fi
print_okay
mv -f "${RPMBUILD_RPMDIR}${PQ2_RPM}" ${PQ2_RPM}

echo -n -e "Build the PQ3 RPM-Package ..."
rpmbuild -bb --quiet ${PQ3_SPEC}
if [ $? -ne 0 ]; then
    echo -n -e "\n   Error: RPM-Build failed!"
    print_failure
    exit 1
fi
print_okay
mv -f "${RPMBUILD_RPMDIR}${PQ3_RPM}" ${PQ3_RPM}

rm -Rf ${RPMBUILD_WORKINGDIR}

if [ "${KEEP_FILES}" = "false" ]; then
    # clean up
    rm ${PQ1_TAR}
    rm ${PQ1_SPEC}
    rm ${PQ1_SCRIPT}
    rm ${PQ1_DESKTOP}

    rm ${PQ1VGA_TAR}
    rm ${PQ1VGA_SPEC}
    rm ${PQ1VGA_SCRIPT}
    rm ${PQ1VGA_DESKTOP}

    rm ${PQ2_TAR}
    rm ${PQ2_SPEC}
    rm ${PQ2_SCRIPT}
    rm ${PQ2_DESKTOP}

    rm ${PQ3_TAR}
    rm ${PQ3_SPEC}
    rm ${PQ3_SCRIPT}
    rm ${PQ3_DESKTOP}
fi

# exit here if the option -b or --buildonly is set
if [ "${BUILDONLY}" = "true" ]; then
    echo "Finish! Have a lot of fun!"
    exit 0
fi

echo -n "Check for running this script as root ..."
if [ "$(whoami)" != "root" ]; then
    echo -n -e "\n   Error: For installation this script needs to run as root!"
    print_failure
    exit 1
fi
print_okay

zypper -v -n in ${STEAM_RPM}

