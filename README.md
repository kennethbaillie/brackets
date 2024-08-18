# Brackets

A quarto extension to pull out any lines in a .qmd file that contain text in square brackets, sort them, and report them in a new md file. Useful for assigning tasks/responsibilities to people in a shared notes file. 

## Requirements

Quarto

## Installation

Create a new, empty directory. In it, create a .qmd file. 

Open a terminal, and enter:
`quarto add baillielab/brackets`

Open your .qmd file and add the following YAML at the top of the file: 

```
---
filters: [brackets]
output-file: people
format: md
---
```

View your rendered file live by entering

`quarto preview <your-filename>`

## Codespaces

There's a working `devcontainer` in this repo so if you fork it and open your own codespace, then it will run. You can view original and rendered file live side-by-side. 