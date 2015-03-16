#! /bin/bash
Platform=$1
NEED_ENCRYPT_RES=$2
RES_COMPILE_TOOL=`./functions.sh getResourceTool`
RES_SRC_DIR=`./functions.sh getResourceDir`
RES_DEST_DIR=`./functions.sh getExportResourcesDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`

exportRes()
{
	currentDir=$1
	outdir=$RES_DEST_DIR
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

exportResEncrypt()
{
	outdir=$RES_DEST_DIR
	$RES_COMPILE_TOOL -i $RES_SRC_DIR/images -o $outdir/images -ek $XXTEAKey -es $XXTEASign
	$RES_COMPILE_TOOL -i $RES_SRC_DIR/animations -o $outdir/animations -ek $XXTEAKey -es $XXTEASign
}

if $NEED_ENCRYPT_RES; then
	exportResEncrypt
else
	exportRes $RES_SRC_DIR
fi

#清除临时文件
find $RES_DEST_DIR -name "*.tmp" -exec rm -r {} \;