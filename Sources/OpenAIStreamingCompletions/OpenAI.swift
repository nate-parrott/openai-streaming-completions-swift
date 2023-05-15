import Foundation

public struct OpenAIAPI {
    var apiKey: String
    var host: String = "api.openai.com"
    var orgId: String?

    public init(apiKey: String, host: String? = nil, orgId: String? = nil) {
        self.apiKey = apiKey
        if let host = host {
            self.host = host
        }
        self.orgId = orgId
    }
}

extension OpenAIAPI {
    enum Errors: Error {
        case noChoices
        case invalidResponse(String)
        case noApiKey
    }
}

