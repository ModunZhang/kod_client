#!/bin/bash
ClientDir=../../dev/scripts/app/map
GameDataDir=../../gameData/tmxMap

echo return { > $ClientDir/pvemap.lua

count=1
for file in $GameDataDir/*.tmx
	do
		name=$(basename $file)
		echo -i $file -o $ClientDir/${name%.*}.lua
		./tmxmap2lua.py -i $file -o $ClientDir/${name%.*}.lua
		echo "import(\".pve_$count\")," >> $ClientDir/pvemap.lua
		count=$(($count+1))
	done

echo } >> $ClientDir/pvemap.lua