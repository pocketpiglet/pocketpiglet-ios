#!/usr/bin/tclsh

set    tile [llength [glob "*.jpeg" -type f]]
append tile "x1"

exec montage *.jpeg -tile $tile -geometry 360x640+0+0 ../piglet_in_sorrow.jpg
