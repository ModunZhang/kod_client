#!/bin/bash
#上传自动更新数据到服务器
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Platform=`./functions.sh getPlatform $1`
ROOT_DIR=`./functions.sh getProjDir`
UPDATE_SOURCE_DIR=`./functions.sh getExportDir $Platform`
GIT_OF_UPDATE="$ROOT_DIR/../kod_auto_update/public"

echo "> 同步文件夹 $UPDATE_SOURCE_DIR --> $GIT_OF_UPDATE"


rsync -ravc "$UPDATE_SOURCE_DIR" $GIT_OF_UPDATE --delete-after


pushDataToGit()
{
	cd "$GIT_OF_UPDATE"
	git add --all
	git commit -m "发布新的自动更新"
	git push
	cd "$DOCROOT"
}

if [ $? == 0 ]; then
	echo "-----文件夹同步成功"
	pushDataToGit
else
	echo "-----错误!"
fi

