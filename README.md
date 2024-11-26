# SwiftAdventOfCode

This is a repository for my solutions to the [Advent of Code](https://adventofcode.com) puzzles, written in Swift.

## Downloading input data

## Automation

This repo follows the automation guidelines on the [/r/adventofcode community wiki](https://www.reddit.com/r/adventofcode/wiki/faqs/automation). Specifically:

- Inputs are only downloaded after a [manual confirmation](Sources/AOCKit/CLI/RunCommand.swift#L251)
- Once inputs are downloaded, they are [cached locally](Sources/AOCKit/CLI/RunCommand.swift#L280)
- The User-Agent header in [`downloadInput(for:)`](Sources/AOCKit/CLI/RunCommand.swift#L250) is set to me since I maintain this repo
