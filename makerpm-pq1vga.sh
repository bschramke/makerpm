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

SCRIPTVERSION="0.1"
AUTHOR="Björn Schramke"
AUTHOR_MAIL="bjoern@schramke-online.de"

GITHUB_URL="https://raw.github.com/bschramke/makerpm/"
GITHUB_SPEC="${GITHUB_URL}master/PQ1VGA.spec"
GITHUB_ICON="${GITHUB_URL}master/PQ1.png"
GITHUB_SCRIPT="${GITHUB_URL}master/PQ1VGA"
GITHUB_DESKTOP="${GITHUB_URL}master/PQ1VGA.desktop"

RPMBUILD_WORKINGDIR=~/rpmbuild/
RPMBUILD_SOURCEDIR=${RPMBUILD_WORKINGDIR}SOURCES/
RPMBUILD_RPMDIR=${RPMBUILD_WORKINGDIR}RPMS/noarch/

PQ1VGA_VERSION="2.0.0"
PQ1VGA_SPEC="PQ1VGA.spec"
PQ1VGA_TAR="PQ1VGA.tar.gz"
PQ1VGA_ICON="PQ1.png"
PQ1VGA_DESKTOP="PQ1VGA.desktop"
PQ1VGA_SCRIPT="PQ1VGA"

# set default configuration
BUILDONLY="true"
DOWNLOADONLY="false"
KEEP_FILES="false"
INSTALL="false"
UNINSTALL="false"

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
################################################################################

echo -n "Check for existing PQ1VGA package \"${PQ1VGA_TAR}\" ..."
if [ -f ${PQ1VGA_TAR} ]; then
    print_okay
else
    print_missing
    exit 1
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

# exit here if the option -d or --downloadonly is set
if [ "${DOWNLOADONLY}" = "true" ]; then
    echo "Finish! Have a lot of fun!"
    exit 0
fi

check_install rpm-build
check_workingdir

echo -n -e "Copying archive with binaries to rpmbuild working directory ..."
copy_source_file ${PQ1VGA_TAR}
print_okay

echo -n -e "Copying icon to rpmbuild working directory ..."
copy_source_file ${PQ1VGA_ICON}
print_okay

echo -n -e "Copying start script to rpmbuild working directory ..."
copy_source_file ${PQ1VGA_SCRIPT}
print_okay

echo -n -e "Copying .desktop-file to rpmbuild working directory ..."
copy_source_file ${PQ1VGA_DESKTOP}
print_okay

echo -n -e "Build the RPM-Package ..."
rpmbuild -bb --clean --rmsource --quiet ${PQ1VGA_SPEC}
if [ $? -ne 0 ]; then
    echo -n -e "\n   Error: RPM-Build failed!"
    print_failure
    exit 1
fi
print_okay

#mv -f "${RPMBUILD_RPMDIR}${STEAM_RPM}" ${STEAM_RPM}

#rm -Rf ${RPMBUILD_WORKINGDIR}

if [ "${KEEP_FILES}" = "false" ]; then
    # clean up
    rm ${PQ1VGA_TAR}
    rm ${PQ1VGA_SPEC}
    rm ${PQ1VGA_SCRIPT}
    rm ${PQ1VGA_DESKTOP}
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

