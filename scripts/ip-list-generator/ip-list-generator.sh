#!/bin/bash

source_file=$1
destination_file=$(dirname $0)/$2
echo -n "" > $destination_file

line_nums=$(cat $source_file | wc --lines)
line_nums=$(( $line_nums - 5 ))
cat $source_file | tail --lines=${line_nums} > ${source_file}.tmp
source_file=${source_file}.tmp

while read line; do
    flag="false"
    msg=$(echo $line | grep "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
    echo $msg
    if [[ -z $msg ]]; then
        flag="true"
    fi
    if $flag; then
        name=$(echo $line | cut -d";" -f4)
    else
        ip=$(echo $line | awk '{print $1}')
        echo -e $ip"\t:\t\t" $name >> ${destination_file}
        ip=""
        name=""
    fi
    line=""
done < ${source_file}

exit 0
