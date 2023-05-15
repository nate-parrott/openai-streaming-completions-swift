import Foundation

public struct OpenAIAPI {
    var apiKey: String
    var host: String = "api.openai.com"
    var orgId: String?

    public init(apiKey: String, host: String? = nil, orgId: String? = nil) {
        self.apiKey = apiKey
        if let host = host {
            if host.isValidDomain() {
                self.host = host
            }
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

extension String {
    func isValidDomain() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^(?=.{1,255}$)(?!\\\\d+$)[a-z0-9-]+(\\.[a-z0-9-]+)*$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        var domain = self
        if hasPrefix("https://") {
            return false
        }
        let isDomainValid = regex.firstMatch(in: domain, options: [], range: range) != nil
        
        return isDomainValid
    }
}
