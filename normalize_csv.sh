#!/bin/bash

# PIPE-Delimited File Normalization Script using awk split function
# This script normalizes PIPE-delimited files by:
# 1. Handling comma-delimited values within specific columns
# 2. Removing extra whitespace around delimiters
# 3. Normalizing comma-separated values (removing spaces, trimming)
# 4. Ensuring consistent formatting

usage() {
    echo "Usage: $0 <input_file> [output_file] [columns_with_commas]"
    echo "  input_file:             Path to the PIPE-delimited file to normalize"
    echo "  output_file:            Path to save normalized file (default: <input>.normalized)"
    echo "  columns_with_commas:    Comma-separated column numbers containing comma-delimited values"
    echo "                          (default: auto-detect all columns)"
    echo ""
    echo "Example: $0 data.txt output.txt 3,5"
    echo "         (Normalizes columns 3 and 5 which contain comma-delimited values)"
    exit 1
}

# Check if input file is provided
if [ $# -lt 1 ]; then
    usage
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.*}.normalized.${INPUT_FILE##*.}}"
COMMA_COLUMNS="${3:-}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Normalize the PIPE-delimited file using awk
if [ -z "$COMMA_COLUMNS" ]; then
    # Auto-detect mode: normalize all columns with commas
    awk -F'|' -v OFS='|' '{
        # Split the line into fields using pipe delimiter
        n = split($0, fields, "|")
        
        # Process each field
        for (i = 1; i <= n; i++) {
            field = fields[i]
            
            # Remove leading and trailing whitespace
            gsub(/^[ \t]+|[ \t]+$/, "", field)
            
            # Check if field contains commas (comma-delimited values)
            if (field ~ /,/) {
                # Normalize comma-delimited values
                num_values = split(field, values, ",")
                normalized_field = ""
                
                for (j = 1; j <= num_values; j++) {
                    # Trim whitespace from each value
                    value = values[j]
                    gsub(/^[ \t]+|[ \t]+$/, "", value)
                    
                    # Build the normalized field
                    if (normalized_field != "") {
                        normalized_field = normalized_field ", " value
                    } else {
                        normalized_field = value
                    }
                }
                
                fields[i] = normalized_field
            } else {
                fields[i] = field
            }
        }
        
        # Reconstruct and output the normalized line
        output_line = ""
        for (i = 1; i <= n; i++) {
            if (i > 1) output_line = output_line "|"
            output_line = output_line fields[i]
        }
        
        print output_line
    }' "$INPUT_FILE" > "$OUTPUT_FILE"
else
    # Specific columns mode: normalize only specified columns with commas
    awk -F'|' -v OFS='|' -v cols="$COMMA_COLUMNS" '{
        # Parse the column numbers
        split(cols, col_array, ",")
        for (i in col_array) {
            comma_cols[col_array[i]] = 1
        }
        
        # Split the line into fields using pipe delimiter
        n = split($0, fields, "|")
        
        # Process each field
        for (i = 1; i <= n; i++) {
            field = fields[i]
            
            # Remove leading and trailing whitespace
            gsub(/^[ \t]+|[ \t]+$/, "", field)
            
            # Check if this column should have comma-delimited values normalized
            if (comma_cols[i] && field ~ /,/) {
                # Normalize comma-delimited values
                num_values = split(field, values, ",")
                normalized_field = ""
                
                for (j = 1; j <= num_values; j++) {
                    # Trim whitespace from each value
                    value = values[j]
                    gsub(/^[ \t]+|[ \t]+$/, "", value)
                    
                    # Build the normalized field
                    if (normalized_field != "") {
                        normalized_field = normalized_field ", " value
                    } else {
                        normalized_field = value
                    }
                }
                
                fields[i] = normalized_field
            } else {
                fields[i] = field
            }
        }
        
        # Reconstruct and output the normalized line
        output_line = ""
        for (i = 1; i <= n; i++) {
            if (i > 1) output_line = output_line "|"
            output_line = output_line fields[i]
        }
        
        print output_line
    }' "$INPUT_FILE" > "$OUTPUT_FILE"
fi

echo "✓ Normalization complete"
echo "  Input:  $INPUT_FILE"
echo "  Output: $OUTPUT_FILE"
