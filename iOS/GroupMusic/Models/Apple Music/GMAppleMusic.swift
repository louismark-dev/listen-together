//
//  GMAppleMusic.swift
//  GroupMusic
//
//  Created by Louis on 2020-12-29.
//

import Foundation
import UIKit

class GMAppleMusic {
    
    private let storefront: Storefront
    private let urlBuilder: CiderUrlBuilder
    private let port: Int = (UIApplication.shared.delegate as! AppDelegate).port
    private let apiEndpoint: URL
    private let fetcher: UrlFetcher
    
    init(storefront: Storefront, urlFetcher: UrlFetcher = CiderClient.defaultURLFetcher) {
        self.storefront = storefront
        self.urlBuilder = CiderUrlBuilder(storefront: self.storefront)
        self.apiEndpoint = URL(string: "http://192.168.2.52:\(self.port)/am-api")!
        self.fetcher = urlFetcher
        
    }
    
    public static var defaultURLFetcher: UrlFetcher {
        return URLSession(configuration: URLSessionConfiguration.default)
    }
    
    public func fetch(album: Album, completion: @escaping (([Album]?, Error?) -> Void)) {
        guard let appleMusicURL: URL = urlBuilder.relationshipRequest(path: album.href, limit: nil, offset: nil).url else {
            print("ERROR: Could not generate URL for Album.")
            return
        }
        guard let requestData = self.encodeRequestJSON(forRequestURL: appleMusicURL) else {
            print("Could not encode JSON for Apple Music Album request.")
            return
        }
                
        let request: URLRequest = self.createURLRequest(withData: requestData)
        
        self.fetch(request) { (results: ResponseRoot<Album>?, error) in
            completion(results?.data, error)
        }
    }
    
    public func fetch(playlist: Playlist, completion: @escaping (([Playlist]?, Error?) -> Void)) {
        guard let appleMusicURL: URL = urlBuilder.relationshipRequest(path: playlist.href, limit: nil, offset: nil).url else {
            print("ERROR: Could not generate URL for Album.")
            return
        }
        guard let requestData = self.encodeRequestJSON(forRequestURL: appleMusicURL) else {
            print("Could not encode JSON for Apple Music Album request.")
            return
        }
                
        let request: URLRequest = self.createURLRequest(withData: requestData)
        
        self.fetch(request) { (results: ResponseRoot<Playlist>?, error) in
            completion(results?.data, error)
        }
    }
    
    public func fetchTracksFor(playlist: Playlist, completion: @escaping (([Track]?, Error?) -> Void)) {
        self.fetch(playlist: playlist) { (playlist: [Playlist]?, error: Error?) in
            completion(playlist?[0].relationships?.tracks.data, error)
        }
    }
    
    public func search(term: String, limit: Int? = nil, offset: Int? = nil, types: [MediaType]? = nil, completion: ((SearchResults?, Error?) -> Void)?) {
        guard let applemusicURL: URL = urlBuilder.searchRequest(term: term, limit: limit, offset: offset, types: types).url else {
            print("ERROR: Could not generate Apple Music URL")
            return
        }
        guard let requestData = encodeRequestJSON(forRequestURL: applemusicURL) else { fatalError("Could not encode JSON for Apple Music API request") }
        
        let request = self.createURLRequest(withData: requestData)
        
        fetch(request) { (results: ResponseRoot<SearchResults>?, error) in
            // TODO: Searching "Weston Road Flows" returns no results. This might be an error in Cider
            completion?(results?.results, error)
        }
    }
    
    private func fetch<T>(_ request: URLRequest, completion: ((ResponseRoot<T>?, Error?) -> Void)?) {
        fetcher.fetch(request: request) { (data, error) in
            guard let data = data else {
                completion?(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(ResponseRoot<T>.self, from: data)

                // If we have any errors, callback with the first error. Otherwise callback with the results
                if let error = results.errors?.first {
                    completion?(nil, error)
                } else {
                    completion?(results, nil)
                }
            } catch {
                completion?(nil, error)
            }
        }
    }
    
    private func createURLRequest(withData data: Data) -> URLRequest {
        var request = URLRequest(url: self.apiEndpoint)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")  // the request is JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")        // the expected response is also JSON
        request.httpMethod = "POST"
        request.httpBody = data
        return request
    }
    
    private func encodeRequestJSON(forRequestURL url: URL) -> Data? {
        let encoder = JSONEncoder()
        let data: Data? = nil
        do {
            let data: Data = try encoder.encode(APIRequest(requestURL: url))
            return data
        } catch {
            return data
        }
    }
    
    struct APIRequest: Codable {
        let requestURL: URL
    }

}
