import Test
import Platform
import FileSystem

let temp = try! Path("/tmp/DirectoryTests")

// set up
try? Directory.create(at: temp)

test.case("Name") {
    let name = try Directory.Name("test")
    expect(name == "test")
}

test.case("Location") {
    let directory = try Directory(name: "test", at: "/tmp")
    expect(directory.location == "/tmp")
}

test.case("Path") {
    let directory = try Directory(at: "/tmp")
    expect(directory.path == "/tmp")
}

test.case("Description") {
    let directory = try Directory(name: "test", at: "/tmp")
    expect(directory.description == "/tmp/test")
}

test.case("Exists") {
    let directory = try Directory(at: temp.appending("testExists"))
    expect(!directory.isExists)
}

test.case("Create") {
    let directory = try Directory(at: temp.appending("testCreate"))
    expect(!directory.isExists)
    try directory.create()
    expect(directory.isExists)
}

test.case("CreateIntermediate") {
    let path = try temp.appending("testCreateIntermediate/one/two")
    let directory = try Directory(at: path)

    expect(!directory.isExists)
    try directory.create(withIntermediateDirectories: true)
    expect(directory.isExists)
}

test.case("Remove") {
    let directory = try Directory(at: temp.appending("testRemove"))
    try directory.create()
    try directory.remove()
    expect(!directory.isExists)
}

test.case("RemoveWithContent") {
    let path = try temp.appending("testRemoveWithContent")
    try Directory.create(at: path.appending("one"))
    try Directory.remove(at: path)
    expect(!Directory.isExists(at: path))
}

test.case("Current") {
    expect(Directory.current?.name.description == "filesystem")

    Directory.current = try Directory(at: temp)

    #if os(macOS)
    expect(Directory.current == "/private/tmp/DirectoryTests")
    #else
    expect(Directory.current == "/tmp/DirectoryTests")
    #endif
}

test.case("ChangeWorkingDirectory") {
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

test.case("InitFromString") {
    let path: String = "/"
    let directory = try Directory(at: path)
    expect(directory.isExists)
}

test.case("Contents") {
    let temp = try temp.appending("testContents")
    let dir1 = try Directory(name: "dir1", at: temp.string)
    try dir1.create()

    let directory = try Directory(at: temp)
    let contents = try directory.contents()

    expect(contents == [.directory(dir1)])
}

test.case("Equatable") {
    let rootDirectoryString = "/"
    let tempDirectoryString = "/tmp"

    let rootDirectory = try Directory(at: rootDirectoryString)
    let tempDirectory = try Directory(at: tempDirectoryString)

    expect(rootDirectory == rootDirectory)
    expect(tempDirectory != rootDirectory)

    expect(rootDirectory == rootDirectoryString)
    expect(rootDirectoryString == rootDirectory)
}

test.case("StringProtocol") {
    _ = try Directory(at: "/tmp"[...])
    _ = try Directory(name: "tmp"[...], at: "/"[...])
    expect(try Directory(at: "/") == String("/")[...])
    expect(String("/")[...] == (try Directory(at: "/")))
}

// tear down
try Directory.remove(at: temp)

test.run()
