#!/bin/sh

cgi=$(cgi-init)

icn=$(cgi-param "$cgi" icn)

object=$(s1kd-ls -G csdb/"$icn"*)

cgi-header -n 'Status: 302 Found'
cgi-header "Location: $object"

cgi-free "$cgi"
