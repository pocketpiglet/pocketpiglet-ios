#!/usr/bin/tclsh

set    tile [llength [glob -types f "*.jpeg"]]
append tile "x1"

exec montage *.jpeg -tile $tile -geometry 360x640+0+0 ../piglet_eats_candy.jpg
