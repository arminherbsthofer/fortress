#!/usr/bin/env python3
"""Query the SearXNG instance and print clean JSON results."""
import os, json, argparse, requests

def search(query, num_results=10):
    
    auth = (os.environ.get("SEARXNG_USERNAME"), os.environ.get("SEARXNG_PASSWORD"))

    resp = requests.post(
        os.environ.get("SEARXNG_HOST"),
        auth=auth,
        data={"q": query, "format": "json"},
        timeout=30,
    )

    resp.raise_for_status()
    results = resp.json().get("results", [])[:num_results]

    return [
        {"title": r.get("title"), "url": r.get("url"), "content": r.get("content")}
        for r in results
    ]

if __name__ == "__main__":

    p = argparse.ArgumentParser()
    p.add_argument("query")
    p.add_argument("-n", "--num", type=int, default=10)
    args = p.parse_args()
    print(json.dumps(search(args.query, args.num), indent=2))
