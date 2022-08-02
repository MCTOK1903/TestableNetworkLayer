//
//  HttpClient.swift
//  TestableNetworkLayer
//
//  Created by Muhammed Celal Tok on 2.08.2022.
//

import Foundation

enum HttpError: Error {
    case badURL, badResponse, errorDecodingData, invalidURL
}

protocol HttpClientProtocol {
    func fetch<T: Codable>(url: URL, completion: @escaping (Result<[T], Error>) -> Void)
}

class HttpClient: HttpClientProtocol {
    
    func fetch<T>(url: URL, completion: @escaping (Result<[T], Error>) -> Void) where T : Decodable, T : Encodable {
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(.failure(HttpError.badResponse))
                return
            }
            
            guard let data = data,
                  let object = try? JSONDecoder().decode([T].self, from: data) else {
                completion(.failure(HttpError.errorDecodingData))
                return
            }
            
            completion(.success(object))
        })
    }
}
