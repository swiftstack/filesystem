extension Path {
    public struct Component {
        let value: String

        public var isEmpty: Bool {
            value.isEmpty
        }

        public init<T: StringProtocol>(_ value: T) throws {
            guard !value.contains(Path.separator) && !value.contains(":") else {
                throw File.Error.invalidPath
            }
            self.value = .init(value)
        }
    }
}

// MARK: Parsing path string

extension Array where Element == Path.Component {
    public init<T: StringProtocol>(_ path: T) throws {
        self = try path.split(
            separator: Path.separator,
            omittingEmptySubsequences: false)
            .map(Path.Component.init)
    }
}

// MARK: Static

extension Path.Component {
    public static let empty = try! Path.Component("")
    public static let home = try! Path.Component("~")
    public static let current = try! Path.Component(".")
    public static let parent = try! Path.Component("..")
}

// MARK: Equatable

extension Path.Component: Equatable {
    public static func ==<T: StringProtocol>(lhs: Self, rhs: T) -> Bool {
        lhs.value == rhs
    }

    public static func ==<T: StringProtocol>(lhs: T, rhs: Self) -> Bool {
        rhs == lhs
    }
}

extension Array where Element == Path.Component {
    public static func ==<T: StringProtocol>(lhs: Self, rhs: Array<T>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for i in 0..<lhs.count {
            guard lhs[i] == rhs[i] else {
                return false
            }
        }
        return true
    }

    public static func ==<T: StringProtocol>(lhs: Array<T>, rhs: Self) -> Bool {
        rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension Path.Component: CustomStringConvertible {
    public var description: String { value }
}
