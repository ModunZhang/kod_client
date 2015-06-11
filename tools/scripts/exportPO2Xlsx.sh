#! /bin/bash
#导出po文件为excel文件
PROJ_DIR=`./functions.sh getProjDir`
I18N_DIR="$PROJ_DIR/dev/res/i18n"
FILE_NAME=""
EXPORT_EXCEL_PATH=$1
EXPORT_EXCEL_PATH=${EXPORT_EXCEL_PATH:="i18n.xlsx"}

for file in $I18N_DIR/*.po; do
	FILE_NAME="$FILE_NAME $file"
done
echo ">开始导出Po文件到Excel"
po-to-xls -o $EXPORT_EXCEL_PATH $FILE_NAME
echo "导出Excel文件结束:$EXPORT_EXCEL_PATH"