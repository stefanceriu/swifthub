//
//  ServiceClient.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import Foundation
import Alamofire

private let userRepoPath = "https://api.github.com/user/repos"

enum ServiceClientError: Error {
    case invalidResponseStructure(String)
    case genericError(String)
}

class ServiceClient: RequestInterceptor {
    
    let requestDispatcher: Session
    let accessToken: String
    
    init(requestDispatcher: Session, accessToken: String) {
        self.requestDispatcher = requestDispatcher
        self.accessToken = accessToken
    }
    
    public func requestUserRepositories(result: @escaping (Result<[[String: Any]], ServiceClientError>) -> Void) {
        
        self.requestDispatcher.request(userRepoPath, headers: ["Accept": "application/json"], interceptor: self).responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case .success(let value):
                
                guard let json = value as? [[String: Any]] else {
                    result(.failure(ServiceClientError.invalidResponseStructure("Could not retrieve results list, aborting.")))
                    return
                }
                
                result(.success(json))
                
            case .failure(let error):
                result(.failure(ServiceClientError.genericError(error.localizedDescription)))
            }
        })
    }
    
    // MARK: RequestAdapter
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: self.accessToken))

        completion(.success(urlRequest))
    }
}
