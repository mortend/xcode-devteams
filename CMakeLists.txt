cmake_minimum_required(VERSION 3.0)
project(xcode-devteams)

set(CMAKE_EXE_LINKER_FLAGS "-framework Cocoa -framework AppKit -framework CoreData -framework Foundation -framework Security")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)

add_executable(xcode-devteams objc/main.mm)
