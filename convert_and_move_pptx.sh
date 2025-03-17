#!/bin/bash

# Create the PPTX directory if it doesn't exist
mkdir -p PPTX

# Find all .pptx files and process them
find . -type f -name '*.pptx' -print0 | while IFS= read -r -d '' file; do
  echo "Converting '$file' to PDF..."
  # Convert to PDF and output to the same directory as the original file
  libreoffice --headless --convert-to pdf "$file" --outdir "$(dirname "$file")"

  # Move the original .pptx file to the PPTX directory
  mv "$file" PPTX/
done

echo "Conversion complete. All .pptx files have been moved to the 'PPTX' folder."
