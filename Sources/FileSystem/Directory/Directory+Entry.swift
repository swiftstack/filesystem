import Platform

extension Directory {
    public enum Entry: Equatable {
        case file(File)
        case directory(Directory)
    }
}

// MARK: DirectoryContentsIterator

public class DirectoryContentsIterator: IteratorProtocol {
    let path: Path
    var handle: DirectoryHandle?

    init(at path: Path) throws {
        self.path = path
        self.handle = try system { opendir(path.string) }
    }

    deinit {
        close()
        handle = nil
    }

    func close() {
        guard let handle = handle else {
            return
        }
        closedir(handle)
        self.handle = nil
    }

    public func next() -> Directory.Entry? {
        guard let handle = handle else {
            return nil
        }

        while let entry = readdir(handle) {
            // skip "." and ".."
            if entry.isCurrentDirectory || entry.isParentDirectory {
                continue
            }
            do {
                return entry.isDirectory
                    ? try .directory(.init(name: .init(entry.name), at: path))
                    : try .file(.init(name: .init(entry.name), at: path))
            } catch {
                // shouldn't happen
                fatalError(String(describing: error))
            }
        }

        close()
        return nil
    }
}
