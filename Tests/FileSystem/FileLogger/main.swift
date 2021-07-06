import Test
import FileSystem
@testable import Log

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
