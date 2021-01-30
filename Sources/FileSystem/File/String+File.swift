import Stream

extension String {
    public static func asyncInit<T: Unicode.Encoding>(
        reading file: File,
        as encoding: T.Type) async throws -> String
    {
        let string = try await asyncInit(readingFrom: file.open(), as: encoding)
        try file.close()
        return string
    }

    public static func asyncInit<T: Unicode.Encoding>(
        readingFrom reader: StreamReader,
        as encoding: T.Type) async throws -> String
    {
        return try await reader.readUntilEnd() { bytes in
            let bytes = bytes.bindMemory(to: T.CodeUnit.self)
            return String(decoding: bytes, as: encoding)
        }
    }

//    // FIXME: [Concurrency]
//
//    @inlinable
//    public init<T: Unicode.Encoding>(
//        reading file: File,
//        as encoding: T.Type) async throws
//    {
//        try await self.init(readingFrom: file.open(), as: encoding)
//        try file.close()
//    }
//
//    @inlinable
//    public init<T: Unicode.Encoding>(
//        readingFrom reader: StreamReader,
//        as encoding: T.Type) async throws
//    {
//        self = try await reader.readUntilEnd() { bytes in
//            let bytes = bytes.bindMemory(to: T.CodeUnit.self)
//            return String(decoding: bytes, as: encoding)
//        }
//    }
}
