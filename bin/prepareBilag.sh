#!/bin/bash

prepare () {
    echo Prepare is not ready
    exit 1
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

    #if [ $(find ${DIR} -maxdepth 1 -type f | wc -l) -ne 1 ]
    if [ $(find ${DIR} -maxdepth 1 -type f -name '*.pdf' | wc -l) -ne 1 ]
    then
	echo "'${DIR}' must contain exactly one expense report"
	continue
    fi

    TMPDIR=$(mktemp -d)
    echo $TMPDIR

    report=$(find ${DIR} -maxdepth 1 -type f -name '*.pdf')

    if [[ $report != *.pdf ]]
    then
	echo "'${report}' is not a pdf file"
	report=$(prepare $report)
    fi
    echo $report
    	
    for file in ${DIR}/Bilag/*
    do
	if [[ $file != *.pdf ]]
	then
	    echo "'${file}' is not a pdf file"
	    file=$(prepare $file)
	fi
	
    done

    "/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py" -o ${DIR}.pdf $report ${DIR}/Bilag/*

    rmdir $TMPDIR
done
