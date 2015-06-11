#! /bin/bash
#导出贴图到images下面
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
ProjDir=`./functions.sh getProjDir`
TPS_FILES_DIR="${ProjDir}/PackImages/TexturePackerProj/player"
if [[ $Platform == 'iOS' ]]; then
	TPS_FILES_DIR="${ProjDir}/PackImages/TexturePackerProj/iOS"
fi
echo "> 开始导出贴图 ${Platform}"
TexturePacker "${TPS_FILES_DIR}"/*.tps