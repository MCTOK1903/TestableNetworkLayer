//
//  Mockable.swift
//  TestableNetworkLayerTest
//
//  Created by Muhammed Celal Tok on 2.08.2022.
//

import Foundation

enum FileExtensionType: String {
    case json = ".json"
}

protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    
    func loadJson<T: Decodable>(filename: String,
                                extensionType: FileExtensionType,
                                type: T.Type,
                                completion: @escaping (Result<[T], Error>) -> Void)
}

extension Mockable {
    var bundle: Bundle {
        Bundle(for: type(of: self))
    }
    
    func loadJson<T: Decodable>(filename: String, extensionType: FileExtensionType, type: T.Type,  completion: @escaping (Result<[T], Error>) -> Void) {
        guard let path = bundle.url(forResource: filename,
                                    withExtension: extensionType.rawValue) else {
            fatalError("Failed to load Json file.")
        }
        
        do {
            let data = try Data(contentsOf: path)
            let decoedObject = try JSONDecoder().decode([T].self, from: data)
            
            completion(.success(decoedObject))
        } catch {
            print("❌ \(error)")
            fatalError("Failed to decoed the Json.")
        }
    }
}
