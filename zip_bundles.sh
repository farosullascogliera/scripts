#!/bin/bash

for dir in Book*; do
    cd "$dir"

    files=(*.mp4)

    total=${#files[@]}

    for ((i=0; i<total; i+=5)); do
        first=${files[i]%%.*}
        last=${files[i+4]%%.*}

        if ((i+5 > total)); then
            last=${files[total-1]%%.*}
        fi

        zip "${first}-${last}.zip" "${files[@]:i:5}"
    done

    cd ..
done
