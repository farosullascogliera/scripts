#!/bin/bash

DIR="./"
OUTPUT_FILE="file_name_list.txt"
FORMAT="mp4"

cd "$DIR"

for file in *.$FORMAT; do

    season=$(echo $file | cut -d'.' -f4 | cut -c3)
    episode=$(echo $file | cut -d'.' -f4 | cut -c5-6)

    # Extract the title from the file name
        # 1. `echo $file`: Outputs the file name
        # 2. `cut -d' ' -f6-`: Splits the file name by spaces and takes the sixth field to the end
        # 3. `rev`: Reverses the string to prepare for cutting from the end
        # 4. `cut -d' ' -f6-`: Splits the reversed string by spaces and takes everything from the sixth field to the end
        # 5. `rev`: Reverses the string back to its original order
        # 6. `tr '.' ' '`: Replaces all dots with spaces
    title=$(echo $file | cut -d'.' -f6- | rev | cut -d'.' -f6- | rev | tr '.' ' ')

    #newname="${season}${episode} - ${title}.$FORMAT"
    newname="${season}${episode}.$FORMAT"

    # Create list of old names and new
    echo 'Old name: "'$(basename "$file")'"' >> "$OUTPUT_FILE"
    echo 'New name: "'$newname'"' >> "$OUTPUT_FILE"
    echo -e "\n" >> "$OUTPUT_FILE"

    mv -- "$file" "$newname"
done

echo -e "\n\n" >> "$OUTPUT_FILE"

echo "Renaming done. Check the text file for log"

