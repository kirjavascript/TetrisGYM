#! /usr/bin/awk -f

# Run against tetris.dbg to see modes and values

BEGIN { FS="," }

/MODE_/ && /scope=0/ { 
    gsub("name=", "", $2 ); 
    gsub("\"", "", $2 ); 
    for (i=3;i<=NF;i++) {
        if ($i ~ /^val=/) {
            gsub("val=", "", $i ); 
            print sprintf("%02d",strtonum($i)), $2
            }
        }
    };
 