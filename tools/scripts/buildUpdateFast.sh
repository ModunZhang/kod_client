#!/bin/bash
Platform=`./functions.sh getPlatform $1`
APP_VERSION=`./functions.sh getAppVersion $Platform`
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$DOCROOT/../../
APP_MIN_VERSION=`./functions.sh getAppMinVersion $Platform`


# echo ---------------- 清理文件
# sh cleanGame.sh $Platform
# echo ---------------- 编译代码
#正式环境一定改成 true true
# sh buildGame.sh $Platform true true
echo "> 开始处理脚本"
echo "------------------------------------"
sh buildScripts.sh $Platform true

echo ---------------- 提交代码
cd $PROJ_DIR
git add -A
git commit -m "commit any uncommitted files $Platform $APP_VERSION"
cd $DOCROOT

APP_BUILD_TAG=`./functions.sh getAppBuildTag $Platform`

echo ---------------- 检查更新
cd $DOCROOT/../buildUpdate
python buildUpdate.py $APP_VERSION $APP_MIN_VERSION $APP_BUILD_TAG
cd $DOCROOT

# echo ---------------- 同步代码
# rsync -rave "ssh " --exclude=.DS_Store*  ../../update ec2-user@ec2-54-223-172-65.cn-north-1.compute.amazonaws.com.cn:~/server/update-server/public/

echo ---------------- 提交代码
cd $PROJ_DIR
git add --all .
git commit -m "update new version $Platform $APP_VERSION min:$APP_MIN_VERSION tag:$APP_BUILD_TAG" 
cd $DOCROOT
echo 提交成功 手动push到远程!

