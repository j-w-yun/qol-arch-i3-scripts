#!/bin/bash

backlight=$(xbacklight)
if (( $(echo "$backlight <= 1" | bc -l) ))
then
	xbacklight -set 100
else
	xbacklight -set 1
fi
