import Test
import Platform
import FileSystem

final class PathTests: TestCase {
    func testComponents() throws {
        let path = try Path("/")
        expect(path == "/")
        expect(path.components == [""])
    }

    func testDescription() throws {
        let path = try Path("/tmp/test")
        expect(path.description == "/tmp/test")
    }

    func testAbsolutePath() throws {
        let path = try Path("/tmp/test")
        expect(path.components == ["", "tmp", "test"])
        expect(path.type == .absolute)
    }

    func testRelativePath() throws {
        let path = try Path("tmp/test")
        expect(path.components == ["tmp", "test"])
        expect(path.type == .relative)
    }

    func testString() throws {
        let string = "/tmp/test"
        let path = try Path(string)
        expect(path.components == ["", "tmp", "test"])
        expect(path.string == string)
    }

    func testAppend() throws {
        var path = try Path("/tmp")
        try path.append("test")
        expect(path.string == "/tmp/test")
    }

    func testAppending() throws {
        let path = try Path("/tmp")
        let test = try path.appending("test")
        expect(test.string == "/tmp/test")
    }

    func testAppendingMany() throws {
        let path = try Path("/tmp")
        let test = try path.appending("one/two")
        expect(test.string == "/tmp/one/two")
        expect(test.components == ["", "tmp", "one", "two"])
    }

    func testAppendComponent() throws {
        var path = try Path("/tmp")
        try path.append("test")
        expect(path.string == "/tmp/test")
    }

    func testAppendingComponent() throws {
        let path = try Path("/tmp")
        let test = try Path.Component("test")
        let combined = path.appending(test)
        expect(combined.string == "/tmp/test")
    }

    func testAppendPath() throws {
        var path = try Path("/tmp")
        try path.append(Path("test"))
        expect(path.string == "/tmp/test")
    }

    func testAppendingPath() throws {
        let path = try Path("/tmp")
        let test = try Path("test")
        let combined = path.appending(test)
        expect(combined.string == "/tmp/test")
    }

    func testDeletingLastComponent() throws {
        let path = try Path("/tmp/test")
        let tmp = path.deletingLastComponent
        expect(tmp.string == "/tmp")
    }

    func testExpandTilde() throws {
        // TODO: Fix the CI
        guard let home = Environment["HOME"],
            !home.isEmpty else {
                return
        }
        let path = try Path("~/test")
        let homeTest = try path.expandingTilde()

        var copy = path
        try copy.expandTilde()
        expect(homeTest == copy)

        #if os(macOS)
        expect(homeTest.string.starts(with: "/Users"))
        #else
        if !homeTest.string.starts(with: "/home") {
            expect(homeTest.string.starts(with: "/root"))
        }
        #endif
        expect(homeTest.string.suffix(5) == "/test")
    }

    func testEquatable() throws {
        let pathString: String = "/"
        let path: Path = try .init(pathString)
        expect(path == path)
        expect(path == pathString)
        expect(pathString == path)
    }

    func testStringProtocol() throws {
        let pathSubstring: Substring = "/"[...]
        let pathComponentSubstring: Substring = "component"[...]

        var path = try Path(pathSubstring)
        expect(path == pathSubstring)
        expect(pathSubstring == path)

        try path.append(pathComponentSubstring)
        _ = try path.appending(pathComponentSubstring)
    }
}
