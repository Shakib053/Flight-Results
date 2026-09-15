import Foundation

enum Config {
    static var serpApiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "SERPAPI_API_KEY") as? String ?? ""
    }
}
