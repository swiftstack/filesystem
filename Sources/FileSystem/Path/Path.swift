import Platform

public struct Path {
    public var components: [Component]

    public enum `Type` {
        case absolute
        case relative
    }

    public var type: Type {
        #if os(Windows)
        // on windows absolute path starts with 'C:'
        return components[0].last == ":" ? .absolute : .relative
        #else
        // on other platforms absolute path starts with ''
        return components[0].isEmpty ? .absolute : .relative
        #endif
    }

    static var separator: Character {
        #if os(Windows)
        return "\\"
        #else
        return "/"
        #endif
    }

    public init<T: Collection>(components: T) where T.Element == Component {
        self.components = !components.isEmpty
            ? [Component](components)
            : ["."]
    }


    public mutating func append(_ component: Component) {
        components.append(component)
    }

    public mutating func append(_ another: Path) {
        components.append(contentsOf: another.components)
    }

    @discardableResult
    public mutating func deleteLastComponent() -> Path.Component? {
        return components.popLast()
    }
}

extension Path {
    public var deletingLastComponent: Path {
        guard components.count > 1 else {
            switch type {
            case .absolute: return self
            case .relative: return .init(components: [])
            }
        }
        return .init(components: components.dropLast())
    }

    public func appending(_ component: Component) -> Path {
        var path = self
        path.append(component)
        return path
    }

    public func appending(_ another: Path) -> Path {
        var path = self
        path.append(another)
        return path
    }
}

extension Path {
    public var string: String {
        switch components.count {
        case 1 where type == .absolute:
            return components[0].value + String(Path.separator)
        default:
            return components
                .map { $0.value }
                .joined(separator: String(Path.separator))
        }
    }

    public init<T: StringProtocol>(_ path: T) throws {
        #if !os(Windows)
        guard path != String(Path.separator) else {
            components = [""]
            return
        }
        #endif
        components = try [Component](path)
    }

    public mutating func append<T: StringProtocol>(_ another: T) throws {
        try components.append(contentsOf: [Component](another))
    }

    public func appending<T: StringProtocol>(_ another: T) throws -> Path {
        var path = self
        try path.append(another)
        return path
    }
}

extension Path {
    enum Error: String, Swift.Error {
        case cantGetHome = "Environment variable HOME is empty"
    }

    public mutating func expandTilde() throws {
        guard type == .relative, components.first == "~" else {
            return
        }
        guard let home = Environment["HOME"] else {
            throw Error.cantGetHome
        }
        let homeComponents = try [Component](home)
        self.components = homeComponents + components[1...]
    }

    public func expandingTilde() throws -> Path {
        var path = self
        try path.expandTilde()
        return path
    }
}

// MARK: Equatable

extension Path: Equatable {
    public static func ==<T: StringProtocol>(lhs: Path, rhs: T) -> Bool {
        return lhs.string == rhs
    }

    public static func ==<T: StringProtocol>(lhs: T, rhs: Path) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension Path: CustomStringConvertible {
    public var description: String {
        return string
    }
}
