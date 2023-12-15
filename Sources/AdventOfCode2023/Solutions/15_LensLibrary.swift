import AOCKit

struct LensLibrary: Puzzle {
    static let day = 15

    // static let rawInput: String? = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

    func part1(input: Input) throws -> Int {
        input.csvWords.raw.sum(of: hash)
    }

    func part2(input: Input) throws -> Int {
        let sequence = parseInitializationSequence(from: input)
        var boxes: [Int: Box] = [:]

        for (label, instruction) in sequence {
            let boxId = hash(label)
            var box = boxes[boxId] ?? Box()

            if case let .insert(focalLength) = instruction {
                box.insertOrReplace(label, focalLength)
            } else {
                box.remove(label)
            }

            boxes[boxId] = box
        }

        return boxes.sum(of: { boxNumber, box in
            box.focusingPower(with: boxNumber)
        })
    }

    private func parseInitializationSequence(from input: Input)
        -> [(label: String, instruction: Instruction)]
    {
        input.csvWords.map { word in
            let label = String(word.raw.prefix(while: \.isLetter))
            if word.raw.hasSuffix("-") {
                return (label, .remove)
            } else {
                guard let focalLength = Int(word.raw.suffix(while: \.isWholeNumber)) else {
                    fatalError()
                }
                return (label, .insert(focalLength))
            }
        }
    }

    private func hash(_ str: String) -> Int {
        str.reduce(0) { hash, ch in
            (hash + Int(ch.asciiValue!)) * 17 % 256
        }
    }
}

private struct Box {
    private var slots: [(label: String, focalLength: Int)] = []

    func focusingPower(with id: Int) -> Int {
        slots.enumerated().sum(of: { index, lens in
            let (_, focalLength) = lens
            return (1 + id) * (1 + index) * focalLength
        })
    }

    mutating func remove(_ label: String) {
        guard let index = index(of: label) else {
            return
        }

        slots.remove(at: index)
    }

    mutating func insertOrReplace(_ label: String, _ focalLength: Int) {
        if let index = index(of: label) {
            slots[index] = (label, focalLength)
        } else {
            slots.append((label, focalLength))
        }
    }

    private func index(of label: String) -> Int? {
        slots.firstIndex(where: { $0.label == label })
    }
}

private enum Instruction {
    case insert(Int)
    case remove
}
