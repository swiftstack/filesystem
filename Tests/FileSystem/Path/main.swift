import Test
import Platform
import FileSystem

test("Components") {
    let path = try Path("/")
    expect(path == "/")
    expect(path.components == [""])
}

test("Description") {
    let path = try Path("/tmp/test")
    expect(path.description == "/tmp/test")
}

test("AbsolutePath") {
    let path = try Path("/tmp/test")
    expect(path.components == ["", "tmp", "test"])
    expect(path.type == .absolute)
}

test("RelativePath") {
    let path = try Path("tmp/test")
    expect(path.components == ["tmp", "test"])
    expect(path.type == .relative)
}

test("String") {
    let string = "/tmp/test"
    let path = try Path(string)
    expect(path.components == ["", "tmp", "test"])
    expect(path.string == string)
}

test("Append") {
    var path = try Path("/tmp")
    try path.append("test")
    expect(path.string == "/tmp/test")
}

test("Appending") {
    let path = try Path("/tmp")
    let test = try path.appending("test")
    expect(test.string == "/tmp/test")
}

test("AppendingMany") {
    let path = try Path("/tmp")
    let test = try path.appending("one/two")
    expect(test.string == "/tmp/one/two")
    expect(test.components == ["", "tmp", "one", "two"])
}

test("AppendComponent") {
    var path = try Path("/tmp")
    try path.append("test")
    expect(path.string == "/tmp/test")
}

test("AppendingComponent") {
    let path = try Path("/tmp")
    let test = try Path.Component("test")
    let combined = path.appending(test)
    expect(combined.string == "/tmp/test")
}

test("AppendPath") {
    var path = try Path("/tmp")
    try path.append(Path("test"))
    expect(path.string == "/tmp/test")
}

test("AppendingPath") {
    let path = try Path("/tmp")
    let test = try Path("test")
    let combined = path.appending(test)
    expect(combined.string == "/tmp/test")
}

test("DeletingLastComponent") {
    let path = try Path("/tmp/test")
    let tmp = path.deletingLastComponent
    expect(tmp.string == "/tmp")
}

test("ExpandTilde") {
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

test("Equatable") {
    let pathString: String = "/"
    let path: Path = try .init(pathString)
    expect(path == path)
    expect(path == pathString)
    expect(pathString == path)
}

test("StringProtocol") {
    let pathSubstring: Substring = "/"[...]
    let pathComponentSubstring: Substring = "component"[...]

    var path = try Path(pathSubstring)
    expect(path == pathSubstring)
    expect(pathSubstring == path)

    try path.append(pathComponentSubstring)
    _ = try path.appending(pathComponentSubstring)
}

await run()
