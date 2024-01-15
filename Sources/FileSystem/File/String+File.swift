import Stream

extension String {
    @inlinable
    public init<T: Unicode.Encoding>(
       reading file: File,
       as encoding: T.Type
    ) async throws {
       try await self.init(readingFrom: file.open(), as: encoding)
       try file.close()
   }

    @inlinable
    public init<T: Unicode.Encoding>(
        readingFrom reader: StreamReader,
        as encoding: T.Type
    ) async throws {
        self = try await reader.readUntilEnd { bytes in
            let bytes = bytes.bindMemory(to: T.CodeUnit.self)
            return String(decoding: bytes, as: encoding)
        }
    }
}
