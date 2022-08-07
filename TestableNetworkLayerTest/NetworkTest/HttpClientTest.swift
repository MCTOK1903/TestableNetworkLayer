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
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
    }
    
    func test_GetCat() throws {
        let reqURL = URL(string: "https://api.thecatapi.com/v1/images/search")!
        let response = HTTPURLResponse(url: reqURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        var mockData: Data?
        let laodJsonExpectation = XCTestExpectation(description: "loadJson")
        
        loadJson(filename: "CatResponse",
                 extensionType: .json,
                 type: CatModel.self) { result in
            switch result {
            case .success(let response):
                mockData = try? JSONEncoder().encode(response)
                laodJsonExpectation.fulfill()
            case .failure:
                break
            }
        }
        
        wait(for: [laodJsonExpectation], timeout: 1)
        
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData!)
        }
        
        let httpClient = HttpClient(urlsession: urlSession)
        
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
        let reqURL = URL(string: "https://api.thecatapi.com/v1/images/search")!
        let response = HTTPURLResponse(url: reqURL,
                                       statusCode: 404,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        var mockData: Data?
        let laodJsonExpectation = XCTestExpectation(description: "loadJson")
        
        loadJson(filename: "CatResponse",
                 extensionType: .json,
                 type: CatModel.self) { result in
            switch result {
            case .success(let response):
                mockData = try? JSONEncoder().encode(response)
                laodJsonExpectation.fulfill()
            case .failure:
                break
            }
        }
        
        wait(for: [laodJsonExpectation], timeout: 1)
        
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData!)
        }
        
        let httpClient = HttpClient(urlsession: urlSession)
        
        let expectation = XCTestExpectation(description: "response")
        
        httpClient.fetch(url: reqURL) { (response: Result<[CatModel], Error>) in
            switch response {
            case .success(let catModel):
                XCTAssertThrowsError("Fatal Error")
                
            case .failure(let error):
                XCTAssertEqual(HttpError.badResponse, error as? HttpError)
                expectation.fulfill()
            }
            
        }
        wait(for: [expectation], timeout: 2)
    }
    
    
    func test_getCat_EndogingError() {
        let reqURL = URL(string: "https://api.thecatapi.com/v1/images/search")!
        let response = HTTPURLResponse(url: reqURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        var mockData: Data?
        let laodJsonExpectation = XCTestExpectation(description: "loadJson")
        
        loadJson(filename: "CatResponse",
                 extensionType: .json,
                 type: CatModel.self) { result in
            switch result {
            case .success(let response):
                mockData = try? JSONEncoder().encode(response)
                laodJsonExpectation.fulfill()
            case .failure:
                break
            }
        }
        
        wait(for: [laodJsonExpectation], timeout: 1)
        
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData!)
        }
        
        let httpClient = HttpClient(urlsession: urlSession)
        
        let expectation = XCTestExpectation(description: "response")
        
        httpClient.fetch(url: reqURL) { (response: Result<[[CatModel]], Error>) in
            switch response {
            case .success(let catModel):
                XCTAssertThrowsError("Fatal Error")
                
            case .failure(let error):
                XCTAssertEqual(HttpError.errorDecodingData, error as? HttpError)
                expectation.fulfill()
            }
            
        }
        wait(for: [expectation], timeout: 2)
    }
}
