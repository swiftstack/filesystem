import Platform

public final class Directory {
    public let name: Name
    public let location: Path

    public var path: Path {
        return location.appending(name.value)
    }

    var handle: DirectoryHandle?

    public init(name: Name, at location: Path) {
        self.name = name
        self.location = location
    }

    convenience
    public init(at path: Path) throws {
        var path = path
        let name = path.deleteLastComponent() ?? .empty
        try self.init(name: .init(name), at: path)
    }

    deinit {
        try? close()
    }

    public var isExists: Bool {
        return Directory.isExists(at: path)
    }

    public func open() throws {
        guard handle == nil else {
            return
        }
        self.handle = try system {
            return opendir(path.string)
        }
    }

    public func close() throws {
        if let handle = handle {
            closedir(handle)
            self.handle = nil
        }
    }

    public func create(
        withIntermediateDirectories: Bool = true,
        permissions: Permissions = .directory
    ) throws {
        try Directory.create(
            at: path,
            withIntermediateDirectories: withIntermediateDirectories,
            permissions: permissions)
    }

    public func remove() throws {
        try close()
        try Directory.remove(at: path)
    }

    public func contents() throws -> [Entry] {
        return try Directory.contents(at: path)
    }
}

// MARK: static

extension Directory {
    public static var current: Directory? {
        get {
            var directory = [Int8](repeating: 0, count: Int(PATH_MAX))
            guard getcwd(&directory, directory.count) != nil else { return nil }
            return try? Directory(at: String(cString: directory))
        }
        set {
            if let newValue = newValue {
                chdir(newValue.path.string)
            }
        }
    }

    public static func isExists(at path: Path) -> Bool {
        return access(path.string, F_OK) == 0
    }

    public static func create(
        at path: Path,
        withIntermediateDirectories: Bool = true,
        permissions: Permissions = .directory
    ) throws {
        func createCurrent() throws {
            try system { mkdir(path.string, permissions.rawMask) }
        }

        func createParent() throws {
            if !path.components.isEmpty {
                let path = path.deletingLastComponent
                if !isExists(at: path) {
                    try create(at: path, permissions: .intermediateDirectories)
                }
            }
        }

        switch withIntermediateDirectories {
        case true:
            try createParent()
            try createCurrent()
        case false:
            try createCurrent()
        }
    }

    public static func remove(at path: Path) throws {
        let iterator = try DirectoryContentsIterator(at: path)
        while let entry = iterator.next() {
            switch entry {
            case .directory(let directory): try directory.remove()
            case .file(let file): try file.remove()
            }
        }
        iterator.close()
        try system { rmdir(path.string) }
    }

    public static func changeWorkingDirectory(to path: Path) throws {
        try system { chdir(path.string) }
    }

    public static func contents(at path: Path) throws -> [Entry] {
        let iterator = try DirectoryContentsIterator(at: path)
        return [Entry](IteratorSequence(iterator))
    }
}

// MARK: Equatable

extension Directory: Equatable {
    public static func == (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.name == rhs.name && lhs.location == rhs.location
    }

    public static func == <T: StringProtocol>(lhs: Directory, rhs: T) -> Bool {
        return lhs.path.string == rhs
    }

    public static func == <T: StringProtocol>(lhs: T, rhs: Directory) -> Bool {
        return rhs == lhs
    }
}

extension Optional where Wrapped == Directory {
    public static func == <T: StringProtocol>(lhs: Self, rhs: T) -> Bool {
        guard let lhs = lhs else { return false }
        return lhs == rhs
    }

    public static func == <T: StringProtocol>(lhs: T, rhs: Self) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension Directory: CustomStringConvertible {
    public var description: String {
        return path.description
    }
}
