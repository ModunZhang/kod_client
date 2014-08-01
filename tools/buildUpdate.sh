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

# rsync -rave "ssh -i /Users/modun/.ssh/T4FMacBookPro-EC2.pem" --exclude=.DS_Store*  ../res/ ubuntu@ec2-54-254-249-17.ap-southeast-1.compute.amazonaws.com:~/BFServer/update-server/public/res/
# rsync -rave "ssh -i /Users/modun/.ssh/T4FMacBookPro-EC2.pem" --exclude=.DS_Store*  ../target/ ubuntu@ec2-54-254-249-17.ap-southeast-1.compute.amazonaws.com:~/BFServer/update-server/public/target/
# # ssh -i /Users/modun/.ssh/T4FMacBookPro-EC2.pem ubuntu@ec2-54-254-249-17.ap-southeast-1.compute.amazonaws.com 'pomelo kill -f; pomelo start -e production -D -d ~/BFServer/game-server; pomelo start -D -d ~/BFServer/update-server'

# echo ---------------- 提交代码
# cd ..
# git add --all .
# git commit -m "update new version"
# git push
# cd buildUpdate

echo ---------------- 自动更新完成