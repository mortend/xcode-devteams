#!/usr/bin/env node
const path = require("path")
const os = require("os")
const {spawn} = require("child_process")

if (os.platform() !== "darwin") {
    console.error("xcode-devteams only runs on macOS")
    process.exit(1)
}

const exe = path.join(__dirname, "bin/xcode-devteams")

spawn(exe, process.argv.slice(2), {stdio: "inherit"})
    .on("exit", process.exit)
