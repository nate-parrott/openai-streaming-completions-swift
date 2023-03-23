import Foundation

public struct OpenAIAPI {
    var apiKey: String
    var orgId: String?
    var origin = "https://api.openai.com"

    public init(apiKey: String, orgId: String? = nil, origin: String? = nil) {
        self.apiKey = apiKey
        self.orgId = orgId
        if let origin = origin {
            self.origin = origin
        }
    }
}

extension OpenAIAPI {
    enum Errors: Error {
        case noChoices
        case invalidResponse(String)
        case noApiKey
    }
}

