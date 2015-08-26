#! /bin/bash

Platform=$1
NEED_ENCRYPT_SCRIPTS=$2
SCRIPT_COMPILE_TOOL=`./functions.sh getScriptsTool`
SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
SCRIPTS_DEST_DIR=`./functions.sh getExportScriptsDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`
TEMP_RES_DIR=`./functions.sh getTempDir`
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ProjDir=`./functions.sh getProjDir`
VERSION_FILE="$ProjDir/dev/scripts/debug_version.lua"
test -d "$SCRIPTS_DEST_DIR" && rm -rf "$SCRIPTS_DEST_DIR/*"

python build_format_map.py -r rgba4444.lua
python build_format_map.py -j jpg_rgb888.lua
python build_animation.py -o animation.lua

gitDebugVersion()
{
	cd "$ProjDir"
	#获取内部版本
	TIME_VERSION=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
	echo "------------------------------------"
	echo "> Debug Version:  $TIME_VERSION"
	echo "local __debugVer = ${TIME_VERSION}
		return __debugVer
	" > $VERSION_FILE
	echo "------------------------------------"
	cd "$DOCROOT"
}


exportScripts()
{
	currentDir=$1
	outdir=$SCRIPTS_DEST_DIR
	for file in $currentDir/*
	do
		outfile=$outdir/${file##*/scripts/}
		fileExt=${file##*.}
		if test -f $file && test $fileExt == "lua";then
			finalDir=${outfile%/*}
			if test $file -nt $outfile;then
		    	test -d $finalDir || mkdir -p $finalDir && cp $file $finalDir
		    fi
		elif test -d $file;then
			exportScripts $file
		fi
    done
}

exportScriptsEncrypt()
{
	outdir=$SCRIPTS_DEST_DIR
	outfile="$outdir/game.zip"
	tempfile="$TEMP_RES_DIR/game.zip"
	if $NEED_ENCRYPT_SCRIPTS; then
		$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o "$tempfile" -e xxtea_zip -ex lua -ek $XXTEAKey -es $XXTEASign -q
	else
		$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o "$tempfile" -ex lua -q
	fi
	if test "$tempfile" -nt "$outfile"; then
		echo 拷贝game.zip
		cp -f "$tempfile" "$outfile"
	else
		echo 忽略game.zip
		cp -f "$tempfile"
	fi
}
gitDebugVersion
exportScriptsEncrypt 
find $SCRIPTS_SRC_DIR -name "*.bytes" -exec rm -rv {} \;
