extension Directory {
    convenience
    public init<T: StringProtocol>(at path: T) throws {
        try self.init(at: .init(path))
    }

    convenience
    public init<T, U>(name: T, at path: U) throws
        where T: StringProtocol, U: StringProtocol
    {
        try self.init(name: .init(name), at: .init(path))
    }
}

// MARK: Static API

extension Directory {
    public static func create<Path: StringProtocol>(
        at path: Path,
        withIntermediateDirectories recursive: Bool = true,
        permissions: Permissions = .directory) throws
    {
        try create(
            at: .init(path),
            withIntermediateDirectories: recursive,
            permissions: permissions)
    }

    public static func remove<Path>(at path: Path) throws
        where Path: StringProtocol
    {
        try Directory.remove(at: .init(path))
    }

    public static func changeWorkingDirectory<Path>(to path: Path) throws
        where Path: StringProtocol
    {
        try Directory.changeWorkingDirectory(to: .init(path))
    }

    public static func contents<Path>(at path: Path) throws -> [Entry]
        where Path: StringProtocol
    {
        try Directory.contents(at: .init(path))
    }
}
