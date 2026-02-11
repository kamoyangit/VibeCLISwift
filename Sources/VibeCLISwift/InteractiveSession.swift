import Foundation

class InteractiveSession {
    func prompt(message: String, defaultValue: String? = nil) -> String {
        print("\u{001B}[1;36m\(message)\u{001B}[0m", terminator: " ")
        if let def = defaultValue {
            print("[\(def)]: ", terminator: "")
        } else {
            print(": ", terminator: "")
        }
        
        if let input = readLine(), !input.isEmpty {
            return input
        }
        return defaultValue ?? ""
    }
    
    func selectProvider() -> LLMProvider {
        print("\n\u{001B}[1;32m=== Select LLM Provider ===\u{001B}[0m")
        print("1. Ollama (Local)")
        print("2. LM Studio (Network)")
        print("3. DeepSeek (Cloud)")
        
        let choice = prompt(message: "Enter number", defaultValue: "1")
        
        switch choice {
        case "2":
            let url = prompt(message: "LM Studio API URL", defaultValue: "http://localhost:1234/v1/chat/completions")
            let model = prompt(message: "Model Name", defaultValue: "local-model")
            return .lmStudio(baseURL: url, model: model)
            
        case "3":
            let apiKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] ?? ""
            if apiKey.isEmpty {
                print("\u{001B}[1;31mWarning: DEEPSEEK_API_KEY not found in environment.\u{001B}[0m")
                let inputKey = prompt(message: "Enter DeepSeek API Key now")
                if inputKey.isEmpty {
                     print("Falling back to Ollama due to missing key.")
                     return .ollama(baseURL: "http://localhost:11434/api/chat", model: "llama3.2")
                }
                return .deepSeek(apiKey: inputKey, model: "deepseek-coder")
            }
            return .deepSeek(apiKey: apiKey, model: "deepseek-coder")
            
        default:
            return .ollama(baseURL: "http://localhost:11434/api/chat", model: "llama3.2")
        }
    }
    
    func collectAppDetails() -> (name: String, feature: String, notes: String) {
        print("\n\u{001B}[1;32m=== App Specification ===\u{001B}[0m")
        let name = prompt(message: "1. App Name (Executive binary name)", defaultValue: "MyTool")
        let feature = prompt(message: "2. Feature Definition (What does it do?)", defaultValue: "Prints Hello World")
        let notes = prompt(message: "3. Additional Notes (Libraries, preferences)", defaultValue: "None")
        return (name, feature, notes)
    }
}
