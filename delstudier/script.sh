#!/bin/bash

# Input and output
DOCX_FILE="delstudier1.docx"
STYLESHEET="tufte.css"
WORKDIR="chunks"
OUTDIR="output"

# Clean previous outputs
rm -rf "$WORKDIR" "$OUTDIR"
mkdir -p "$WORKDIR" "$OUTDIR"

# Step 1: Convert DOCX to Markdown
echo "Converting $DOCX_FILE to Markdown..."
pandoc "$DOCX_FILE" -t markdown -o "$WORKDIR/full.md"

# Step 2: Split by level 2 headings (##)
echo "Splitting markdown by level 2 headings..."
awk '
  BEGIN { n = 0 }
  /^## / {
    if (f) close(f)
    n++
    f = sprintf("'"$WORKDIR"'/section%02d.md", n)
  }
  { print > f }
' "$WORKDIR/full.md"

# Step 3: Convert each chunk to standalone HTML
echo "Generating HTML output with stylesheet: $STYLESHEET"
for file in "$WORKDIR"/*.md; do
  base=$(basename "$file" .md)
  title=$(head -n 1 "$file" | sed 's/^## //')
  pandoc "$file" -o "$OUTDIR/$base.html" \
    --template=tufte-template.html \
    --standalone \
    --metadata title="$title"
done

echo "Done. HTML files are in $OUTDIR/"
