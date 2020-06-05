import Stream

extension String {
    @inlinable
    public init<T: Unicode.Encoding>(
        reading file: File,
        as encoding: T.Type) throws
    {
        try self.init(readingFrom: file.open(), as: encoding)
        try file.close()
    }

    @inlinable
    public init<T: Unicode.Encoding>(
        readingFrom reader: StreamReader,
        as encoding: T.Type) throws
    {
        self = try reader.read(while: { _ in true }) { bytes in
            let bytes = bytes.bindMemory(to: T.CodeUnit.self)
            return String(decoding: bytes, as: encoding)
        }
    }
}
