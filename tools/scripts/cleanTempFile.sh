#清理脚本生成的临时文件
echo "> 清理脚本生成的临时文件"
SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
find $SCRIPTS_SRC_DIR -name "*.bytes" -exec rm -rfv {} \;