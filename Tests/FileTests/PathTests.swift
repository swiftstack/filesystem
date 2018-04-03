import Test
@testable import File

final class PathTests: TestCase {
    func testDescription() {
        let path = Path(string: "/tmp/test")
        assertEqual(path.description, "/tmp/test")
    }

    func testAbsolutePath() {
        let path = Path(string: "/tmp/test")
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.type, .absolute)
    }

    func testRelativePath() {
        let path = Path(string: "tmp/test")
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.type, .relative)
    }

    func testString() {
        let string = "/tmp/test"
        let path = Path(string: string)
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.string, string)
    }

    func testAppending() {
        let path = Path(string: "/tmp")
        let test = path.appending("test")
        assertEqual(test.string, "/tmp/test")
    }

    func testAppendingMany() {
        let path = Path(string: "/tmp")
        let test = path.appending("one/two")
        assertEqual(test.components.count, 3)
    }

    func testRemovingLastComponent() {
        let path = Path(string: "/tmp/test")
        let tmp = path.removingLastComponent()
        assertEqual(tmp.string, "/tmp")
    }
}
