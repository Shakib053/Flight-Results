import Foundation

enum Config {
    static var serpApiKey: String {
        let value = Bundle.main.object(forInfoDictionaryKey: "SERPAPI_API_KEY") as? String ?? ""
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
