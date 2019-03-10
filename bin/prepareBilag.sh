#!/bin/bash

prepare () {
    tgt=${1%.*}.pdf
    docConvert.sh $1 $tgt
    echo $tgt
}

while [ -n "$1" ]
do
    DIR=${1%/}
    shift

    TARGET="${DIR}.pdf"
    if [ -e ${TARGET} ]
    then
	echo "'${TARGET}' already exists. Delete it if you want to recreate"
	exit 1
    fi

    if [ ! -d "${DIR}" ]
    then
	echo "No such directory: ${DIR}"
	continue
    fi

    if [ ! -d "${DIR}/Bilag" ]
    then
	echo "'${DIR}' does not contain Bilag"
	continue
    fi

    if [ $(find ${DIR} -maxdepth 1 -type f | wc -l) -ne 1 ]
    then
	if [ $(find ${DIR} -maxdepth 1 -type f -name '*.pdf' | wc -l) -ne 1 ]
	then
	   echo "'${DIR}' must contain exactly one expense report"
	   continue
	else
	    report=$(find ${DIR} -maxdepth 1 -type f -name '*.pdf')
	fi
    else
	report=$(find ${DIR} -maxdepth 1 -type f)
    fi

    TMPDIR=$(mktemp -d)
    echo $TMPDIR


    if [[ $report != *.pdf ]]
    then
	echo "'${report}' is not a pdf file - converting"
	report=$(prepare "${report}")
    fi
    echo $report
    	
    for file in ${DIR}/Bilag/*
    do
	if [[ $file != *.pdf ]]
	then
	    echo "'${file}' is not a pdf file - converting"
	    file=$(prepare $file)
	fi
	
    done

    "/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o ${DIR}.pdf $report ${DIR}/Bilag/*.pdf

    rmdir $TMPDIR
done
