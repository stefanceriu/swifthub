//
//  RepositoryListViewController.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage

class RepositoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RepositorySearchServiceDelegate {
    
    private let searchService: RepositorySearchService
    private let imageCache: AutoPurgingImageCache
    
    @IBOutlet weak private var tableView: UITableView!
    
    init(_ repositorySearchService: RepositorySearchService) {
        self.searchService = repositorySearchService
        self.imageCache = AutoPurgingImageCache()
        super.init(nibName: nil, bundle: nil)
        
        self.searchService.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: String(describing: RepositoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepositoryTableViewCell.self))
        
        self.searchService.performSearch()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchService.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchResultItem = self.searchService.searchResults[indexPath.row]
        
        let cell: RepositoryTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: RepositoryTableViewCell.self)) as! RepositoryTableViewCell
        
        cell.titleLabel.text = searchResultItem.name;
        cell.authorLabel.text = searchResultItem.owner.login
        
        let avatarURLRequest = URLRequest(url: searchResultItem.owner.avatarURL)
        
        if let image = self.imageCache.image(for: avatarURLRequest) {
            cell.avatarImageView.image = image
        } else {
            AF.request(searchResultItem.owner.avatarURL).responseImage { [weak self] response in
                if case .success(let image) = response.result {
                    self?.imageCache.add(image, for: avatarURLRequest)
                    self?.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        return cell
    }
    
    // MARK: RepositorySearchServiceDelegate
    
    func searchServiceDidFinishSearching() {
        self.tableView.reloadData()
    }
    
    func searchServiceDidFailSearchingWithError(error: RepositorySearchServiceError) {
        print("Failed searching for repositories with error: \(error). Should probably retry..")
        self.tableView.reloadData()
    }
}
