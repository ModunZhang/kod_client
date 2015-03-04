#!/bin/bash

#加密的Key
XXTEAKey="Cbcm78HuH60MCfA7"
#加密的签名
XXTEASign="XXTEA"
ENCRYPT=false
#如果是Xcode执行 并且为Debug模式目标平台为模拟器 便不加密 否则其他所有情况将加密代码和图片资源
# $PLATFORM_NAME "iphonesimulator"
if test "${CONFIGURATION}" = "Debug"; then
	ENCRYPT=false
fi
export LocalBin="/usr/local/bin/"
export PATH=$LocalBin:$PATH
SCRIPT_COMPILE_TOOL=$QUICK_V3_ROOT/quick/bin/compile_scripts.sh
RES_COMPILE_TOOL=$QUICK_V3_ROOT/quick/bin/pack_files.sh
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION_FILE=$DOCROOT/../../dev/scripts/debug_version.lua
DESTROOT=$DOCROOT/../../update
if  test -d $DESTROOT ; then
	#clean
	cd $DESTROOT
	rm -rfv *
	cd $DOCROOT/
else
	mkdir $DESTROOT
fi
echo "------------------------------------"
echo "\033[32m [INFO]Clean Update folder Success! \033[0m"
cd $DOCROOT/../../
#获取内部版本
TIME_VERSION=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
echo "------------------------------------"
echo "\033[32m [INFO]Debug Version:  $TIME_VERSION \033[0m"
echo "local __debugVer = ${TIME_VERSION}
return __debugVer
" > $VERSION_FILE
echo "------------------------------------"
cd $DOCROOT

RESOURCEROOT=$DOCROOT/../../dev

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
	$SCRIPT_COMPILE_TOOL -i $RESOURCEROOT/scripts -o $outdir -m files -e xxtea_chunk -ex lua -ek $XXTEAKey -es $XXTEASign
}
exportResEncrypt()
{
	outdir=$DESTROOT/res
	$RES_COMPILE_TOOL -i $RESOURCEROOT/res/images -o $outdir/images -ek $XXTEAKey -es $XXTEASign
	$RES_COMPILE_TOOL -i $RESOURCEROOT/res/animations -o $outdir/animations -ek $XXTEAKey -es $XXTEASign
}

if $ENCRYPT; then
	echo "\033[32m [INFO] Encrypt is Open! \033[0m"
	echo "------------------------------------"
	exportRes $RESOURCEROOT/res
	exportResEncrypt
	exportScriptsEncrypt
else
	echo "\033[32m [INFO] Encrypt is Close! \033[0m"
	echo "------------------------------------"
	exportRes $RESOURCEROOT/res
	exportScripts $RESOURCEROOT/scripts
fi
#清除临时文件
find $RESOURCEROOT/res -name "*.tmp" -exec rm -r {} \;
find $DESTROOT/* -exec touch {} \;