#!/bin/bash
export LocalBin="/usr/local/bin/"
export PATH=$LocalBin:$PATH
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION_FILE=$DOCROOT/../../dev/scripts/debug_version.lua
DESTROOT=$DOCROOT/../../update

gitDebugVersion()
{
	cd $DOCROOT/../../
	#获取内部版本
	TIME_VERSION=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
	echo "------------------------------------"
	echo "> Debug Version:  $TIME_VERSION"
	echo "local __debugVer = ${TIME_VERSION}
		return __debugVer
	" > $VERSION_FILE
	echo "------------------------------------"
	cd $DOCROOT
}

if test "${CONFIGURATION}" = "Debug"; then
	gitDebugVersion
fi

cd $DOCROOT/../../tools/scripts

if test "${CONFIGURATION}" = "Debug"; then
	sh buildGame.sh iOS false false
else
	sh buildGame.sh iOS true true
fi

cd $DOCROOT
find $DESTROOT/* -exec touch {} \;