extension File {
    convenience
    public init<T>(name: T, at path: Path) throws
        where T: StringProtocol
    {
        try self.init(name: .init(name), at: path)
    }

    convenience
    public init<T, U>(name: T, at path: U) throws
        where T: StringProtocol, U: StringProtocol
    {
        try self.init(name: .init(name), at: .init(path))
    }

    convenience
    public init(at path: Path) throws {
        var path = path
        guard let name = path.deleteLastComponent() else {
            throw Error.invalidPath
        }
        try self.init(name: .init(name), at: path)
    }

    convenience
    public init<T: StringProtocol>(at path: T) throws {
        try self.init(at: .init(path))
    }
}

// MARK: API

extension File {
    public func rename<T: StringProtocol>(to name: T) throws {
        try rename(to: .init(name))
    }
}

// MARK: Static API

extension File {
    public static func isExists<T, U>(name: T, at path: U) throws -> Bool
        where T: StringProtocol, U: StringProtocol
    {
        try File.isExists(name: .init(name), at: .init(path))
    }

    public static func isExists<T: StringProtocol>(at path: T) throws -> Bool {
        try File.isExists(at: .init(path))
    }

    public static func remove<T: StringProtocol>(at path: T) throws {
        try File.remove(at: .init(path))
    }

    public static func rename<OldName, NewName, Path>(
        _ old: OldName, to new: NewName, at path: Path
    ) throws where
        OldName: StringProtocol, NewName: StringProtocol, Path: StringProtocol
    {
        try File.rename(.init(old), to: .init(new), at: .init(path))
    }
}
