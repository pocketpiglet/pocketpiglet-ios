#!/usr/bin/tclsh

set files_count 0
set common_name ""
set name_list   {}

foreach name [lsort -dictionary [glob -types f "*.jpeg"]] {
    if {[regexp {^([^\d]+)(\d+)} $name dummy cname number]} {
        if {[string equal $common_name ""]} {
            set common_name [string trim $cname "_"]
        }

        set number [string trimleft $number "0"]

        if {[string equal $number ""]} {
            set number 0
        }

        if {[expr $number % 1]==0} {
            lappend name_list $name

            incr files_count
        }
    }
}

append files_count "x1"

if {[catch {eval exec montage $name_list -tile $files_count -geometry 360x640+0+0 "../$common_name.jpg"} Err]} {
    puts $Err
}

puts $files_count
