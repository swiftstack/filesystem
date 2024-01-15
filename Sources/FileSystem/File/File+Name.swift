extension File {
    public struct Name {
        let value: Path.Component

        public var `extension`: String? {
            let value = self.value.value
            guard let index = value.lastIndex(of: ".") else { return nil }
            return String(value[index...])
        }

        public init(_ value: Path.Component) throws {
            guard !value.isEmpty else {
                throw Error.invalidName
            }
            self.value = value
        }
    }
}

// MARK: Convenience

extension File.Name {
    public init<T: StringProtocol>(_ value: T) throws {
        try self.init(.init(value))
    }
}

// MARK: Equatable

extension File.Name: Equatable {
     public static func == <T: StringProtocol>(lhs: Self, rhs: T) -> Bool {
        return lhs.value.value == rhs
    }

    public static func == <T: StringProtocol>(lhs: T, rhs: Self) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension File.Name: CustomStringConvertible {
    public var description: String { value.description }
}
