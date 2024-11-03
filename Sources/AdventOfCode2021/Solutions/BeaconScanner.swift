import AOCKit

struct BeaconScanner: Puzzle {
    static let day = 19

    func part1(input: Input) throws -> Int {
        let scanners = parse(input)
        let transforms = getTransforms(toAlign: scanners)
        return countUniqueBeacons(in: scanners, using: transforms)
    }

    func part2(input: Input) throws -> Int {
        let scanners = parse(input)
        let transforms = getTransforms(toAlign: scanners)
        return findMaxDistance(between: scanners, using: transforms)
    }
}

private typealias Position = Point3D

private extension Position {
    static let origin: Self = .zero
}

private typealias Scanner = [Position]
private typealias Rotation = @Sendable (Position) -> Position
private typealias Transform = (rotate: Rotation, offset: Position)
private typealias Transforms = [[Int: [Transform]]]

private let rots: [Rotation] = [
    { p in Position(p.x, p.y, p.z) },
    { p in Position(p.y, p.z, p.x) },
    { p in Position(p.z, p.x, p.y) },
    { p in Position(-p.x, p.z, p.y) },
    { p in Position(p.z, p.y, -p.x) },
    { p in Position(p.y, -p.x, p.z) },
    { p in Position(p.x, p.z, -p.y) },
    { p in Position(p.z, -p.y, p.x) },
    { p in Position(-p.y, p.x, p.z) },
    { p in Position(p.x, -p.z, p.y) },
    { p in Position(-p.z, p.y, p.x) },
    { p in Position(p.y, p.x, -p.z) },
    { p in Position(-p.x, -p.y, p.z) },
    { p in Position(-p.y, p.z, -p.x) },
    { p in Position(p.z, -p.x, -p.y) },
    { p in Position(-p.x, p.y, -p.z) },
    { p in Position(p.y, -p.z, -p.x) },
    { p in Position(-p.z, -p.x, p.y) },
    { p in Position(p.x, -p.y, -p.z) },
    { p in Position(-p.y, -p.z, p.x) },
    { p in Position(-p.z, p.x, -p.y) },
    { p in Position(-p.x, -p.z, -p.y) },
    { p in Position(-p.z, -p.y, -p.x) },
    { p in Position(-p.y, -p.x, -p.z) },
]

private func transform(_ position: Position, using transform: Transform) -> Position {
    transform.rotate(position) + transform.offset
}

private func transform(_ scanner: Scanner, using t: Transform) -> Scanner {
    scanner.map { beacon in transform(beacon, using: t) }
}

private func parse(_ input: Input) -> [Scanner] {
    input.raw.components(separatedBy: "\n\n").map { scanner in
        scanner.components(separatedBy: "\n")[1...].map { line in
            let parts = Line(line).csvWords.integers
            return Position(parts[0], parts[1], parts[2])
        }
    }
}

private func getTransforms(toAlign scanners: [Scanner]) -> Transforms {
    // figure out all overlapping detection cubes
    var transforms: Transforms = Array(repeating: [:], count: scanners.count)
    transforms[0] = [
        0: [(rots[0], .origin)],
    ]

    for i in scanners[1...].indices {
        let scanner1 = scanners[i]

        scanner2Loop: for j in scanners.indices where i != j {
            let scanner2 = scanners[j]
            for rot in rots {
                var offsetCounts: [Position: Int] = [:]
                for var beacon1 in scanner1 {
                    beacon1 = rot(beacon1)
                    for beacon2 in scanner2 {
                        let offset = beacon2 - beacon1
                        offsetCounts[offset, default: 0] += 1
                        if offsetCounts[offset] == 12 {
                            transforms[i][j] = [(rot, offset)]
                            continue scanner2Loop
                        }
                    }
                }
            }
        }
    }

    // make sure all scanners can be transformed relative to scanner 0
    while transforms.contains(where: { $0[0] == nil }) {
        for i in transforms[1...].indices where transforms[i][0] == nil {
            for (j, t1) in transforms[i] {
                guard let t2 = transforms[j][0] else { continue }
                transforms[i][0] = t1 + t2
                break
            }
        }
    }

    return transforms
}

private func countUniqueBeacons(
    in scanners: [Scanner],
    using transforms: [[Int: [Transform]]]
) -> Int {
    var beacons = Set(scanners[0])
    for i in scanners[1...].indices {
        var scanner = scanners[i]
        for t in transforms[i][0] ?? [] {
            scanner = transform(scanner, using: t)
        }
        for beacon in scanner {
            beacons.insert(beacon)
        }
    }
    return beacons.count
}

private func findMaxDistance(
    between scanners: [Scanner],
    using transforms: [[Int: [Transform]]]
) -> Int {
    var scannerCoords: [Position] = [.origin]
    for i in scanners[1...].indices {
        var p: Position = .origin
        for t in transforms[i][0] ?? [] {
            p = transform(p, using: t)
        }
        scannerCoords.append(p)
    }

    var maxDist = 0
    for i in 0 ..< scannerCoords.count - 1 {
        let p1 = scannerCoords[i]
        for j in 1 ..< scannerCoords.count {
            let p2 = scannerCoords[j]
            maxDist = max(maxDist, p1.manhattanDistance(to: p2))
        }
    }
    return maxDist
}

private let testInput = """
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14
"""
