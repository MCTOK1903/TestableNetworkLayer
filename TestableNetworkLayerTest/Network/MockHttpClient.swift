//
//  MockHttpClient.swift
//  TestableNetworkLayerTest
//
//  Created by Muhammed Celal Tok on 2.08.2022.
//

import Foundation
@testable import TestableNetworkLayer

final class MockHtppClient: HttpClientProtocol, Mockable {
    func fetch<T>(url: URL, completion: @escaping (Result<[T], Error>) -> Void) where T : Decodable, T : Encodable {
        
        return loadJson(filename: "CatResponse",
                        extensionType: .json,
                        type: T.self, completion: completion)
    }
    
}
