Platform=`./functions.sh getPlatform $1`
APP_VERSION=`./functions.sh getAppVersion $Platform`
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$DOCROOT/../../
APP_MIN_VERSION=`./functions.sh getAppMinVersion $Platform`
APP_BUILD_TAG=`./functions.sh getAppBuildTag $Platform`
echo ---------------- 检查更新
cd $DOCROOT/../buildUpdate
echo "buildUpdate.py" $APP_VERSION $APP_MIN_VERSION $APP_BUILD_TAG
python buildUpdate.py $APP_VERSION $APP_MIN_VERSION $APP_BUILD_TAG
cd $DOCROOT