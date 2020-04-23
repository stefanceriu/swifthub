//
//  RepositorySearchResultItem.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import Foundation

struct RepositorySearchResultOwner: Codable, Equatable {
    var login: String
    var avatarUrl: URL
}

struct RepositorySearchResultItem : Codable, Equatable {
    var name: String
    var owner: RepositorySearchResultOwner
}
