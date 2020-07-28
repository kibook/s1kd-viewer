#!/bin/sh

pm_object=$1
tmp=$2

s1kd-refs -d csdb -D "$pm_object" -c | head -n 1
