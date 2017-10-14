#!/bin/sh

find .. -name '*.png' -exec mogrify -verbose {} \;
