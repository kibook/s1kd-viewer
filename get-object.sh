#!/bin/sh

document=$1
tmp=$2

find_object() {
	s1kd-ls csdb | s1kd-metadata -n path -w code -v "$1" -l
}

path=$(find_object "$document")

if test -z "$path"
then
	exit 1
fi

echo "$path"
