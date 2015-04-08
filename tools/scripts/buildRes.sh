#! /bin/bash
Platform=$1
NEED_ENCRYPT_RES=$2
RES_COMPILE_TOOL=`./functions.sh getResourceTool`
RES_SRC_DIR=`./functions.sh getResourceDir`
RES_DEST_DIR=`./functions.sh getExportResourcesDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`
PVRTOOL=`./functions.sh getPVRTexTool`
IMAGEFORMAT="PVRTC1_4"

# rm -rf $RES_DEST_DIR
exportImagesRes()
{
	images_dir=$1
	outdir=$RES_DEST_DIR
	for file in $images_dir/*.png $images_dir/*.jpg 
	do
		outfile=$outdir/${file##*/res/}
		finalDir=${outfile%/*}
		if test "$file" -nt "$outfile";then
			test -d $finalDir || mkdir -p $finalDir && cp  "$file" $finalDir
		fi
	done

	for file in $images_dir/_Compressed/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			if test "$file" -nt "$outfile"; then
				test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
			fi
		fi
	done

	for file in $images_dir/_CanCompress/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			if test "$file" -nt "$outfile"; then
				#compress image
				$PVRTOOL -f $IMAGEFORMAT -i $file -o ${file%.*}.pvr
				echo "$PVRTOOL -f $IMAGEFORMAT -i $file -o ${file%.*}.pvr"
				mv ${file%.*}.pvr $outfile
			fi
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
		elif test -d "$file";then
			if [[ ${file/"images"//} != $file ]];then
	    		exportImagesRes $file
	    	else
				exportRes $file
	    	fi
		fi
    done
}
#TODO:修改加密脚本
exportResEncrypt()
{
	outdir=$RES_DEST_DIR
	$RES_COMPILE_TOOL -i $RES_SRC_DIR/images -o $outdir/images -ek $XXTEAKey -es $XXTEASign
	$RES_COMPILE_TOOL -i $RES_SRC_DIR/animations -o $outdir/animations -ek $XXTEAKey -es $XXTEASign
}

if $NEED_ENCRYPT_RES; then
	exportResEncrypt
	#清除临时文件
	find $RES_SRC_DIR -name "*.tmp" -exec rm -r {} \;
else
	exportRes $RES_SRC_DIR
fi

