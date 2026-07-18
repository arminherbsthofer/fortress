---
name: web-research
description: Search the web via a self-hosted SearXNG instance. Use when the
  user needs current information, documentation lookups, or research on topics
  beyond the model's training data. Returns title, URL, and snippet per result.
---

# Web Research

## Usage
    python3 scripts/search.py "your query"

Returns a JSON array of {title, url, content}. To read a page in full,
fetch the URL separately rather than expecting full text here.

For deeper searches you can vary your search query in a sensible way and collect all results and follow the links.

## Notes
- If results come back empty, the query may have hit the rate limiter — retry or rephrase.
