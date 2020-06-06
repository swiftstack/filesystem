import Test
import Platform
import FileSystem

final class DirectoryTests: TestCase {
    let temp = try! Path("/tmp/DirectoryTests")

    override func setUp() {
        try? Directory.create(at: temp)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func testName() throws {
        let name = try Directory.Name("test")
        expect(name == "test")
    }

    func testLocation() throws {
        let directory = try Directory(name: "test", at: "/tmp")
        expect(directory.location == "/tmp")
    }

    func testPath() throws {
        let directory = try Directory(at: "/tmp")
        expect(directory.path == "/tmp")
    }

    func testDescription() throws {
        let directory = try Directory(name: "test", at: "/tmp")
        expect(directory.description == "/tmp/test")
    }

    func testExists() throws {
        let directory = try Directory(at: temp.appending("testExists"))
        expect(!directory.isExists)
    }

    func testCreate() throws {
        let directory = try Directory(at: temp.appending("testCreate"))
        expect(!directory.isExists)
        try directory.create()
        expect(directory.isExists)
    }

    func testCreateIntermediate() throws {
        let path = try temp.appending("testCreateIntermediate/one/two")
        let directory = try Directory(at: path)

        expect(!directory.isExists)
        try directory.create(withIntermediateDirectories: true)
        expect(directory.isExists)
    }

    func testRemove() throws {
        let directory = try Directory(at: temp.appending("testRemove"))
        try directory.create()
        try directory.remove()
        expect(!directory.isExists)
    }

    func testRemoveWithContent() throws {
        let path = try temp.appending("testRemoveWithContent")
        try Directory.create(at: path.appending("one"))
        try Directory.remove(at: path)
        expect(!Directory.isExists(at: path))
    }

    func testCurrent() throws {
        #if Xcode
        expect(Directory.current == "/private/tmp")
        #else
        let aio = try Directory.current?.path.string.suffix(3).uppercased()
        expect(aio == "AIO")
        #endif

        Directory.current = try Directory(at: temp)

        #if os(macOS)
        expect(Directory.current == "/private/tmp/DirectoryTests")
        #else
        expect(Directory.current == "/tmp/DirectoryTests")
        #endif
    }

    func testChangeWorkingDirectory() throws {
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

    func testInitFromString() throws {
        let path: String = "/"
        let directory = try Directory(at: path)
        expect(directory.isExists)
    }

    func testContents() throws {
        let temp = try self.temp.appending(#function)
        let dir1 = try Directory(name: "dir1", at: temp.string)
        try dir1.create()

        let directory = try Directory(at: temp)
        let contents = try directory.contents()

        expect(contents == [.directory(dir1)])
    }

    func testEquatable() throws {
        let rootDirectoryString = "/"
        let tempDirectoryString = "/tmp"

        let rootDirectory = try Directory(at: rootDirectoryString)
        let tempDirectory = try Directory(at: tempDirectoryString)

        expect(rootDirectory == rootDirectory)
        expect(tempDirectory != rootDirectory)

        expect(rootDirectory == rootDirectoryString)
        expect(rootDirectoryString == rootDirectory)
    }

    func testStringProtocol() throws {
        _ = try Directory(at: "/tmp"[...])
        _ = try Directory(name: "tmp"[...], at: "/"[...])
        expect(try Directory(at: "/") == String("/")[...])
        expect(String("/")[...] == (try Directory(at: "/")))
    }
}
