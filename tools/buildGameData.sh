#!/bin/bash

ClientDir=../dev/scripts/app/datas
GameDataDir=../gameData

test -d $ClientDir || mkdir -p $ClientDir

python ./buildGameData/exportGameData.py $GameDataDir $ClientDir "client"