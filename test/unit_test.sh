#!/bin/sh
# total[0] == passed
# total[1] == failed
# total[2] == errors
# echo "\033[2J\033[0;0H"
failed=1
error=2
both=3
total=([0]=0 [1]=0 [2]=0 [3]=0);
function InitTotal()
{
	total=([0]=0 [1]=0 [2]=0 [3]=0);
}
function SummaryTotal()
{
	let total[0]=total[0]+$1[0]
	let total[1]=total[1]+$1[1]
	let total[2]=total[2]+$1[2]
	let total[3]=total[3]+1
}
function SummaryTest()
{
	local var=$(echo $(cat $1 | grep "([0-9]* passed, [0-9]* failed, [0-9]* errors)."))
	local result=$(echo $var | grep -o '[0-9]\+')
	local array=(${result// / });
	SummaryTotal array;
	if [ ${array[1]} -gt 0 ] && [ ${array[2]} -gt 0 ]; then
		return $both
	else
		if [ ${array[1]} -gt 0 ]; then
			return $failed
		elif [ ${array[2]} -gt 0 ]; then
			return $error
		fi
	fi
	return 0
}
function GetColor()
{
	local color="\033[32m"
	if [ $1 -eq $error ]; then
		color="\033[33m"
	elif [ $1 -eq $failed ]; then
		color="\033[31m"
	elif [ $1 -eq $both ]; then
		color="\033[35m"
	fi
	echo $color
}
function SummaryTestWithNoDetails()
{
	SummaryTest $2
	local color=$(GetColor $?);
	echo "$color $(cat $2 | grep "([0-9]* passed, [0-9]* failed, [0-9]* errors).") 在 $1 \033[0m"
}
function SummaryTestWithDetails()
{
	SummaryTest $2;
	local color=$(GetColor $?);
	echo "$color $(cat $2) \033[0m"
}
function SummaryTestArray()
{
	for args in $1
	do
		echo $args
		lunit $args > tmp
		if [ $2 == -v ]; then
			SummaryTestWithDetails $args tmp;
		else
			SummaryTestWithNoDetails $args tmp;
		fi
	done
}
function Clean()
{
	rm tmp
}

function ScanDirForAll()
{
	local detail=$2
    for filename in `ls *.lua`
    do
        if [ -d $1'/'$filename ] ; then
                ScanDirForAll $1'/'$filename $detail;
        else
        	if [ $(expr "$filename" : "test") -gt 0 ]; then
        		if $detail; then
        			lunit $1/$filename > tmp
	            	SummaryTestWithDetails $filename tmp;
        		else
        			lunit $1/$filename > tmp
	            	SummaryTestWithNoDetails $filename tmp;
        		fi
        	fi
        fi
    done 
}
function ScanArray()
{
	for filename in $@
	do
		if [ -f ${filename} ]; then
			lunit ${filename} > tmp
			SummaryTestWithDetails $filename tmp;
		fi
	done
}

InitTotal;
if [ ${#1} = 0 ]; then
	ScanDirForAll . false;
elif [ $1 = all ]; then
	ScanDirForAll . true;
else
	ScanArray ${@}
fi
Clean;


if [ ${total[1]} -gt 0 ] || [ ${total[2]} -gt 0 ]; then
	echo "\033[31m"一共有${total[3]}个测试脚本, 通过${total[0]}个单元测试, 失败${total[1]}个, 错误${total[2]}个
else
	echo "\033[32m"一共有${total[3]}个测试脚本, 通过${total[0]}个单元测试, 失败${total[1]}个, 错误${total[2]}个
fi

echo "\033[0m\033[1A"



# declare -i i=10
# declare -i sum=0
# until ((i>10))
# do
#   let sum+=i
#   let ++i
# done
# echo $sum

# if [ -f hello ]; then
# 	echo hello
# fi
# for loop in 1 2 3 4 5 6
# do 
# 	echo $loop

# done




