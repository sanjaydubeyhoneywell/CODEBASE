#!/bin/bash

# PIPE-Delimited File Normalization Script using awk split function
# This script normalizes PIPE-delimited files by:
# 1. Handling comma-delimited values within specific columns
# 2. Expanding rows where comma-delimited values exist
# 3. Removing extra whitespace around delimiters
# 4. Creating one row per comma-separated value

usage() {
    echo "Usage: $0 <input_file> [output_file] [column_number]"
    echo "  input_file:      Path to the PIPE-delimited file to normalize"
    echo "  output_file:     Path to save normalized file (default: <input>.normalized)"
    echo "  column_number:   Column number containing comma-delimited values (1-based index)"
    echo "                   (default: 3 - the Skills column)"
    echo ""
    echo "Example: $0 data.txt output.txt 3"
    echo "         (Expands column 3 which contains comma-delimited values)"
    exit 1
}

# Check if input file is provided
if [ $# -lt 1 ]; then
    usage
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.*}.normalized.${INPUT_FILE##*.}}"
COMMA_COLUMN="${3:-3}"  # Default to column 3 (Skills)

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Normalize the PIPE-delimited file using awk
awk -F'|' -v OFS='|' -v col="$COMMA_COLUMN" '{
    # Split the line into fields using pipe delimiter
    n = split($0, fields, "|")
    
    # Process the target column with comma-delimited values
    target_field = fields[col]
    
    # Remove leading and trailing whitespace from target field
    gsub(/^[ \t]+|[ \t]+$/, "", target_field)
    
    # Split the comma-delimited values
    num_values = split(target_field, comma_values, ",")
    
    # Create output for each comma-separated value
    for (i = 1; i <= num_values; i++) {
        # Trim whitespace from each value
        value = comma_values[i]
        gsub(/^[ \t]+|[ \t]+$/, "", value)
        
        # Build output line
        output_line = ""
        for (j = 1; j <= n; j++) {
            if (j > 1) output_line = output_line "|"
            
            # Replace the target column with current comma-separated value
            if (j == col) {
                output_line = output_line value
            } else {
                # Trim whitespace from all other fields too
                field_val = fields[j]
                gsub(/^[ \t]+|[ \t]+$/, "", field_val)
                output_line = output_line field_val
            }
        }
        
        print output_line
    }
}' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "✓ Normalization complete"
echo "  Input:  $INPUT_FILE"
echo "  Output: $OUTPUT_FILE"
echo "  Expanded column: $COMMA_COLUMN"
