#! /bin/bash

Platform=$1
NEED_ENCRYPT_SCRIPTS=$2
SCRIPT_COMPILE_TOOL=`./functions.sh getScriptsTool`
SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
SCRIPTS_DEST_DIR=`./functions.sh getExportScriptsDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`

test -d $SCRIPTS_DEST_DIR && rm -rf $SCRIPTS_DEST_DIR

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
	$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o $outdir -m files -e xxtea_chunk -ex lua -ek $XXTEAKey -es $XXTEASign
}

if $NEED_ENCRYPT_SCRIPTS; then
	exportScriptsEncrypt 
else
	exportScripts $SCRIPTS_SRC_DIR
fi
find $SCRIPTS_DEST_DIR -name "*.bytes" -exec rm -r {} \;