import Platform

#if os(macOS)
func lseek(_ handle: Int32, _ offset: Int, _ origin: Int32) -> Int {
    return Int(Platform.lseek(handle, Int64(offset), origin))
}
#endif

#if os(Linux)
extension dirent {
    var d_namlen: Int {
        withUnsafeBytes(of: d_name) { $0.firstIndex(of: 0) } ?? 0
    }
}
#endif

extension UnsafeMutablePointer where Pointee == dirent {
    var isDirectory: Bool {
        return Int(pointee.d_type) & Int(DT_DIR) != 0
    }

    var isCurrentDirectory: Bool {
        return pointee.d_name.0 == UInt8(ascii: ".")
            && pointee.d_name.1 == 0
    }

    var isParentDirectory: Bool {
        return pointee.d_name.0 == UInt8(ascii: ".")
            && pointee.d_name.1 == UInt8(ascii: ".")
            && pointee.d_name.2 == 0
    }

    var name: String {
        withUnsafeBytes(of: pointee.d_name) { buffer in
            .init(decoding: buffer[..<Int(pointee.d_namlen)], as: UTF8.self)
        }
    }
}
