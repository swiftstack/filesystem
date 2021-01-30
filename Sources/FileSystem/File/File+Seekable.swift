import Stream
import Platform

extension File: Seekable {
    public func seek(to offset: Int, from origin: SeekOrigin) throws {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        try system { lseek(descriptor.rawValue, offset, origin.rawValue) }
    }
}

extension Seekable {
    public func seek(to origin: SeekOrigin) async throws {
        try await seek(to: 0, from: origin)
    }
}

extension BufferedOutputStream: Seekable where T == File {
    public func seek(to offset: Int, from origin: SeekOrigin) async throws {
        switch origin {
        case .current where offset == 0:
            return
        default:
            try await flush()
            try baseStream.seek(to: offset, from: origin)
        }
    }
}

extension BufferedInputStream: Seekable where T == File {
    public func seek(to offset: Int, from origin: SeekOrigin) async throws {
        switch origin {
        case .current where offset == 0:
            return
        case .current where offset > 0 && buffered > offset:
            try await consume(count: offset)
        default:
            clear()
            try baseStream.seek(to: offset, from: origin)
        }
    }
}

extension BufferedStream: Seekable where T == File {
    public func seek(to offset: Int, from origin: SeekOrigin) async throws {
        try await inputStream.seek(to: offset, from: origin)
        try await outputStream.seek(to: offset, from: origin)
    }
}

extension SeekOrigin {
    var rawValue: Int32 {
        switch self {
        case .end: return SEEK_END
        case .current: return SEEK_CUR
        case .begin: return SEEK_SET
        }
    }
}
