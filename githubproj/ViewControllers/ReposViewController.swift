//
//  ViewController.swift
//  githubproj
//
//  Created by John Sparks on 1/24/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import UIKit

import ReSwift

class CollectionViewCell: UICollectionViewCell {
    static var reuseId: String { return "\(self)" }
}


class EmptyRepoCell: CollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.darkGray
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class LoadingCell: CollectionViewCell {
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activity)
        activity.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        activity.center = contentView.center
    }
}

class RepoCell: CollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = UIColor.white
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        label.frame = bounds
    }
}

class ReposView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let sortControlTopMargin: CGFloat = 20.0
    let sortControlHeight: CGFloat = 44.0
    let sortControl = UISegmentedControl(items: ["☝️", "👇"])
    let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var state: AppState = AppState() {
        didSet {
            collection.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sortControl.frame = CGRect(x: 0, y: sortControlTopMargin, width: bounds.size.width, height: sortControlHeight)
        sortControl.addTarget(self, action: #selector(ReposView.changedSort), for: .valueChanged)
        
        collection.frame = CGRect(x: 0, y: sortControl.frame.maxY, width: bounds.size.width, height: bounds.size.height - sortControl.frame.maxY)
        collection.dataSource = self
        collection.delegate = self
        collection.register(RepoCell.self, forCellWithReuseIdentifier: RepoCell.reuseId)
        collection.register(EmptyRepoCell.self, forCellWithReuseIdentifier: EmptyRepoCell.reuseId)
        collection.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.reuseId)
        (collection.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: 300, height: 50)
        
        addSubview(collection)
        addSubview(sortControl)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK -- Segmented Control
    func changedSort(){
        store.dispatch(ReposSortAction(direction: sortControl.selectedSegmentIndex == 0 ? .desc : .asc))
    }
    
    // MARK -- Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return state.repoFeed.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = state.repoFeed[indexPath.row]
        
        switch item {
        case let item as GithubRepo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepoCell.reuseId, for: indexPath) as! RepoCell
            cell.label.text = item.name
            return cell
        case _ as LoadingFeedItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.reuseId, for: indexPath) as! LoadingCell
            cell.activity.startAnimating()
            return cell
        case _ as EmptyFeedItem:
            return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyRepoCell.reuseId, for: indexPath) as! EmptyRepoCell
        default:
            return UICollectionViewCell() // CRASH
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = state.repoFeed[indexPath.row]

        switch item {
        case _ as GithubRepo: break
        case _ as LoadingFeedItem:
            if state.loadingRepos == false {
                store.dispatch(LoadReposAction())
            }
        case _ as EmptyFeedItem: break
        default: break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sortControl.frame = CGRect(x: 0, y: sortControlTopMargin, width: bounds.size.width, height: sortControlHeight)
        
        collection.frame = CGRect(x: 0, y: sortControl.frame.maxY, width: bounds.size.width, height: bounds.size.height - sortControl.frame.maxY)
    }
}

class ReposViewController: BaseViewController {

    let reposView = ReposView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(reposView)
        
        GithubAPI.shared.authorize { error in
            
            store.dispatch(RefreshReposAction())
            
        }
    }
    
    override func newState(state: AppState) {
        reposView.state = state
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        reposView.frame = view.bounds
    }
}

