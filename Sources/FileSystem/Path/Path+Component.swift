extension Path {
    public struct Component {
        let value: String

        public var isEmpty: Bool {
            value.isEmpty
        }

        public var isValid: Bool {
            !value.contains(Path.separator) && !value.contains(":")
        }

        public init<T: StringProtocol>(_ value: T) {
            self.value = .init(value)
        }
    }
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

// MARK: CustomStringConvertible

extension Path.Component: CustomStringConvertible {
    public var description: String { value }
}


// MARK: Parsing path string

extension Array where Element == Path.Component {
    public init<T: StringProtocol>(_ path: T) {
        self = path.split(
            separator: Path.separator,
            omittingEmptySubsequences: false)
            .map(Path.Component.init)
    }
}
