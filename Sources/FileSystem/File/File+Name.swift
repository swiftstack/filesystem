extension File {
    public struct Name: Equatable {
        let value: Path.Component

        public var `extension`: String? {
            let value = self.value.value
            guard let index = value.lastIndex(of: ".") else { return nil }
            return String(value[index...])
        }

        public var isValid: Bool { !value.isEmpty && value.isValid }

        public init(_ value: Path.Component) {
            self.value = value
        }

        public init<T: StringProtocol>(_ value: T) {
            self.value = .init(value)
        }
    }
}

extension File.Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = .init(value)
    }
}
