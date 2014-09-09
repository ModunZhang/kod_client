#!/bin/bash

export LocalBin="/usr/local/bin/"
export PATH=$LocalBin:$PATH

DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DESTROOT=$DOCROOT/../update
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

exportRes $RESOURCEROOT/res
exportScripts $RESOURCEROOT/scripts

find $DESTROOT/* -exec touch {} \;