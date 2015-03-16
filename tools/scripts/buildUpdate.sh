#!/bin/bash
Platform=`./functions.sh getPlatform $1`
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$DOCROOT/../../

echo ---------------- 清理文件
rm -rf $PROJ_DIR/update
echo ---------------- 编译代码
sh buildGame.sh $Platform false false

echo ---------------- 提交代码
# cd $PROJ_DIR
# git add -A
# git commit -m "commit any uncommitted files"
# cd $DOCROOT

echo ---------------- 检查更新
# cd $DOCROOT/../buildUpdate
# python buildUpdate.py
# cd $DOCROOT

echo ---------------- 同步代码
cd $PROJ_DIR
# cp -r ../update ../../server/update-server/public
# rsync -rave "ssh " --exclude=.DS_Store*  ../update ec2-user@ec2-54-178-151-193.ap-northeast-1.compute.amazonaws.com:~/server/update-server/public/


echo ---------------- 提交代码
# git add --all .
# git commit -m "update new version"
# git push
cd $DOCROOT

