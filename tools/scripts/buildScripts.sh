#! /bin/bash

Platform=$1
NEED_ENCRYPT_SCRIPTS=$2
SCRIPT_COMPILE_TOOL=`./functions.sh getScriptsTool`
SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
SCRIPTS_DEST_DIR=`./functions.sh getExportScriptsDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`

test -d "$SCRIPTS_DEST_DIR" && rm -rf "$SCRIPTS_DEST_DIR/*"
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
	tempfile="$SCRIPTS_SRC_DIR/game.zip"
	if $NEED_ENCRYPT_SCRIPTS; then
		$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o "$tempfile" -e xxtea_zip -ex lua -ek $XXTEAKey -es $XXTEASign -q
	else
		$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o "$tempfile" -ex lua -q
	fi
	if test "$tempfile" -nt "$outfile"; then
		echo 拷贝game.zip
		mv -f "$tempfile" "$outfile"
	else
		echo 忽略game.zip
		rm -f "$tempfile"
	fi
}
exportScriptsEncrypt 
find $SCRIPTS_SRC_DIR -name "*.bytes" -exec rm -rv {} \;
