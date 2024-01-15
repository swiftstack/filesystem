import Stream
import Platform

extension File {
    public typealias Stream = BufferedStream<File>

    public func open(
        flags: Flags = .read,
        permissions: Permissions = .file,
        bufferSize: Int = 4096
    ) throws -> Stream {
        do {
            try open(flags, permissions)
            return BufferedStream(baseStream: self, capacity: bufferSize)
        } catch let error as SystemError {
            throw File.Error(systemError: error)
        }
    }
}

extension File: Stream {
    public func read(
        to buffer: UnsafeMutableRawPointer,
        byteCount: Int
    ) async throws -> Int {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        return try system {
            return Platform.read(descriptor.rawValue, buffer, byteCount)
        }
    }

    public func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int
    ) async throws -> Int {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        return try system {
            return Platform.write(descriptor.rawValue, buffer, byteCount)
        }
    }
}
