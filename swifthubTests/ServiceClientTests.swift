//
//  swifthubTests.swift
//  swifthubTests
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import XCTest
import Alamofire
import Mocker
@testable import swifthub

class ServiceClientTests: XCTestCase {
    
    private var serviceClient: ServiceClient?
    
    private let decoder : JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])

        let sessionManager = Session(configuration: configuration)
        
        self.serviceClient = ServiceClient(requestDispatcher: sessionManager, accessToken: "someAccessToken")
    }

    override func tearDownWithError() throws {
        self.serviceClient = nil
    }

    func testSuccess() throws {
        
        let requestExpectation = expectation(description: "Request should finish")
        
        let mockRepo = RepositorySearchResultItem(name: "Foo", owner: RepositorySearchResultOwner(login: "Bar", avatarUrl: URL(string: "http://foo.bar")!))
        
        let mockedData = try! JSONEncoder().encode([mockRepo])
        let mock = Mock(url: URL(string: "https://api.github.com/user/repos")!, dataType: .json, statusCode: 200, data: [.get: mockedData])
        mock.register()
        
        self.serviceClient?.requestUserRepositories(result: { (result) in
            switch(result) {
            case .failure(_):
                XCTFail()
            case .success(let results):
                XCTAssert(results.count == 1)
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                    let items = try? self.decoder.decode([RepositorySearchResultItem].self, from: jsonData)
                    
                    XCTAssert(items?.count == 1)
                    
                    XCTAssert(items?.first == mockRepo)
                    
                } catch {
                    XCTFail()
                }
            }
            
            requestExpectation.fulfill()
        })
        
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testInvalidJSONResponse() throws {
        
        let requestExpectation = expectation(description: "Request should finish")
        
        let mock = Mock(url: URL(string: "https://api.github.com/user/repos")!, dataType: .json, statusCode: 200, data: [.get: "Some invalid json".data(using: .utf8)!])
        mock.register()
        
        self.serviceClient?.requestUserRepositories(result: { (result) in
            switch(result) {
            case .failure(let error):
                guard case ServiceClientError.genericError = error else {
                    XCTFail()
                    return
                }
                
            case .success(_):
                XCTFail()
            }
            
            requestExpectation.fulfill()
        })
        
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testInvalidResponseStructure() throws {
        
        let requestExpectation = expectation(description: "Request should finish")
        
        let mockedData = try! JSONEncoder().encode(["Foo": "Bar"])
        let mock = Mock(url: URL(string: "https://api.github.com/user/repos")!, dataType: .json, statusCode: 200, data: [.get: mockedData])
        mock.register()
        
        self.serviceClient?.requestUserRepositories(result: { (result) in
            switch(result) {
            case .failure(let error):
                guard case ServiceClientError.invalidResponseStructure = error else {
                    XCTFail()
                    return
                }
                
            case .success(_):
                XCTFail()
            }
            
            requestExpectation.fulfill()
        })
        
        wait(for: [requestExpectation], timeout: 10.0)
    }
}
