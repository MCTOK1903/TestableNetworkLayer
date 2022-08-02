//
//  CatViewModelTest.swift
//  TestableNetworkLayerTest
//
//  Created by Muhammed Celal Tok on 2.08.2022.
//

import XCTest
@testable import TestableNetworkLayer

class CatViewModelTest: XCTestCase {

    var catViewModel: CatViewModelProcol!
    let fetchCatImageExpectation = XCTestExpectation(description: "Fetched Cat Image")
    let fetchedWithErrorExpectation = XCTestExpectation(description: "Fetched Error")
    
    override func setUp() {
        super.setUp()
        
        catViewModel = CatViewModel(httpClient: MockHtppClient())
        catViewModel.output = self
    }
    
    override func tearDown() {
        catViewModel = nil
        
        super.tearDown()
    }
    
    func test_fetchCatImage_Success() {
        
        catViewModel.getCatImage(with: "https://api.thecatapi.com/v1/images/search")
        
        wait(for: [fetchCatImageExpectation], timeout: 2)
    }
    
    func test_FetchCathImage_BadURL() {
        catViewModel.getCatImage(with: "bad url")
        
        wait(for: [fetchedWithErrorExpectation], timeout: 2)
    }
}

extension CatViewModelTest: CatViewModelOutput {
    func returnCatModel(with value: [CatModel]) {
        XCTAssertEqual(value.count, 1)
        fetchCatImageExpectation.fulfill()
    }

    
    func showError(with error: String) {
        XCTAssertNotNil(error)
        fetchedWithErrorExpectation.fulfill()
    }

}
