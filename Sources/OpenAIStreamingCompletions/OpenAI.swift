import Foundation

public struct OpenAIAPI {
    var apiKey: String
    var orgId: String?

    public init(apiKey: String, orgId: String? = nil) {
        self.apiKey = apiKey
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

