#!/bin/bash
#Error.xls 修改了列的标题
ClientDir=../../dev/scripts/app/datas
GameDataDir=../../gameData

test -d $ClientDir || mkdir -p $ClientDir

python ../buildGameData/buildGameData.py $GameDataDir $ClientDir "client"