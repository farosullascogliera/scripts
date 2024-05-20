#!/bin/bash

######## ONLY WORKS WITH AMD #########

# This script simply turns all video files into hevc format,
# with a set of options, using amf



in_folder=""
out_folder=""

# Since memory is a thing, I cut the video into segmets of 10 minutes and process
# just that, as around 13 minutes ffmpeg simply stops working.
# The videos are just glued together after.
segment_duration=600

rm -rf "$out_folder/segments"

for in_file in "$in_folder"/*.mp4; do
    out_file="$out_folder/$(basename "$in_file")"
    filename_no_ext=$(basename "${in_file%.*}")
    out_segs_folder="$out_folder/segments/$filename_no_ext"

    mkdir -p "$out_segs_folder"

    ffmpeg -i "$in_file" -c copy -f segment -segment_time "$segment_duration" -reset_timestamps 1 "$out_segs_folder/$filename_no_ext-%03d.mp4"

    concat_list_file="$out_segs_folder/concat_list.txt"

    for segment_file in "$out_segs_folder"/*.mp4; do
        out_hevc_segment="${segment_file%.*}_hevc_amf.mp4"
        ffmpeg -i "$segment_file" -c:v hevc_amf -rc cqp -quality quality "$out_hevc_segment"
        echo "file '$(basename "$out_hevc_segment")'" >> "$concat_list_file"
    done

    ffmpeg -y -f concat -safe 0 -i "$concat_list_file" -c copy "$out_folder/$filename_no_ext.mp4"

    rm -rf "$out_folder/segments"
done
