#! /bin/bash
Platform=$1
NEED_ENCRYPT_RES=$2
RES_COMPILE_TOOL=`./functions.sh getResourceTool`
RES_SRC_DIR=`./functions.sh getResourceDir`
RES_DEST_DIR=`./functions.sh getExportResourcesDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`
# PVRTOOL=`./functions.sh getPVRTexTool`
# IMAGEFORMAT="PVRTC1_4"
TEMP_RES_DIR=`./functions.sh getTempDir`

exportImagesRes()
{
	echo -- 处理images文件夹
	images_dir=$1
	outdir=$RES_DEST_DIR
	for file in $images_dir/*.png $images_dir/*.jpg 
	do
		outfile=$outdir/${file##*/res/}
		finalDir=${outfile%/*}
		if test "$file" -nt "$outfile";then
			echo "---- ${file##*/res/}"
			if $NEED_ENCRYPT_RES; then
				test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$file" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
			else
				test -d $finalDir || mkdir -p $finalDir && cp  "$file" $finalDir
			fi
		fi
	done
	echo -- 处理_Compressed文件夹
	for file in $images_dir/_Compressed/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			fileExt=${file##*.}
			if test "$file" -nt "$outfile"; then
				echo "---- ${file##*/}"
				if test $fileExt == "plist" || test $fileExt == "ExportJson";then
					test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
				else
					if $NEED_ENCRYPT_RES;then
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$file" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					else
						test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
					fi
				fi
			fi
		fi
	done
	echo -- 处理rgba444_single文件夹
	for file in $images_dir/rgba444_single/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			tempfile="$TEMP_RES_DIR/${file##*/}"
			fileExt=${file##*.}
			if test "$file" -nt "$outfile"; then
				echo "---- ${file##*/}"
				if test $fileExt == "plist" || test $fileExt == "ExportJson";then
					test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
				else
					#是否考虑 pvr ccz + premultiply-alpha?
					TexturePacker --format cocos2d --no-trim --disable-rotation --texture-format png --opt RGBA4444 --png-opt-level 7  --allow-free-size --padding 0 "$file" --sheet "$tempfile" --data "$TEMP_RES_DIR/tmp.plist"
					if $NEED_ENCRYPT_RES;then
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempfile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					else
						test -d $finalDir || mkdir -p $finalDir && cp "$tempfile" $finalDir
					fi
				fi
			fi
		fi
	done
	echo -- 处理_CanCompress文件夹
	for file in $images_dir/_CanCompress/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			tempfileName="${file%.*}"
			tempfileName="${tempfileName##*/}"
			tempfile="${TEMP_RES_DIR}/${tempfileName}.pvr"
			if test "$file" -nt "$outfile"; then
				echo "---- ${file##*/}"
				#$PVRTOOL -p -f $IMAGEFORMAT -i $file -o ${file%.*}.pvr
				TexturePacker --format cocos2d --no-trim --disable-rotation --texture-format pvr2 --premultiply-alpha --opt PVRTC4 --padding 0 "$file" --sheet "$tempfile" --data "$TEMP_RES_DIR/tmp.plist"
				cp -f $tempfile "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png"
				if $NEED_ENCRYPT_RES;then
					$RES_COMPILE_TOOL -i "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					mv -f "$finalDir/${tempfileName}_PVR_PNG.png" $outfile
					rm -f "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png"
				else
					mv -f "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png" $outfile
				fi
			fi
		fi
	done
}

exportAnimationsRes()
{
	echo -- 处理Animations文件夹
	images_dir=$1
	outdir=$RES_DEST_DIR
	for file in $images_dir/* 
	do
		if test -f "$file";then
			outfile=$outdir/${file##*/res/}
			finalDir=${outfile%/*}
			fileExt=${file##*.}
			if test "$file" -nt "$outfile";then
				echo "---- ${file##*/res/}"
				if test $fileExt == "plist" || test $fileExt == "ExportJson";then
					test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
				else
					if $NEED_ENCRYPT_RES; then
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$file" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					else
						test -d $finalDir || mkdir -p $finalDir && cp  "$file" $finalDir
					fi
				fi
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
			oldlen=$(ls -al "$file" | awk '{print $5}')
			newlen=$(ls -al "$outfile" | awk '{print $5}')
			if test "$file" -nt "$outfile";then
		    	test -d "$finalDir" || mkdir -p "$finalDir" && cp "$file" "$finalDir"
		    elif [ $oldlen -ne $newlen ]; then
		    	test -d "$finalDir" || mkdir -p "$finalDir" && cp "$file" "$finalDir"
		    fi
		elif test -d "$file";then
			dir_name=${file##*/dev/res/}
			if [[ "images" == $dir_name ]];then
	    		exportImagesRes $file
	    	elif [[ "animations" == $dir_name ]];then
	    		exportAnimationsRes $file
	    	elif [[ "animations_mac" == $dir_name ]];then
	    		echo -- 不处理animations_mac文件夹
	    	else
				exportRes $file
	    	fi
		fi
    done
}
#清除临时文件
find "$RES_SRC_DIR" -name "*.tmp" -exec rm -r {} \;
exportRes "$RES_SRC_DIR"
echo ">资源处理完成"