//
//  ListView.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import UIKit

class ProjectListLayout: UICollectionViewLayout {
    
    var bounds: CGRect = CGRect.zero
    var attributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    var maxHeight: CGFloat = 0
    var maxWidth: CGFloat = 0
    var colHeights: [Int: CGFloat] = [:]
    
    override func prepare() {
        guard let collection = collectionView, let list = collection.superview as? ListView else { return }
        
        attributes = [:]
        
        colHeights = [:]
        let numCols = list.items.filter({ $0 is ProjectColumnListItem }).count
        let colWidth = collection.frame.width
        
        var col = 0
        
        let columns = (list.items.filter({ $0 is ProjectColumnListItem }) as! [ProjectColumnListItem]).map({ $0.column.id })
        
        for (row, item) in list.items.enumerated() {
            
            switch item {
            case let item as ProjectColumnListItem:
                col = columns.index(of: item.column.id)!
                
            case let item as ProjectCardListItem:
                let columnId = store.state.github.cardColumns[item.card]!
                col = columns.index(of: columnId)!

            default: break
            }
            
            let indexPath = IndexPath(item: row, section: 0)
            let a = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            colHeights[col] = colHeights[col] ?? 0
            a.frame = CGRect(x: CGFloat(col) * colWidth, y: colHeights[col]!, width: colWidth, height: 100)
            colHeights[col] = colHeights[col]! + 100
            attributes[indexPath] = a
            
            
        }
        maxWidth = CGFloat(numCols) * colWidth
        maxHeight = colHeights.flatMap({ $1 }).reduce(0) { max($0, $1) }
        
        print("w: \(maxWidth) h: \(maxHeight)")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter({ $1.frame.intersects(rect) }).flatMap({ $1 })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if bounds.width == newBounds.width {
            return false
        } else {
            bounds = newBounds
            return true
        }
    }
}


class ListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var items: [ListItem] = [] {
        didSet {
            collection.reloadData()
        }
    }
        
    private let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: ProjectListLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collection.frame = bounds
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        
        let register: [String : AnyClass] = [
            RepoCell.reuseId : RepoCell.self,
            EmptyRepoCell.reuseId : EmptyRepoCell.self,
            LoadingCell.reuseId : LoadingCell.self,
            ProjectCell.reuseId : ProjectCell.self,
            ProjectColumnCell.reuseId : ProjectColumnCell.self,
            ProjectCardCell.reuseId : ProjectCardCell.self,
        ]
        
        register.forEach { reuseId, klass in
            collection.register(klass, forCellWithReuseIdentifier: reuseId)
        }

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
            
        case let item as ProjectCardListItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCardCell.reuseId, for: indexPath) as! ProjectCardCell
            cell.card = item.card
            return cell
            
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
    
    // MARK - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 50)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collection.frame = bounds
    }
}
