import Foundation
import Combine

extension OpenAIAPI {
    public struct CompletionRequest: Codable {
        var prompt: String
        var model = "text-davinci-003"
        var max_tokens: Int = 1500
        var temperature: Double = 0.2
        var stream = false
        var stop: [String]?

        public init(prompt: String, model: String = "text-davinci-003", max_tokens: Int = 1500, temperature: Double = 0.2, stop: [String]? = nil) {
            self.prompt = prompt
            self.model = model
            self.max_tokens = max_tokens
            self.temperature = temperature
            self.stop = stop
        }
    }

    struct CompletionResponse: Codable {
        struct Choice: Codable {
            var text: String
        }
        var choices: [Choice]
    }

    public func complete(_ completionRequest: CompletionRequest) async throws -> String {
        let request = try createTextRequest(completionRequest: completionRequest)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw Errors.invalidResponse(String(data: data, encoding: .utf8) ?? "<failed to decode response>")
        }
        let completionResponse = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard completionResponse.choices.count > 0 else {
            throw Errors.noChoices
        }
        return completionResponse.choices[0].text
    }

    public func completeStreaming(_ completionRequest: CompletionRequest) throws -> StreamingCompletion {
        var cr = completionRequest
        cr.stream = true

        let request = try createTextRequest(completionRequest: cr)
        let src = EventSource(urlRequest: request)
        let completion = StreamingCompletion()
        src.onComplete { statusCode, reconnect, error in
            DispatchQueue.main.async {
                if let statusCode, statusCode / 100 == 2 {
                    completion.status = .complete
                }
            }
        }
        src.onMessage { id, event, data in
            guard let data else { return }
            let textOpt = decodeStreamingResponse(jsonStr: data)
            DispatchQueue.main.async {
                if let textOpt {
                    completion.text += textOpt
                }
            }
        }
        src.connect()
        return completion
    }

    private func decodeStreamingResponse(jsonStr: String) -> String? {
        guard let json = try? JSONDecoder().decode(CompletionResponse.self, from: Data(jsonStr.utf8)) else {
            return nil
        }
        return json.choices.first?.text
    }

    private func createTextRequest(completionRequest: CompletionRequest) throws -> URLRequest {
        let url = URL(string: "\(self.origin)/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let orgId {
            request.setValue(orgId, forHTTPHeaderField: "OpenAI-Organization")
        }
        request.httpBody = try JSONEncoder().encode(completionRequest)
        return request
    }
}

public class StreamingCompletion: ObservableObject {
    public enum Status: Equatable {
        case loading
        case complete
        case error
    }
    @Published public var status = Status.loading
    @Published public var text: String = ""

    init() {}
}
