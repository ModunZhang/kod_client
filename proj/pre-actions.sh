#!/bin/bash

export LocalBin="/usr/local/bin/"
export PATH=$LocalBin:$PATH
ENCRYPT=true
XXTEAKey="Cbcm78HuH60MCfA7"
SCRIPT_COMPILE_TOOL=$QUICK_V3_ROOT/quick/bin/compile_scripts.sh
RES_COMPILE_TOOL=$QUICK_V3_ROOT/quick/bin/pack_files.sh
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION_FILE=$DOCROOT/../dev/scripts/debug_version.lua
DESTROOT=$DOCROOT/../update
#clean
echo "------------------------------------"
echo "->Clean the update folder"
cd $DESTROOT
rm -rf *
cd $DOCROOT/
echo "------------------------------------"
echo "->Clean Success!"
cd $DOCROOT/../
#获取内部版本
TIME_VERSION=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
echo "------------------------------------"
echo "->Debug Version: " $TIME_VERSION
echo "local __debugVer = ${TIME_VERSION}
return __debugVer
" > $VERSION_FILE
cd $DOCROOT

RESOURCEROOT=$DOCROOT/../dev

# $QUICK_COCOS2DX_ROOT/bin/compile_scripts.sh  -i ${SRCROOT}/../scripts  -m files -o ${SRCROOT}/../target/scripts -e xxtea_chunk -ek "Cbcm78HuH60MCfA7"
# echo ---------------- compile lua scripts
# cd ..
# rm -rf target/scripts/*
# sh $QUICK_COCOS2DX_ROOT/bin/compile_scripts.sh  -i scripts  -m files -o target/scripts -e xxtea_chunk -ek Cbcm78HuH60MCfA7
# git add --all .
# git commit -m "compile lua scripts"
# cd buildUpdate


exportRes()
{
	currentDir=$1
	outdir=$DESTROOT/res
	for file in $currentDir/*
	do
		outfile=$outdir/${file##*/res/}
		fileExt=${file##*.}
		if test -f $file && test $fileExt != "po";then
			finalDir=${outfile%/*}
			if test $file -nt $outfile;then
		    	test -d $finalDir || mkdir -p $finalDir && cp $file $finalDir
		    fi
		elif test -d $file;then
			exportRes $file
		fi
    done
}

exportScripts()
{
	currentDir=$1
	outdir=$DESTROOT/scripts
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
	outdir=$DESTROOT/scripts
	$SCRIPT_COMPILE_TOOL -i $RESOURCEROOT/scripts -o $outdir -m files -e xxtea_chunk -ex lua -ek $XXTEAKey -q
}
exportResEncrypt()
{
	outdir=$DESTROOT/res/images
	$RES_COMPILE_TOOL -i $RESOURCEROOT/res/images -o $outdir -ek $XXTEAKey 
}

if $ENCRYPT; then
	exportRes $RESOURCEROOT/res
	# exportResEncrypt
	exportScriptsEncrypt
else
	exportRes $RESOURCEROOT/res
	exportScripts $RESOURCEROOT/scripts
fi

find $DESTROOT/* -exec touch {} \;