#! /bin/bash
Platform=$1
NEED_ENCRYPT_RES=$2
RES_COMPILE_TOOL=`./functions.sh getResourceTool`
RES_SRC_DIR=`./functions.sh getResourceDir`
RES_DEST_DIR=`./functions.sh getExportResourcesDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`
PVRTOOL=`./functions.sh getPVRTexTool`
IMAGEFORMAT="PVRTC4"

# rm -rf $RES_DEST_DIR
exportAnimationsRes()
{
	currentDir=$1
	outdir=$RES_DEST_DIR
	for file in $currentDir/*
	do
		outfile=$outdir/${file##*/res/}
		if test -f $file;then
			fileExt=${file##*.}
			finalDir=${outfile%/*}
			if test $fileExt != "png";then
				if test $file -nt $outfile;then
		    		test -d $finalDir || mkdir -p $finalDir && cp $file $finalDir
		    	fi
			else
				if test $file -nt $outfile;then
					# if  test -n `which TexturePacker`; then
					# 	echo 处理${file##*/}
					# 	# $PVRTOOL -p -f $IMAGEFORMAT -i $file 
					# 	TexturePacker --quiet --format cocos2d --no-trim --disable-rotation --texture-format pvr2 --opt $IMAGEFORMAT  --padding 0 $file --sheet ${file%.*}.pvr
					# 	test -d $finalDir || mkdir -p $finalDir && cp ${file%.*}.pvr $outfile
					# 	rm -f ${file%.*}.pvr
					# else
						test -d $finalDir || mkdir -p $finalDir && cp $file $finalDir
					# fi
				fi
			fi
		elif test -d $file; then
			exportAnimationsRes $file
		fi
	done
}
#不复制字体文件和po文件
exportRes()
{
	currentDir=$1
	outdir=$RES_DEST_DIR
	for file in $currentDir/*
	do
		outfile=$outdir/${file##*/res/}
		fileExt=${file##*.}
		if test -f "$file" && test $fileExt != "po" && test $fileExt != "ttf";then
			finalDir=${outfile%/*}
			if test "$file" -nt "$outfile";then
		    	test -d "$finalDir" || mkdir -p "$finalDir" && cp "$file" "$finalDir"
		    fi
		elif test -d $file;then
			if [[ ${file/"animations"//} != $file ]];then
	    		exportAnimationsRes $file
	    	else
				exportRes $file
	    	fi
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
find $RES_SRC_DIR -name "*.tmp" -exec rm -r {} \;