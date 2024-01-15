import Test
import Platform
import FileSystem

let temp = try! Path("/tmp/DirectoryTests")

// set up
try? Directory.create(at: temp)

test("Name") {
    let name = try Directory.Name("test")
    expect(name == "test")
}

test("Location") {
    let directory = try Directory(name: "test", at: "/tmp")
    expect(directory.location == "/tmp")
}

test("Path") {
    let directory = try Directory(at: "/tmp")
    expect(directory.path == "/tmp")
}

test("Description") {
    let directory = try Directory(name: "test", at: "/tmp")
    expect(directory.description == "/tmp/test")
}

test("Exists") {
    let directory = try Directory(at: temp.appending("testExists"))
    expect(!directory.isExists)
}

test("Create") {
    let directory = try Directory(at: temp.appending("testCreate"))
    expect(!directory.isExists)
    try directory.create()
    expect(directory.isExists)
}

test("CreateIntermediate") {
    let path = try temp.appending("testCreateIntermediate/one/two")
    let directory = try Directory(at: path)

    expect(!directory.isExists)
    try directory.create(withIntermediateDirectories: true)
    expect(directory.isExists)
}

test("Remove") {
    let directory = try Directory(at: temp.appending("testRemove"))
    try directory.create()
    try directory.remove()
    expect(!directory.isExists)
}

test("RemoveWithContent") {
    let path = try temp.appending("testRemoveWithContent")
    try Directory.create(at: path.appending("one"))
    try Directory.remove(at: path)
    expect(!Directory.isExists(at: path))
}

test("Current") {
    expect(Directory.current?.name.description.lowercased() == "filesystem")

    Directory.current = try Directory(at: temp)

    #if os(macOS)
    expect(Directory.current == "/private/tmp/DirectoryTests")
    #else
    expect(Directory.current == "/tmp/DirectoryTests")
    #endif
}

test("ChangeWorkingDirectory") {
    guard let previous = Directory.current else {
        fail()
        return
    }

    try Directory.changeWorkingDirectory(to: "/")
    expect(Directory.current == "/")

    try Directory.changeWorkingDirectory(to: "/tmp")
    #if os(macOS)
    expect(Directory.current == "/private/tmp")
    #else
    expect(Directory.current == "/tmp")
    #endif

    try Directory.changeWorkingDirectory(to: previous.path)
}

test("InitFromString") {
    let path: String = "/"
    let directory = try Directory(at: path)
    expect(directory.isExists)
}

test("Contents") {
    let temp = try temp.appending("testContents")
    let dir1 = try Directory(name: "dir1", at: temp.string)
    try dir1.create()

    let directory = try Directory(at: temp)
    let contents = try directory.contents()

    expect(contents == [.directory(dir1)])
}

test("Equatable") {
    let rootDirectoryString = "/"
    let tempDirectoryString = "/tmp"

    let rootDirectory = try Directory(at: rootDirectoryString)
    let tempDirectory = try Directory(at: tempDirectoryString)

    expect(rootDirectory == rootDirectory)
    expect(tempDirectory != rootDirectory)

    expect(rootDirectory == rootDirectoryString)
    expect(rootDirectoryString == rootDirectory)
}

test("StringProtocol") {
    _ = try Directory(at: "/tmp"[...])
    _ = try Directory(name: "tmp"[...], at: "/"[...])
    expect(try Directory(at: "/") == String("/")[...])
    expect(String("/")[...] == (try Directory(at: "/")))
}

// tear down
try Directory.remove(at: temp)

await run()
