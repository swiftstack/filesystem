public enum TempPathSuffix {
    case random
    case components(String)
}

extension TempPathSuffix: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self = .components(stringLiteral)
    }
}

extension Path {
    public static var temp: Path {
        #if os(macOS)
        try! .init("/private/tmp")
        #else
        try! .init("/tmp")
        #endif
    }
}

public func withTempPath(
    suffix: TempPathSuffix = .random,
    task: (Path) async throws -> Void
) async throws {
    try await withTempDirectory(suffix: suffix) { directory in
        try await task(directory.path)
    }
}

public func withTempDirectory(
    suffix: TempPathSuffix = .random,
    task: (Directory) async throws -> Void
) async throws {
    var path = Path.temp

    try path.append("SwiftStack")

    switch suffix {
    case .components(let components): try path.append(Path(components))
    case .random: try path.append(String(UInt64.random(in: (.min ... .max))))
    }

    let directory: Directory = try .init(at: path)
    if directory.isExists {
        try directory.remove()
    }
    try directory.create()
    try await task(directory)
    try directory.remove()
}
