total_array=()
function Begin()
{
	echo "开始在在代码里面检索图片文件名。。。。。"
}
function End()
{
	if [ ${#total_array[*]} -gt 0 ]; then
		echo "找到为使用的图片:"
		for png_name in ${total_array[*]}
		do
			echo $png_name
		done
		echo "是否删除这些图片?y/n"

		read ANS
		case $ANS in    
		y|Y|yes|Yes) 
		        for png_name in ${total_array[*]}
				do
					rm -f $png_name
				done
				echo "删除完毕!"
		        ;;
		n|N|no|No)
		        exit 0
		        ;;
		esac
	else
		echo "没有发现未使用的图片。。。恭喜!!!"
	fi
}
function ScanPng()
{
	local png_name=$1
	local result=$(grep -rl $png_name ../../scripts/app ../../res/tmxmaps)
	local array=(${result// / });
	if [ ${#array[*]} -gt 0 ]; then
		echo "find" ${#array[*]} "in files" $png_name
	else
		echo "not find" $png_name
		total_array[${#total_array[*]}]=$png_name
	fi
}
Begin;
if [ ${#@} -gt 0 ]; then
	for png_name in ${@}
	do
		ScanPng $png_name
	done
else
	echo "无效文件名"
	echo "usage:" "delete_none_use.sh files"
	exit 1
fi
End;

# while read LINE
# do
# rm -f $LINE
# done  < "pngs.sh"



# echo $(grep -rl "grass_80x80.png" ../../scripts/app ../../res/tmxmaps)


