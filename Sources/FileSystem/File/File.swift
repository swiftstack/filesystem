import Stream
import Platform

public class File {
    public private(set) var descriptor: Descriptor?

    public private(set) var name: Name
    public let location: Path

    public var path: Path {
        location.appending(name.value)
    }

    public var isExists: Bool {
        access(path.string, F_OK) == 0
    }

    public var permissions: Permissions? {
        get { return (try? Permissions(for: descriptor)) ?? nil }
        set { try? newValue.set(for: descriptor) }
    }

    public init(name: Name, at location: Path) {
        self.name = name
        self.location = location
    }

    deinit {
        try? close()
    }

    public var size: Int {
        var st = stat()
        switch descriptor {
        case .some(let descriptor): fstat(descriptor.rawValue, &st)
        case .none: stat(path.string, &st)
        }
        return Int(st.st_size)
    }

    func open(
        _ flags: Flags = .read,
        _ permissions: Permissions = .file) throws
    {
        guard self.descriptor == nil else {
            throw Error.alreadyOpened
        }
        let flags = OpenFlags(flags).rawValue
        self.descriptor = Descriptor(rawValue: try system {
            return Platform.open(path.string, flags, permissions.rawMask)
        })
    }

    public func close() throws {
        if let descriptor = descriptor {
            try system { Platform.close(descriptor.rawValue) }
            self.descriptor = nil
        }
    }

    public func create(
        withIntermediateDirectories: Bool = true,
        permissions: Permissions = .file
    ) throws {
        guard descriptor == nil else {
            throw Error.exists
        }
        if withIntermediateDirectories, !Directory.isExists(at: location) {
            try Directory.create(at: self.location)
        }
        try open(.create, permissions)
        try close()
    }

    public func remove() throws {
        try close()
        try system { Platform.remove(path.string) }
    }

    public func rename(to name: Name) throws {
        let newPath = location.appending(name.value)
        try system { Platform.rename(path.string, newPath.string) }
        self.name = name
    }
}

// MARK: static

extension File {
    public static func isExists(name: File.Name, at path: Path) -> Bool {
        File(name: name, at: path).isExists
    }

    public static func isExists(at path: Path) throws -> Bool {
        try File(at: path).isExists
    }

    public static func remove(at path: Path) throws {
        try File(at: path).remove()
    }

    public static func create(
        _ name: Name,
        at path: Path,
        withIntermediateDirectories: Bool,
        permissions: Permissions = .file) throws
    {
        try File(name: name, at: path).create(
            withIntermediateDirectories: withIntermediateDirectories,
            permissions: permissions)
    }

    public static func rename(_ old: Name, to new: Name, at path: Path) throws {
        try File(name: old, at: path).rename(to: new)
    }
}

// MARK: Equatable

extension File: Equatable {
    public static func == (lhs: File, rhs: File) -> Bool {
        return lhs.name == rhs.name && lhs.location == rhs.location
    }

    public static func ==<T: StringProtocol>(lhs: File, rhs: T) -> Bool {
        return lhs.path.string == rhs
    }

    public static func ==<T: StringProtocol>(lhs: T, rhs: File) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension File: CustomStringConvertible {
    public var description: String {
        return "file://" + path.description
    }
}
