extension Directory {
    public struct Name {
        let value: Path.Component

        public init(_ value: Path.Component) throws {
            self.value = value
        }
    }
}

// MARK: Convenience

extension Directory.Name {
    public init<T: StringProtocol>(_ value: T) throws {
        self.value = try Path.Component(value)
    }
}

// MARK: Equatable

extension Directory.Name: Equatable {
     public static func == <T: StringProtocol>(lhs: Self, rhs: T) -> Bool {
        return lhs.value.value == rhs
    }

    public static func == <T: StringProtocol>(lhs: T, rhs: Self) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension Directory.Name: CustomStringConvertible {
    public var description: String { value.description }
}
