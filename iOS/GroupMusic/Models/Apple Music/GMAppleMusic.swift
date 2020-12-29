//
//  GMAppleMusic.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-29.
//

import Foundation

class GMAppleMusic {
    static func generateSampleURL() {
        let urlBuilder = CiderUrlBuilder(storefront: .canada)
        let applemusicURL: URL = urlBuilder.searchRequest(term: "Offset", limit: nil, offset: nil, types: [.songs]).url!
        var request: URLRequest = URLRequest(url: URL(string: "http://localhost:4431/am-api")!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(APIRequest(requestURL: applemusicURL))
            request.httpBody = data
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                        print(error ?? "Unknown error")                                 // handle network error
                        return
                    }
                print("DATA: \(data)")
                print("RESPONSE: \(String(describing: response))")
                
                let decoder = JSONDecoder()
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                 }
            }
            task.resume()
        } catch {
            fatalError("Could not construct JSON")
        }
    }
    
    struct APIRequest: Codable {
        let requestURL: URL
    }

}
