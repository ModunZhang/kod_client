total_array=()
function Array2String()
{
	local str=""
	for item in $@
	do
		if [ "$str" = "" ]; then
			str=$item
		else
			str=$str".*"$item
		fi
	done
	echo $str
}
function Begin()
{
	echo "开始在在代码里面检索图片文件名。。。。。"
}
function End()
{
	if [ ${#total_array[*]} -gt 0 ]; then
		echo "找到未使用的图片:"
		for png_name in ${total_array[*]}
		do
			echo "\\033[31m"$png_name"\\033[0m"
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
function ScanPng1()
{
	local png_name=$1
	local arrays=(${png_name//_/ });
	local total_count=${#arrays[@]}
	local count=0
	for item in ${png_name//_/ }
	do
		local names=(${png_name//_/ });	
		if [ $total_count -gt 1 ]; then
			unset names[$count]
			count=$count+1
		fi
		local result=$(grep -rle $(echo $(Array2String ${names[*]})) ../../scripts/app ../../res/tmxmaps)
		local array=(${result// / });
		local c=${#array[*]}
		if [ $c -gt 0 ]; then
			echo "find" $c "in files," "\\033[32m$png_name\\033[0m" "from head file : " "\\033[32m"${array[0]}"\033[0m"
			return
		fi
	done
	echo "not find" "\\033[31m"$png_name"\\033[0m"
	total_array[${#total_array[*]}]=$png_name
	####
	# echo $(grep -e "${names[0]}.*${names[1]}.*" ../../scripts/app/service/AllianceManager.lua)
	# local result=$(grep -rle $png_name ../../scripts/app ../../res/tmxmaps)
	# local array=(${result// / });
	# if [ ${#array[*]} -gt 0 ]; then
	# 	echo "find" ${#array[*]} "in files" $png_name
	# else
	# 	echo "not find" $png_name
	# 	total_array[${#total_array[*]}]=$png_name
	# fi
}

# cat birds.txt  
  
# echo  
# echo "grep bird birds.txt..." 

# grep "alliance_graphic_1" birds.txt 

# echo
# a="alliance_graphic_1"
# for item in ${a//_/ }
# do
# 	echo $item
# done


function ScanPng2()
{
	local png_name=$1
	local result=$(grep -wrle $png_name $script_path)
	local array=(${result// / });
	if [ ${#array[*]} -gt 0 ]; then
		echo "find" ${#array[*]} "in files" $png_name
	else
		echo "not find" $png_name
		total_array[${#total_array[*]}]=$png_name
	fi
}

# cd ../../res/tmxmaps
# res_path=$(pwd)
# cd ../../../tools
# cd $1

cur_path=$(pwd)

cd $cur_path
cd ../dev/scripts/app/
script_path=$(pwd)

cd $cur_path
cd ../dev/res/images
res_path=$(pwd)

Begin;
files=(*.png) 
for f in ${files[*]}
do
	if [ ${f##*.} != "sh" ]; then
		ScanPng2 $f
	fi
done
End;


# Begin;
# if [ ${#@} -gt 0 ]; then
# 	for png_name in ${@}
# 	do
# 		if [ ${png_name##*.} != "sh" ]; then
# 			ScanPng2 $png_name
# 		fi
# 	done
# else
# 	echo "无效文件名"
# 	echo "usage:" "delete_none_use.sh files"
# 	exit 1
# fi
# End;

# while read LINE
# do
# rm -f $LINE
# done  < "pngs.sh"



# echo $(grep -rl "grass_80x80.png" ../../scripts/app ../../res/tmxmaps)

# png_name="alliansfe"
# for item in ${png_name//_/ }
# do
# 	names=(${png_name//_/ });
# 	Array2String ${names[*]};
# 	# let str="$str$item" 
# done

