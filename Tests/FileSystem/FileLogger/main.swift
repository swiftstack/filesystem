import Test
import FileSystem
@testable import Log

func withTempPath(task: (Path) async throws -> Void) async throws {
    let directory = try Directory(at: "/tmp/FileLoggerTests")
    if directory.isExists {
        try directory.remove()
    }
    try directory.create()
    try await task(directory.path)
    try directory.remove()
}

test.case("FileLogger") {
    try await withTempPath { temp in
        await scope {
            let file = try File(name: "logger", at: temp)
            expect(!file.isExists)

            Log.use(try FileLogger(file))
            await Log.info("message")

            expect(file.isExists)
        }

        await scope {
            let file = try File(name: "logger", at: temp)
            let stream = try file.open(flags: .read).inputStream
            let content = try await stream.readUntilEnd(as: String.self)
            expect(content == "[info] message\n")
        }
    }
}

test.run()
