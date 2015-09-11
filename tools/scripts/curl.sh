#! /bin/bash
url="http://192.168.0.30:3000/errors/create"
# url="gm.batcatstudio.com/errors/create"
str=`curl $url -c $(pwd)/tmp`
csrf=`echo $str | sed 's/\(.*\)"\(.*\)"\(.*\)/\2/g'`
curl -d "_csrf=$csrf" -d "deviceId=1234" -d "stack=helloworld" $url -b $(pwd)/tmp
rm $(pwd)/tmp

