# jcat

A simple cat command clone written in Jai.

## Description

jcat is a lightweight implementation of the Unix `cat` command, built as a learning project in the Jai programming language. It covers alot of the basics of cat, but not all the edge cases. It should run on both mac/linux.

## Features

- Display file contents to stdout
- Concatenate multiple files
- Basic error handling

## Usage

```bash
jcat [file1] [file2] ...
```

## Examples

```bash
# Display a single file
jcat example.txt

# Concatenate multiple files
jcat file1.txt file2.txt

# Display from stdin (if no arguments)
jcat
```

## Building

```bash
jai-macos main.jai
```

or

```bash
jai-linux main.jai
```

or use make if you have make installed you can use it. Assumes you have jai-macos or jai-linux in your path

```bash
make build
```

## License

MIT