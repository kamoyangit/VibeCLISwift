import Foundation

enum LLMProvider {
    case ollama(baseURL: String, model: String)
    case lmStudio(baseURL: String, model: String)
    case deepSeek(apiKey: String, model: String)

    var endpoint: URL? {
        switch self {
        case .ollama(let url, _): return URL(string: url)
        case .lmStudio(let url, _): return URL(string: url)
        case .deepSeek: return URL(string: "https://api.deepseek.com/chat/completions")
        }
    }
    
    var modelName: String {
        switch self {
        case .ollama(_, let m): return m
        case .lmStudio(_, let m): return m
        case .deepSeek(_, let m): return m
        }
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]?
    // Ollama simplified response or part of complex response, handled separately if needed
}

struct OllamaChatResponse: Codable {
    struct Message: Codable {
        let role: String
        let content: String
    }
    let model: String
    let message: Message?
    let done: Bool
}


class LLMClient {
    private let session = URLSession.shared
    
    func send(prompt: String, provider: LLMProvider, systemPrompt: String? = nil) async throws -> String {
        guard let url = provider.endpoint else {
            throw URLError(.badURL)
        }
        
        var messages: [ChatMessage] = []
        if let system = systemPrompt {
            messages.append(ChatMessage(role: "system", content: system))
        }
        messages.append(ChatMessage(role: "user", content: prompt))
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization header for DeepSeek
        if case .deepSeek(let apiKey, _) = provider {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let payload = ChatRequest(model: provider.modelName, messages: messages, stream: false)
        let jsonData = try JSONEncoder().encode(payload)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                print("API Error: \(errorText)")
            }
            throw URLError(.badServerResponse)
        }
        
        // Debugging raw response if needed
        // print(String(data: data, encoding: .utf8) ?? "No Data")

        // Try decoding as OpenAI format (DeepSeek, LM Studio, some Ollama)
        if let openAIResponse = try? JSONDecoder().decode(ChatResponse.self, from: data),
           let content = openAIResponse.choices?.first?.message.content {
            return content
        }
        
        // Try decoding as Ollama format
        if let ollamaResponse = try? JSONDecoder().decode(OllamaChatResponse.self, from: data),
           let content = ollamaResponse.message?.content {
            return content
        }
        
        throw URLError(.cannotDecodeContentData)
    }
}
