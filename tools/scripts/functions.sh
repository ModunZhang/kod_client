#! /bin/bash

set -e
#todo android
PLATFORMS="iOS"
EncryptTypes="true false"

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
$@