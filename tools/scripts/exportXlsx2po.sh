#! /bin/bash
#导出excel文件为po文件
PO_LANGUAGES=()
# echo 
PROJ_DIR=`./functions.sh getProjDir`
I18N_DIR="$PROJ_DIR/dev/res/i18n"
EXCEL_FILE=$1
EXCEL_FILE=${EXCEL_FILE:="i18n.xlsx"}

for file in $I18N_DIR/*.po; do
	temp_name=${file#*/i18n/}
	temp_name=${temp_name%.*}
	PO_LANGUAGES[`expr ${#PO_LANGUAGES[@]} + 1`]="$temp_name"
done

for language_code in ${PO_LANGUAGES[@]};
do
	echo "> 导出${I18N_DIR}/${language_code}.po"
	xls-to-po $language_code $EXCEL_FILE "${I18N_DIR}/${language_code}.po"
done

if [ $? == 0 ]; then
	echo "Po文件导出成功,手动更新po文件的搜索参数!"
else
	echo "Po文件导出失败 检查参数、路径和Excel的格式!"
fi