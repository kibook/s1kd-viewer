#!/bin/sh

cgi=$(cgi-init)

icn=$(cgi-param "$cgi" icn)

tmp=$(mktemp -d)

object=$(sh get-object.sh "$icn" "$tmp")
object_status=$?

mime=$(file -b --mime-type "$object")

cgi-header "Content-type: $mime"

if test "$object_status" -eq 0
then
	cat "$object"
fi

sh free-object.sh "$object"

rm -r "$tmp"

cgi-free "$cgi"
