#! /bin/bash

set -e
#todo android
PLATFORMS="iOS"
EncryptTypes="true false"
XCODE_CONFIGURATIONS="Debug Release Hotfix"

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

getProjDir()
{
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $DIR/../..
}

getResourceDir()
{
	root_dir=`getProjDir`
	echo ${root_dir}/dev/res
}

getScriptsDir()
{
	root_dir=`getProjDir`
	echo ${root_dir}/dev/scripts
}

getExportDir()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		result=${root_dir}/update
		test -d $result || mkdir -p $result && echo $result
	fi
}
getExportScriptsDir()
{
	root_dir=`getExportDir $1`
	result="${root_dir}/scripts"
	test -d $result || mkdir -p $result && echo $result
}
getExportResourcesDir()
{
	root_dir=`getExportDir $1`
	result="${root_dir}/res"
	test -d $result || mkdir -p $result && echo $result
}
getScriptsTool()
{
	echo "$QUICK_V3_ROOT/quick/bin/compile_scripts.sh"
}
getResourceTool()
{
	echo "$QUICK_V3_ROOT/quick/bin/pack_files.sh"
}
getNeedEncryptScripts()
{
	EncryptType=$1
	if [[ -z $EncryptType ]]
	then
	    echo "Scripts Encrypt:" >&2
	    select EncryptType in $EncryptTypes
	    do
	        if [[ -n $EncryptType ]]
	        then
	            break
	        fi
	    done
	fi
	echo $EncryptType
}
getNeedEncryptResources()
{
	EncryptType=$1
	if [[ -z $EncryptType ]]
	then
	    echo "Resources Encrypt:" >&2
	    select EncryptType in $EncryptTypes
	    do
	        if [[ -n $EncryptType ]]
	        then
	            break
	        fi
	    done
	fi
	echo $EncryptType
}
getXXTEAKey()
{
	echo "Cbcm78HuH60MCfA7"
}
getXXTEASign()
{
	echo "XXTEA"
}
#暂时弃用PVRTexToolCLI
getPVRTexTool()
{
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $DIR/../TextureTools/PVRTexToolCLI
}
getAppVersion()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		plist=${root_dir}/frameworks/runtime-src/proj.ios_mac/ios/Info.plist
		echo `/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" $plist`
	fi
}
getAppMinVersion()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		plist=${root_dir}/frameworks/runtime-src/proj.ios_mac/ios/Info.plist
		echo `/usr/libexec/PlistBuddy -c "print AppMinVersion" $plist`
	fi
}

getAppBuildTag()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		TAG_BUILD=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
		echo $TAG_BUILD
	fi
}
getTempDir()
{
	result="/Users/`whoami`/.DragonFall"
	test -d $result || mkdir -p $result && chmod 777 $result && echo $result
}

getConfiguration()
{
	Configuration=$1
	if [[ -z $Configuration ]]
	then
	    echo "Configuration :" >&2
	    select Configuration in $XCODE_CONFIGURATIONS
	    do
	        if [[ -n $Configuration ]]
	        then
	            break
	        fi
	    done
	fi
	echo $Configuration
}
#需要定义全局变量$RELEASE_GIT_AUTO_UPDATE为自动更新仓库
getGitPushOfAutoUpdate()
{
	Configuration=$1
	python -c "exit(0) if \"$Configuration\" in \"$XCODE_CONFIGURATIONS\".split() else exit(1)"
	echo "$RELEASE_GIT_AUTO_UPDATE"
}
gitBranchNameOfUpdateGit()
{
	Configuration=$1
	python -c "exit(0) if \"$Configuration\" in \"$XCODE_CONFIGURATIONS\".split() else exit(1)"
	if [[ $Configuration = "Debug" ]]
	then
		echo "develop"
	elif [[ $Configuration = "Release" ]]; then
		echo "master"
	else
		echo "hotfix"
	fi
}
$@