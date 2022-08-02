//
//  CatViewModel.swift
//  TestableNetworkLayer
//
//  Created by Muhammed Celal Tok on 2.08.2022.
//

import Foundation
import UIKit

protocol CatViewModelOutput: AnyObject {
    func returnCatModel(with value: [CatModel])
    func showError(with error: String)
}

protocol CatViewModelProcol {
    var output: CatViewModelOutput? { get set }
    
    func getCatImage(with url: String)
}

class CatViewModel: CatViewModelProcol {
    
    private var httpClient: HttpClientProtocol
    weak var output: CatViewModelOutput?
    
    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }
    
    func getCatImage(with url: String) {
        
        guard let url = URL(string: url) else {
            self.output?.showError(with: HttpError.badURL.localizedDescription)
            return
        }
        
        httpClient.fetch(url: url) { [weak self] (response: Result<[CatModel], Error>) in
            
            switch response {
            case .success(let catModel):
                
                self?.output?.returnCatModel(with: catModel)
            case .failure(let error):
                self?.output?.showError(with: error.localizedDescription)
            }
        }
    }
}
