import AOCKit
import Foundation

fileprivate typealias Passport = [String : String]
fileprivate typealias FieldSet = Set<String>
fileprivate typealias Validator = (Passport) -> Bool
fileprivate typealias ValidatorBuilder = (String) -> (Passport) -> Bool

struct PassportProcessing: Puzzle {
    func part1Solution(for input: String) throws -> Int {
        let passports = try parsePassports(from: input)
        let validator = PassportValidator()
        return validate(passports, using: validator.containsRequiredKeys)
    }

    func part2Solution(for input: String) throws -> Int {
        let passports = try parsePassports(from: input)
        let validator = PassportValidator()
        return validate(passports, using: validator.allFieldsValid)
    }

    private func validate(_ passports: [Passport], using isValid: (Passport) -> Bool) -> Int {
        passports.filter(isValid).count
    }

    private func parsePassports(from input: String) throws -> [Passport] {
        let lines = getLines(from: input, omittingEmptyLines: false)

        var passports: [Passport] = []
        var current = Passport()
        for line in lines {
            if line.isEmpty {
                passports.append(current)
                current = Passport()
                continue
            }

            let pairs = split(line, on: " ")
            for pair in pairs {
                let (key, value) = try parseField(from: pair)
                current[key] = value
            }
        }
        passports.append(current)

        return passports
    }

    private func parseField(from string: String) throws -> (key: String, value: String) {
        let pair = split(string, on: ":")
        guard pair.count == 2 else {
            throw PassportProcessingError.invalidSegment(string)
        }
        return (key: pair[0], value: pair[1])
    }
}

fileprivate extension String {
    static let birthYear = "byr"
    static let issueYear = "iyr"
    static let expirationYear = "eyr"
    static let height = "hgt"
    static let hairColor = "hcl"
    static let eyeColor = "ecl"
    static let passportId = "pid"
    static let countryId = "cid"
}

fileprivate struct PassportValidator {
    func containsRequiredKeys(_ passport: Passport) -> Bool {
        FieldSet(passport.keys).isSuperset(of: FieldSet(Self.validators.keys))
    }

    func allFieldsValid(_ passport: Passport) -> Bool {
        containsRequiredKeys(passport) && Self.validators.values.allSatisfy { $0(passport) }
    }

    private static let validators = makeValidators(
        // byr (Birth Year) - four digits; at least 1920 and at most 2002.
        field(.birthYear, validate: and(hasLength(of: 4), isBetween(1920, and: 2002))),

        // iyr (Issue Year) - four digits; at least 2010 and at most 2020.
        field(.issueYear, validate: and(hasLength(of: 4), isBetween(2010, and: 2020))),

        // eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
        field(.expirationYear, validate: and(hasLength(of: 4), isBetween(2020, and: 2030))),

        // hgt (Height) - a number followed by either cm or in:
        //     If cm, the number must be at least 150 and at most 193.
        //     If in, the number must be at least 59 and at most 76.
        field(
            .height,
            validate: and(
                matches(pattern: "^\\d{2,3}(cm|in)$"),
                or(hasUnits("cm", between: 150, and: 193), hasUnits("in", between: 59, and: 76))
            )
        ),

        // hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
        field(.hairColor, validate: matches(pattern: "^#[0-9a-f]{6}$")),

        // ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
        field(.eyeColor, validate: oneOf("amb", "blu", "brn", "gry", "grn", "hzl", "oth")),

        // pid (Passport ID) - a nine-digit number, including leading zeroes.
        field(.passportId, validate: matches(pattern: "^\\d{9}$"))
    )

    private static let todo: ValidatorBuilder = {_ in { _ in fatalError() } }

    private static func makeValidators(_ pairs: (String, Validator)...) -> [String : Validator] {
        pairs.reduce(into: Dictionary<String, Validator>()) { $0[$1.0] = $1.1 }
    }

    private static func field(_ name: String, validate builder: ValidatorBuilder) -> (key: String, value: Validator) {
        (key: name, value: builder(name))
    }

    private static func and(_ validators: ValidatorBuilder...) -> ValidatorBuilder {
        { fieldName in
            { passport in
                validators.map { $0(fieldName) }.allSatisfy { $0(passport) }
            }
        }
    }

    private static func or(_ validators: ValidatorBuilder...) -> ValidatorBuilder {
        { fieldName in
            { passport in
                validators.map { $0(fieldName) }.contains { $0(passport) }
            }
        }
    }

    private static func hasLength(of length: Int) -> ValidatorBuilder {
        { fieldName in
            { passport in passport[fieldName]!.count == length }
        }
    }

    private static func isBetween(_ min: Int, and max: Int) -> ValidatorBuilder {
        { fieldName in
            { passport in Int(passport[fieldName]!)!.isBetween(min, and: max) }
        }
    }

    private static func matches(pattern: String) -> ValidatorBuilder {
        { fieldName in
            { passport in NSRegularExpression(pattern).matches(passport[fieldName]!) }
        }
    }

    private static func oneOf(_ values: String...) -> ValidatorBuilder {
        { fieldName in
            { passport in values.contains(passport[fieldName]!) }
        }
    }

    private static func hasUnits(_ units: String, between min: Int, and max: Int) -> ValidatorBuilder {
        let regex = NSRegularExpression("(\\d+)\(units)")
        return { fieldName in
            { passport in
                guard let match = regex.match(passport[fieldName]!) else { return false }
                return Int(match[1])!.isBetween(min, and: max)
            }
        }
    }
}

enum PassportProcessingError: Error {
    case invalidSegment(_ segment: String)
}

extension PassportProcessingError: CustomStringConvertible {
    public var description: String {
        switch self {
            case .invalidSegment(let segment):
                return "Unable to process segment: \(segment)"
        }
    }
}
