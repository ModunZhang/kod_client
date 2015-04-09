#! /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Platform=`./functions.sh getPlatform $1`
ExportDir=`./functions.sh getExportDir $Platform`
ProjDir=`./functions.sh getProjDir`


echo "> 开始清理项目"
echo "------------------------------------"
cd $ProjDir
if test $Platform == "iOS"; then
	echo "-- $ExportDir/*"
	rm -rf $ExportDir/*
fi
echo "> 完成清理项目"
echo "------------------------------------"