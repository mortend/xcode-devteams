const path = require("path")
const { spawn } = require("child_process")

const exe = path.join(
    __dirname,
    "bin/Release/net6.0-macos/osx-x64/xcode-devteams.app/Contents/MacOS/xcode-devteams"
)
spawn(exe, process.argv.slice(2), { stdio: "inherit" })
    .on("exit", process.exit)
