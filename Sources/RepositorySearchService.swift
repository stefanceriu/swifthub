//
//  RepositorySearchService.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import Foundation

enum RepositorySearchServiceError: Error {
    case genericError(String)
}

protocol RepositorySearchServiceDelegate : AnyObject {
    func searchServiceDidFinishSearching()
    func searchServiceDidFailSearchingWithError(error: RepositorySearchServiceError)
}

class RepositorySearchService {
    
    private let serviceClient: ServiceClient
    private let decoder : JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    weak var delegate: RepositorySearchServiceDelegate?
    var searchResults: [RepositorySearchResultItem]
    
    init(_ serviceClient: ServiceClient) {
        self.serviceClient = serviceClient
        self.searchResults = []
    }
    
    public func performSearch() {
        self.serviceClient.requestUserRepositories { innerResult in
            switch innerResult {
            case .success(let results):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: results, options: [])
                    let items = try self.decoder.decode([RepositorySearchResultItem].self, from: jsonData)
                    self.searchResults = items.sorted(by: {$0.name < $1.name})
                    self.delegate?.searchServiceDidFinishSearching()
                }
                catch {
                    self.delegate?.searchServiceDidFailSearchingWithError(error: RepositorySearchServiceError.genericError(error.localizedDescription))
                }
            case .failure(let error):
                self.delegate?.searchServiceDidFailSearchingWithError(error: RepositorySearchServiceError.genericError(error.localizedDescription))
            }
        }
        
    }
}
