import Test
import Stream
import Platform
import FileSystem

@testable import struct FileSystem.Permissions

func withTempPath(task: (Path) async throws -> Void) async throws {
    let directory = try Directory(at: "/tmp/FileTests")
    if directory.isExists {
        try directory.remove()
    }
    try directory.create()
    try await task(directory.path)
    try directory.remove()
}

test.case("Name") {
    let name = try File.Name("file")
    expect(name == "file")
    expect(throws: File.Error.invalidName) {
        _ = try File.Name("")
    }
}

test.case("Init") {
    try await withTempPath { temp in
        let path = try temp.appending("Init")
        let file = try File(name: "Init", at: temp)
        expect(file.name == "Init")
        expect(file.location == temp)
        expect(file.path == path)
    }
}

test.case("InitPath") {
    try await withTempPath { temp in
        let path = try temp.appending("InitPath")
        let file = try File(at: path)
        expect(file.name == "InitPath")
        expect(file.location == temp)
        expect(file.path == path)
    }
}

test.case("InitString") {
    try await withTempPath { temp in
        let path = try temp.appending("InitString")
        let file = try File(at: path.string)
        expect(file.name == "InitString")
        expect(file.location == temp)
        expect(file.path == path)
    }
}

test.case("Description") {
    try await withTempPath { temp in
        let file = try File(name: "Description", at: temp)
        expect(file.description == "file://\(temp)/Description")
    }
}

test.case("Open") {
    try await withTempPath { temp in
        let file = try File(name: "Open", at: temp)
        expect(throws: File.Error.doesntExist) {
            _ = try file.open(flags: .read)
        }
        expect(throws: File.Error.doesntExist) {
            _ = try file.open(flags: .write)
        }

        _ = try file.open(flags: .create)

        expect(throws: File.Error.alreadyOpened) {
            _ = try file.open(flags: .read)
        }

        try file.close()

        _ = try file.open(flags: .write)
        try file.close()

        _ = try file.open(flags: [.read, .write])
        try file.close()

        try file.remove()
    }
}

test.case("CreateExists") {
    try await withTempPath { temp in
        let file = try File(name: "CreateExists", at: temp)
        expect(!file.isExists)
        try file.create()
        expect(file.isExists)
    }
}

// FIXME: Concurrency Stream issue
test.case("ReadWrite") {
    try await withTempPath { temp in
        await scope {
            let file = try File(name: "test.read-write", at: temp)
            let stream = try file.open(flags: [.write, .create, .truncate])
            try await stream.write("test string")
            try await stream.flush()
        }

        await scope {
            let file = try File(name: "test.read-write", at: temp)
            let string = try await String.asyncInit(reading: file, as: UTF8.self)
            expect(string == "test string")
            try file.remove()
        }
    }
}

test.case("Rename") {
    let originalName = try File.Name("test.file")
    let newName = try File.Name("new-test.file")

    try await withTempPath { temp in
        await scope {
            let file = File(name: originalName, at: temp)
            try file.create()

            try file.rename(to: newName)
            expect(!File.isExists(name: originalName, at: temp))
            expect(File.isExists(name: newName, at: temp))
        }

        await scope {
            try File.rename(newName, to: originalName, at: temp)
            expect(File.isExists(name: originalName, at: temp))
            expect(!File.isExists(name: newName, at: temp))
        }
    }
}

// FIXME: Concurrency Stream crash
test.case("Lifetime") {
    var streamReader: StreamReader? = nil

    try await withTempPath { temp in
        let file = try File(name: "test.lifetime", at: temp)
        let stream = try file.open(flags: [.read, .write, .create])
        try await stream.write("test string")
        try await stream.flush()
        try await stream.seek(to: .begin)

        streamReader = stream
    }

    guard let reader = streamReader else {
        fail()
        return
    }

    await scope {
        let string = try await String.asyncInit(readingFrom: reader, as: UTF8.self)
        expect(string == "test string")
    }
}

test.case("Persmissions") {
    let permissions = Permissions.file
    expect(permissions.rawValue == 0x644)
    expect(permissions.owner == [.read, .write])
    expect(permissions.group == .read)
    expect(permissions.others == .read)

    expect(permissions.rawMask == S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
}

test.case("Equatable") {
    expect(try File(at: "/tmp/file") != (try File(at: "/file")))
    expect(try File(at: "/file") == (try File(at: "/file")))
    expect(try File(at: "/file") == String("/file"))
    expect(String("/file") == (try File(at: "/file")))
}

test.case("StringProtocol") {
    _ = try File(at: "/file"[...])
    _ = try File(name: "file"[...], at: "/"[...])
    _ = try File(name: "file"[...], at: Path("/"))
    expect(try File(at: "/file") == String("/file")[...])
    expect(String("/file")[...] == (try File(at: "/file")))
}

// FIXME: Concurrency Stream crash
test.case("Size") {
    try await withTempPath { temp in
        let file = try File(name: "Size", at: temp)
        try file.create()
        expect(file.size == 0)
        let stream = try file.open(flags: .write)
        try await stream.write(.a)
        try await stream.flush()
        expect(file.size == 1)
    }
}

test.run()
