#!/bin/bash

# CSV Normalization Script using awk split function
# This script normalizes CSV files by:
# 1. Removing extra whitespace around delimiters
# 2. Ensuring consistent formatting
# 3. Handling quoted fields properly

usage() {
    echo "Usage: $0 <input_file> [output_file]"
    echo "  input_file:  Path to the CSV file to normalize"
    echo "  output_file: Path to save normalized CSV (default: <input>.normalized)"
    exit 1
}

# Check if input file is provided
if [ $# -lt 1 ]; then
    usage
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.csv}.normalized.csv}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Normalize the CSV file using awk
awk -F',' '{
    # Split the line into fields using comma delimiter
    n = split($0, fields, ",")
    
    # Process each field
    for (i = 1; i <= n; i++) {
        # Remove leading and trailing whitespace
        field = fields[i]
        gsub(/^[ \t]+|[ \t]+$/, "", field)
        
        # Remove quotes if the field is quoted
        if (field ~ /^".*"$/) {
            field = substr(field, 2, length(field) - 2)
        }
        
        # Store normalized field (with quotes if contains comma, newline, or quote)
        if (field ~ /[,"\n]/) {
            fields[i] = "\"" field "\""
        } else {
            fields[i] = field
        }
    }
    
    # Reconstruct and output the normalized line
    output_line = ""
    for (i = 1; i <= n; i++) {
        if (i > 1) output_line = output_line ","
        output_line = output_line fields[i]
    }
    
    print output_line
}' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✓ Normalization complete"
echo "  Input:  $INPUT_FILE"
echo "  Output: $OUTPUT_FILE"
