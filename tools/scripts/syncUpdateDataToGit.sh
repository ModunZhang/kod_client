#!/bin/bash
#上传更新数据到自动更新指定的git仓库
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Platform=`./functions.sh getPlatform $1`
UPDATE_SOURCE_DIR=`./functions.sh getExportDir $Platform`
XCODE_CONFIGURATION=`./functions.sh getConfiguration $2`
PATH_OF_GIT_AUTOUPDATE=`./functions.sh  getGitPushOfAutoUpdate $XCODE_CONFIGURATION`
TARGET_PATH="$PATH_OF_GIT_AUTOUPDATE/public"

pullGitData()
{
	cd "$PATH_OF_GIT_AUTOUPDATE"
	git reset --hard HEAD
	git clean -df
	git pull
	cd "$DOCROOT"
}
echo "> 更新仓库内容"
pullGitData

echo "> $Platform $XCODE_CONFIGURATION 同步文件夹 $UPDATE_SOURCE_DIR --> $TARGET_PATH"

rsync -ravc --exclude=.DS_Store* "$UPDATE_SOURCE_DIR" $TARGET_PATH --delete-after

pushDataToGit()
{
	
	cd "$PATH_OF_GIT_AUTOUPDATE"
	git add --all
	git ci -m "发布新的自动更新"
	git push
	cd "$DOCROOT"
}

if [ $? == 0 ]; then
	echo "> 本地拷贝文件完成 开始上传到github"
	pushDataToGit 
	echo "> 文件夹同步成功 手动ssh到更新服务器部署!"
else
	echo "> 错误!"
fi