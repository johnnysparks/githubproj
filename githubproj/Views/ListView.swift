//
//  ListView.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import UIKit

class ListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items: [ListItem] = [] {
        didSet {
            collection.reloadData()
        }
    }
    
    private let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collection.frame = bounds
        collection.dataSource = self
        collection.delegate = self
        collection.register(RepoCell.self, forCellWithReuseIdentifier: RepoCell.reuseId)
        collection.register(EmptyRepoCell.self, forCellWithReuseIdentifier: EmptyRepoCell.reuseId)
        collection.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.reuseId)
        collection.register(ProjectCell.self, forCellWithReuseIdentifier: ProjectCell.reuseId)
        collection.register(ProjectColumnCell.self, forCellWithReuseIdentifier: ProjectColumnCell.reuseId)
        
        (collection.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: 300, height: 50)
        
        addSubview(collection)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    // MARK -- Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        
        switch item {
            
        case let item as ProjectColumnListItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectColumnCell.reuseId, for: indexPath) as! ProjectColumnCell
            cell.column = item.column
            return cell
            
        case let item as RepoListItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepoCell.reuseId, for: indexPath) as! RepoCell
            cell.label.text = item.repo.name
            cell.loadingLabel.text = item.message
            return cell
            
        case let item as ProjectListItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCell.reuseId, for: indexPath) as! ProjectCell
            cell.project = item.project
            return cell
            
        case _ as LoadingListItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.reuseId, for: indexPath) as! LoadingCell
            cell.activity.startAnimating()
            return cell
            
        case _ as EmptyListItem:
            return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyRepoCell.reuseId, for: indexPath) as! EmptyRepoCell
            
        default:
            return UICollectionViewCell() // CRASH
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]

        item.displayHandler?()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.touchHandler?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collection.frame = bounds
    }
}
