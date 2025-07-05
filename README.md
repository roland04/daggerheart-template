# Daggerheart Campaign PDF Generator

This project provides a modern workflow to create beautiful, two-column PDF documents for tabletop RPG campaigns (like Daggerheart) using Markdown. It uses a custom LaTeX template, Pandoc Lua filters, and an organized folder structure to make the process easy—even for users with no LaTeX experience.

## Features
- Write your campaign in Markdown: Easy, readable, and portable.
- Automatic conversion to PDF: Produces a professionally styled, two-column PDF.
- Custom adversary blocks: Add adversaries using simple Markdown/YAML blocks.
- Image support: Effortlessly include images—single column, double column, or full page.
- Cross-platform scripts: Run on Windows, Linux, or Mac with a single command.

## Folder Structure

```
├── fonts/                           # Custom fonts for use in documents
│   ├── Montserrat-Regular.ttf
│   ├── Montserrat-Light.ttf
│   └── ...                          # Other custom fonts
├── tex/                             # LaTeX templates and auxiliary files
│   ├── adversary.tex                # Definition of the adversary box/command
│   ├── template.tex                 # Common configuration (packages, styles, etc.)
│   └── ...                          # Additional LaTeX files
├── filters/                         # Lua filters for Pandoc
│   ├── filters.lua                  # Main or utility filter
│   ├── adversaries.lua              # Filter for adversary box generation
│   └── h4.lua                       # Filter for custom heading styles
├── output/                          # Generated files (PDFs, etc.)
│   └── main.pdf
├── images/                          # Image files for use in documents
│   └── ...                          # All project images
├── main.md                          # Main Markdown document (content)
├── example.md                       # Example Markdown document
├── generatepdf.bat                  # Windows script to generate PDF
└── generatepdf.sh                   # Linux/macOS script to generate PDF
```

## Setup

1. Install [Pandoc](https://pandoc.org/installing.html) (Make sure Pandoc is available in your system’s PATH.)
2. Install LaTeX
    - **Linux**: Install TeX Live or another LaTeX distribution.
      ```
      sudo apt install texlive-xetex
      ```
    - **Mac**: Install MacTeX from [tug.org](https://www.tug.org/mactex/).
    - **Windows**: Install MiKTeX from [miktex.org](https://miktex.org/download).
3. Install pandoc-latex-environment filter
   1. Install [pipx](https://pipx.pypa.io/en/stable/installation/) if you haven't already.
   2. Run the following command to install the filter:
   ```
   pipx install pandoc-latex-environment
   ```
4. Clone this repository or download the files to your local machine.

## Writing Your Campaign

Write your content in main.md using standard Markdown.

Use the following YAML at the top of main.md to set the title, subtitle, and author:
  - Set `toc: true` to enable a table of contents.
  - Do not remove the mandatory fields for the LaTeX environment.

```yaml
---
title: Title of the Campaign
subtitle: Subtitle of the Campaign
author: Name of the Author
toc: false
# Mandatory fields. Please do not remove.
pandoc-latex-environment:
  squarebox: [squarebox]
  roundedbox: [roundedbox]
---
```

## Adding Images

- Place your images in the `images/` directory.
- To add images, use the following syntax:
```markdown
![](images/filename.ext)
```

## Adding Full-Page elements

- Be cautious with full-page elements, as they will break the two-column layout and start a new page.
- To add a full-page element, use the `fullpagestart` and `fullpageend` commands:
```markdown
\fullpagestart

This is a full-page element. It will take up the entire page, breaking the two-column layout.

| Header 1 | Header 2 | Header 3 | Header 4 | Header 5 | Header 6 | Header 7 | Header 8 | Header 9 |
|----------|----------|----------|----------|----------|----------|----------|----------|----------|
| Item 1   | Item 2   | Item 3   | Item 4   | Item 5   | Item 6   | Item 7   | Item 8   | Item 9   |
| Item 4   | Item 5   | Item 6   | Item 7   | Item 8   | Item 9   | Item 10  | Item 11  | Item 12  |
| Item 7   | Item 8   | Item 9   | Item 10  | Item 11  | Item 12  | Item 13  | Item 14  | Item 15  |

\fullpageend
```

## Custom Blocks

- Use the `squarebox` class to create visually distinct boxes in your text:

```markdown
::: squarebox
**This is a box title**
This is a quote from a character in the campaign. *It should be visually distinct from the rest of the text*, perhaps with a different font or style.
:::
```

- For rounded boxes, use the `roundedbox` class:

```markdown
::: roundedbox
**This is a rounded box title**
This is a quote from a character in the campaign. *It should be visually distinct from the rest of the text*, perhaps with a different font or style.
:::
```

- For quotes, you can use the `>` syntax to create a blockquote:

```markdown
> ***Note***: This is a quote from a character in the campaign. *It should be visually distinct from the rest of the text, perhaps with a different font or style*.
```

## Adversaries

- For adversaries, use the `adversary` class:
  - The `name`, `type`, `description`, `tactics`, `difficulty`, `thresholds`, `hp`, `atk` and `weapons` fields are mandatory.
  - `experience` and `features` fields are optional.

```markdown
::: adversary
name: Vampire, The Bloodthirsty
type: Tier 2 Solo
description: A fearsome vampire that preys on the weak.
tactics: Attack from shadows, drain blood
difficulty: 15
thresholds: 16 / 30
hp: 8
atk: +4
weapons:
  - Fangs: Close | 2d8+2 (Magical)
experience: Bloodthirsty Knowledge +3
features:
  - Blood Drain - Action: Make an attack against a target within Close range. On a success, deal 2 and the target must mark an Armor Slot without gaining its benefit (they can still use armor to reduce the damage)
  - Shadow Step - Action: Move to a location within Close range, ignoring terrain.
:::
```

## Generating the PDF

### Option 1: Run the script (recommended)
- Windows: Double-click generatepdf.bat or run it from the command prompt.
- Linux/Mac: Open a terminal, navigate to the project folder, and run:
    ```bash
    ./generatepdf.sh
    ```
The script will:
- Check if Pandoc is installed.
- Convert input/document.md to output/document.pdf using your template and filters.

### Option 2: Run Pandoc manually
From the project root, run:

1. Run the following command to build the .html file
```
pandoc main.md --no-highlight --template=tex/template.tex --pdf-engine=xelatex --filter pandoc-latex-environment --lua-filter=filters/filters.lua -o output/main.pdf
```

## Helpful Tips
- Images: Place all images in input/images/ and reference them as images/filename.ext in your Markdown.
- Adversaries and custom blocks: Use the provided YAML/Markdown syntax for easy entry and automatic styling.
- Troubleshooting: If you get errors, ensure Pandoc and LaTeX are correctly installed and that your image paths are correct.
- Sometimes special characters in tables (like `#`, `&`, etc.) can cause issues. If you encounter problems, try escaping them with double backslash (`\\#`).
- Use the example.md file as a reference for formatting and structure.

## What Does This Project Actually Do?
Transforms your Markdown campaign into a styled, printable PDF with two columns, custom adversary boxes, and flexible image placement.
Automates complex LaTeX formatting so you can focus on writing, not typesetting.
Keeps your project organized for easy editing, versioning, and sharing.

## License

This project is licensed under the **GNU General Public License, version 3** (or any later version).

For more details, see the [full license text](https://www.gnu.org/licenses/gpl-3.0.html).

### This template uses:
- Montserrat font (Google Fonts, SIL Open Font License)
- Merriweather font (Google Fonts, SIL Open Font License)
- Eveleth Clean Regular (commercial font, not included—users must provide their own licensed copy).
  - Add `Eveleth-Regular.ttf` to the `fonts/` directory.
  - If not available, the template will use LeagueSpartan font (Google Fonts, SIL Open Font License) as a fallback.