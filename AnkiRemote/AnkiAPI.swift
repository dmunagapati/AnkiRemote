import Foundation

struct AnkiAPI {
    static let baseURL = "http://192.168.1.123:8765"
    
    static func invoke(action: String, params: [String: Any] = [:], completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        let json: [String: Any] = [
            "action": action,
            "version": 6,
            "params": params
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data,
               let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = jsonResponse["result"] as? [String] {
                completion(.success(result))
            } else {
                completion(.failure(NSError(domain: "API Error", code: -1, userInfo: nil)))
            }
        }.resume()
    }
}
