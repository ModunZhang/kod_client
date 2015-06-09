#! /bin/bash
#通过plist文件生成包含大图信息的lua文件
####################################
PLATFORMS="iOS Player"
getPlatform()
{
Platform=$1
if [[ -z $Platform ]]
then
    echo "Platform :" >&2
    select Platform in $PLATFORMS
    do
        if [[ -n $Platform ]]
        then
            break
        fi
    done
fi
echo $Platform
}
####################################

Platform=`getPlatform $1`
SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
RES_SRC_DIR=`./functions.sh getResourceDir`
EXPORT_FILE_PATH=""
PLIST_PATH=""

if [[ $Platform == 'iOS' ]]; then
	EXPORT_FILE_PATH="texture_data_iOS.lua"
	PLIST_PATH="${RES_SRC_DIR}/images/_Compressed"
elif [[ $Platform == 'Player' ]]; then
	EXPORT_FILE_PATH="texture_data.lua"
	PLIST_PATH="${RES_SRC_DIR}/images/_Compressed_mac"
fi
EXPORT_FILE_PATH="${SCRIPTS_SRC_DIR}/app/${EXPORT_FILE_PATH}"
# run
python plist_texture_data_to_lua.py -p "$PLIST_PATH" -o "$EXPORT_FILE_PATH"