---
name: pdf-reader
description: Read, extract text from, and analyze PDF files. Use when the user mentions pdf, read a pdf, extract text from pdf, or drops a .pdf file into the chat. Trigger whenever you see .pdf filenames
 in the current directory or any context where someone is working with a document.
---

# PDF Reader Skill

## Quick start

When the user wants to read or work with a PDF:

1. Locate the PDF file in the workspace or current directory. If not found, ask for the path.

2. Extract text using `pdftotext` (must be installed):

```bash
pdftotext -layout input.pdf - | head -500
```

The `-layout` flag preserves the original spatial layout of the text in the PDF.

3. For full document extraction, omit `head` or use a larger limit:

```bash
pdftotext -layout input.pdf -
```

4. For multi-page PDFs with complex layout (tables, columns), extract each page separately for better fidelity:

```bash
PDFFILE="document.pdf"
pages=$(pdffonts "$PDFFILE" | tail -n +3 | wc -l || true)
# Get page count from poppler-utils if available
pdfinfo "$PDFFILE" 2>/dev/null | grep "Pages:" | awk '{print $2}'
```

5. For page-by-page extraction:

```bash
pdftotext -layout -f 1 -l 1 input.pdf -   # page 1
pdftotext -layout -f 2 -l 2 input.pdf -   # page 2
# continue as needed...
```

## When the content is large

- Always show the first portion (e.g., `head -300` or `$LIMIT`) and ask if the user wants more.
- For scanning/searching within a PDF, use:

```bash
pdftotext -layout input.pdf - | grep -n "search term"
```

## Fallbacks

- If a PDF is scanned / image-based, `pdftotext` will return only whitespace. In that case, convert pages to images and use the LLM's multimodal capabilities to analyze them:

```bash
# Convert all pages to PNG images at 300 DPI
pdftoppm -png -r 300 input.pdf page

# This produces page-1.png, page-2.png, etc. in the current directory.

# For a single page:
pdftoppm -png -f 1 -l 1 -r 300 input.pdf page
# produces page-1.png
```

Then show each image (e.g., `page-1.png`) directly to the user or feed it into the LLM to have it describe/extract the content.

- If `pdftotext` is also unavailable, check if `pdftoppm` exists as a fallback:

```bash
which pdftoppm && echo "pdftoppm available — can still convert scanned PDFs to images" || echo "No poppler-utils tools available"
```

## Useful commands summary

| Command | Use case |
|---------|----------|
| `pdftotext -layout file.pdf -` | Extract all text with layout preserved |
| `pdftotext file.pdf output.txt` | Write to a text file for editing |
| `pdfinfo file.pdf` | Get metadata (pages, author, title, etc.) |
| `pdffonts file.pdf` | List fonts used in the PDF |

