//
//  HttpClientTest.swift
//  TestableNetworkLayerTest
//
//  Created by Muhammed Celal Tok on 6.08.2022.
//

import XCTest
@testable import TestableNetworkLayer

class HttpClientTest: XCTestCase, Mockable {
    
    var urlSession: URLSession!
    var httpClient: HttpClientProtocol!
    let reqURL = URL(string: "https://api.thecatapi.com/v1/images/search")!
    
    
    let mockString =
    """
        [
            {
                "id": "8on",
                "url": "https://cdn2.thecatapi.com/images/8on.jpg",
            }
        ]
    """
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        
        httpClient = HttpClient(urlsession: urlSession)
    }
    
    override func tearDown() {
        urlSession = nil
        httpClient = nil
        
        super.tearDown()
    }
    
    func test_GetCat_Success() throws {
        
        let response = HTTPURLResponse(url: reqURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        let mockData: Data = Data(mockString.utf8)
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        
        httpClient.fetch(url: reqURL) { (response: Result<[CatModel], Error>) in
            switch response {
            case .success(let catModel):
                XCTAssertEqual(catModel.first?.url, "https://cdn2.thecatapi.com/images/8on.jpg")
                XCTAssertEqual(catModel.count, 1)
                
                expectation.fulfill()
            case .failure(let failure):
                XCTAssertThrowsError(failure)
            }
            
        }
        wait(for: [expectation], timeout: 2)
    }
    
    
    func test_getCat_BadResponse() throws {
        let response = HTTPURLResponse(url: reqURL,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        let mockData: Data = Data(mockString.utf8)
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        
        httpClient.fetch(url: reqURL) { (response: Result<[CatModel], Error>) in
            switch response {
            case .success:
                XCTAssertThrowsError("Fatal Error")
            case .failure(let error):
                XCTAssertEqual(HttpError.badResponse, error as? HttpError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }
    
    
    func test_GetCat_EncodingError() {
        let response = HTTPURLResponse(url: reqURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        let mockData: Data = Data(mockString.utf8)
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        
        httpClient.fetch(url: reqURL) { (response: Result<[[CatModel]], Error>) in
            switch response {
            case .success:
                XCTAssertThrowsError("Fatal Error")
            case .failure(let error):
                XCTAssertEqual(HttpError.errorDecodingData, error as? HttpError)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }
}
