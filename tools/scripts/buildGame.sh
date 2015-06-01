#!/bin/bash

Platform=`./functions.sh getPlatform $1`
NEED_ENCRYPT_SCRIPTS=`./functions.sh getNeedEncryptScripts $2`
NEED_ENCRYPT_RES=`./functions.sh getNeedEncryptResources $3`

echo "> 开始处理脚本"
echo "------------------------------------"
./buildScripts.sh $Platform $NEED_ENCRYPT_SCRIPTS

echo "> 开始处理资源"
echo "------------------------------------"
./buildRes.sh $Platform $NEED_ENCRYPT_RES

./cleanTempFile.sh