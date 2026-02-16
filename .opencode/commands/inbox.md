---
name: inbox
description: Archive all files under inbox/ into wiki/
agent: jarvis
---

## Wiki Schema

!`cat wiki/_schema.md`

## Workflow

- Read user request below. If now presented, scan every files in `inbox/`:
  - If there is a `inbox/instruction.md` exist, read and follow the instructions to archive files.
  - For text files and images (remember you are a multimodal assistant): read all content.
    - Some files may contain URLs, webfetch them and read the content as well.
  - For docx, xlsx, etc. : try using `pandoc -t markdown` to extract text content.
  - For online videos: try using `yt-dlp` if available, otherwise archive the URL and metadata.
  - For unsupported formats: archive them to `wiki/assets/`, ensure at least one Markdown link is pointing to the file.
- Create one or more Markdown notes in `wiki/` (no subdirectories).
- Use lightweight frontmatter for retrieval.
- Avoid duplicates: if already archived, update the existing note.
- After processing, git commit the changes with a message like "Archive inbox files: <list of filenames>".

## Guidelines

- After all files are properly archived, ask user for confirmation then delete the originals in `inbox/`.
- If content cannot be extracted, still archive the file to `wiki/assets/` and record basic metadata + how to review.

Minimum frontmatter (recommended)

```yaml
---
title: "<title>"
created: "<timestamp>"
tags: []
# ... some other metadata fields as needed
---
```

## Response

- Brief confirmation plus created/updated note paths and any `wiki/assets/*` files.

---

## User Request

$ARGUMENTS
