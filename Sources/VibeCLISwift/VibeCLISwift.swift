import Foundation

@main
struct VibeCLISwift {
    static func main() async {
        let session = InteractiveSession()
        print("\u{001B}[1;35m✨ Welcome to VibeCLISwift ✨\u{001B}[0m")
        
        // Step 1: Select Provider
        let provider = session.selectProvider()
        
        // Step 2: Get App Details
        let (appName, feature, notes) = session.collectAppDetails()
        
        let generator = CodeGenerator()
        let sysPrompt = generator.createSystemPrompt(name: appName, feature: feature, notes: notes)
        
        let client = LLMClient()
        let compiler = Compiler()
        
        let currentPrompt = "Please generate the code now."
        
        var attempts = 0
        let maxAttempts = 3
        
        print("\n\u{001B}[1;33m🧠 Generating Code with \(provider.modelName)...\u{001B}[0m")
        
        // Initial generation
        var code = ""
        do {
            // We send our specific instructions as system prompt if possible, or prepended to user prompt
            // My LLMClient.send(prompt: ..., systemPrompt: ...) handles it.
            let response = try await client.send(prompt: currentPrompt, provider: provider, systemPrompt: sysPrompt)
            code = generator.extractCode(from: response)
        } catch {
            print("\u{001B}[1;31mError generating code: \(error)\u{001B}[0m")
            return
        }
        
        // Compilation Loop
        while attempts < maxAttempts {
            do {
                if code.isEmpty {
                     print("Generated code was empty. Aborting.")
                     break
                }
                
                print("\n\u{001B}[1;34m🔨 Compiling (Attempt \(attempts + 1))...\u{001B}[0m")
                let binaryPath = try compiler.compile(code: code, appName: appName)
                print("\n\u{001B}[1;32m🚀 Success! Binary created at: \(binaryPath)\u{001B}[0m")
                print("Try running it: \(binaryPath) --help")
                break
            } catch CompilationError.failed(let output) {
                print("\u{001B}[1;31m❌ Compilation Failed:\u{001B}[0m")
                // print(output) // Optionally print full output, or just summary
                
                attempts += 1
                if attempts >= maxAttempts {
                    print("Max attempts reached. Exiting.")
                    print("Last compilation error: \(output)")
                    break
                }
                
                print("Retrying with LLM (Fixing errors)...")
                
                let fixPrompt = """
                The following Swift code failed to compile:
                
                ```swift
                \(code)
                ```
                
                Compiler Output:
                \(output)
                
                Please fix the errors and return ONLY the full corrected Swift code.
                """
                
                do {
                    // For retry, we treat it as a new request with the context in the prompt
                    let response = try await client.send(prompt: fixPrompt, provider: provider, systemPrompt: "You are an expert Swift engineer fixing compilation errors.")
                    code = generator.extractCode(from: response)
                } catch {
                     print("Error during retry generation: \(error)")
                     break
                }
            } catch {
                print("Unexpected error: \(error)")
                break
            }
        }
    }
}
