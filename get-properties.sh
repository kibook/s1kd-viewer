#!/bin/sh

object=$1
tmp=$2

s1kd-instance -d csdb -H applic "$object"
