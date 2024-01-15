import Test
import Stream
import Platform
import FileSystem

@testable import struct FileSystem.Permissions

test("Name") {
    let name = try File.Name("file")
    expect(name == "file")
    expect(throws: File.Error.invalidName) {
        _ = try File.Name("")
    }
}

test("Init") {
    try await withTempPath { temp in
        let path = try temp.appending("Init")
        let file = try File(name: "Init", at: temp)
        expect(file.name == "Init")
        expect(file.location == temp)
        expect(file.path == path)
    }
}

test("InitPath") {
    try await withTempPath { temp in
        let path = try temp.appending("InitPath")
        let file = try File(at: path)
        expect(file.name == "InitPath")
        expect(file.location == temp)
        expect(file.path == path)
    }
}

test("InitString") {
    try await withTempPath { temp in
        let path = try temp.appending("InitString")
        let file = try File(at: path.string)
        expect(file.name == "InitString")
        expect(file.location == temp)
        expect(file.path == path)
    }
}

test("Description") {
    try await withTempPath { temp in
        let file = try File(name: "Description", at: temp)
        expect(file.description == "file://\(temp)/Description")
    }
}

test("Open") {
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

test("CreateExists") {
    try await withTempPath { temp in
        let file = try File(name: "CreateExists", at: temp)
        expect(!file.isExists)
        try file.create()
        expect(file.isExists)
    }
}

test("ReadWrite") {
    try await withTempPath { temp in
        await scope {
            let file = try File(name: "test.read-write", at: temp)
            let stream = try file.open(flags: [.write, .create, .truncate])
            try await stream.write("test string")
            try await stream.flush()
        }

        await scope {
            let file = try File(name: "test.read-write", at: temp)
            // FIXME: [Concurrency] async init issue
            let string = try await String.asyncInit(reading: file, as: UTF8.self)
            expect(string == "test string")
            try file.remove()
        }
    }
}

test("Rename") {
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

test("Lifetime") {
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
        // FIXME: [Concurrency] async init issue
        let string = try await String.asyncInit(readingFrom: reader, as: UTF8.self)
        expect(string == "test string")
    }
}

test("Persmissions") {
    let permissions = Permissions.file
    expect(permissions.rawValue == 0x644)
    expect(permissions.owner == [.read, .write])
    expect(permissions.group == .read)
    expect(permissions.others == .read)

    expect(permissions.rawMask == S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
}

test("Equatable") {
    expect(try File(at: "/tmp/file") != (try File(at: "/file")))
    expect(try File(at: "/file") == (try File(at: "/file")))
    expect(try File(at: "/file") == String("/file"))
    expect(String("/file") == (try File(at: "/file")))
}

test("StringProtocol") {
    _ = try File(at: "/file"[...])
    _ = try File(name: "file"[...], at: "/"[...])
    _ = try File(name: "file"[...], at: Path("/"))
    expect(try File(at: "/file") == String("/file")[...])
    expect(String("/file")[...] == (try File(at: "/file")))
}

test("Size") {
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

await run()
