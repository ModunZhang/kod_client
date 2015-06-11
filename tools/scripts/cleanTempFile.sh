#清理脚本生成的临时文件
echo "> 清理脚本生成的临时文件"

SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
TEMP_RES_DIR=`./functions.sh getTempDir`

echo -- $TEMP_RES_DIR
rm -rf "$TEMP_RES_DIR"
echo -- $SCRIPTS_SRC_DIR
find $SCRIPTS_SRC_DIR -name "*.bytes" -exec rm -rfv {} \;