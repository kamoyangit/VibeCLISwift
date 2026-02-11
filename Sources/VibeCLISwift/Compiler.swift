import Foundation

class Compiler {
    func compile(code: String, appName: String) throws -> String {
        let fileManager = FileManager.default
        let currentDir = fileManager.currentDirectoryPath
        let sourcePath = "\(currentDir)/\(appName).swift"
        let binaryPath = "\(currentDir)/\(appName)"
        
        print("Saving source to: \(sourcePath)")
        try code.write(toFile: sourcePath, atomically: true, encoding: .utf8)
        
        let process = Process()
        // Locate swiftc using /usr/bin/env or assume path. 
        // Standard path is /usr/bin/swiftc on macOS with Xcode Command Line Tools.
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
        process.arguments = [sourcePath, "-o", binaryPath]
        
        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe // Capture both for debugging
        
        print("Compiling...")
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 {
            throw CompilationError.failed(output: output)
        }
        
        // Ensure execution permissions
        let chmod = Process()
        chmod.executableURL = URL(fileURLWithPath: "/bin/chmod")
        chmod.arguments = ["+x", binaryPath]
        try? chmod.run()
        chmod.waitUntilExit()
        
        return binaryPath
    }
}

enum CompilationError: Error {
    case failed(output: String)
}
