#!/bin/bash

echo ---------------- 编译代码
sh ../proj/pre-actions.sh


echo ---------------- 提交代码
cd ..
git add -A
git commit -m "commit any uncommitted files"
cd tools


echo ---------------- 检查更新
cd buildUpdate
python buildUpdate.py
cd ..

echo ---------------- 同步代码
cp -r ../update ../../server/update-server/public

rsync -rave "ssh -i /Users/modun/.ssh/ModunsMBP.pem" --exclude=.DS_Store*  ../update ec2-user@ec2-54-178-151-193.ap-northeast-1.compute.amazonaws.com:~/server/update-server/public/update

echo ---------------- 提交代码
cd ..
git add --all .
git commit -m "update new version"
git push
cd buildUpdate

echo ---------------- 自动更新完成