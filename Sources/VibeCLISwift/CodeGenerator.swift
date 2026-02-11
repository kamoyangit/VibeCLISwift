import Foundation

class CodeGenerator {
    func createSystemPrompt(name: String, feature: String, notes: String) -> String {
        return """
        You are an expert Swift engineer. Generate a single-file Swift CLI code for macOS based on the following specifications.
        
        1. App Name: \(name)
        2. Feature: \(feature)
        3. Notes: \(notes)
        
        Requirements:
        - Avoid external dependencies like ArgumentParser. Use `CommandLine.arguments` to parse arguments.
        - Must include a `--help` option to display usage instructions.
        - Output ONLY the code. Do not include explanations.
        - Ensure the code is complete and compilable using `swiftc`.
        """
    }
    
    func extractCode(from response: String) -> String {
        // Basic markdown code block extraction
        if let range = response.range(of: "```swift", options: .caseInsensitive),
           let endRange = response.range(of: "```", options: .backwards) {
            
            if range.upperBound < endRange.lowerBound {
                 let code = response[range.upperBound..<endRange.lowerBound]
                 return String(code).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Try generic code block
        if let range = response.range(of: "```"),
           let endRange = response.range(of: "```", options: .backwards) {
               if range.upperBound < endRange.lowerBound {
                   // Verify if the first line is language identifier
                   let content = response[range.upperBound..<endRange.lowerBound]
                   return String(content).trimmingCharacters(in: .whitespacesAndNewlines)
               }
        }
        
        // Assume the whole response is code if no markdown blocks found (fallback)
        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
